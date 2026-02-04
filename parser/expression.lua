local util = require("util")
---@param parser Parser
return function(parser)

---@class Parser
local Parser = parser

---@return Expression | Error, Span
function Parser:parseExpression()
	return self:parseBoolOr()
end

---@alias PrimaryExpression NilLiteralExpression | BoolLiteralExpression | NumLiteralExpression | StringLiteralExpression | TableLiteralExpression | VarArgExpression | FunctionExpression | PrefixExpression

---@return PrimaryExpression | Error, Span
function Parser:parsePrimary()
	if self.tokenStream:isDone() then return self.tokenStream:errorHere(true, "EOF") end
	return self.tokenStream:scope("primary expression", {
		{"nil", function()
			local token = self.tokenStream:next()
			if token.type == "nilLiteral" then
				return {
					type = "nil",
				}
			end
			return self.tokenStream:errorHere(true, "Not a nil literal")
		end},
		{"boolean", function()
			local token = self.tokenStream:next()
			if token.type == "boolLiteral" then
				return {
					type = "bool",
					value = token.value
				}
			end
			return self.tokenStream:errorHere(true, "Not a bool literal")
		end},
		{"number", function()
			local token = self.tokenStream:next()
			if token.type == "number" then
				return {
					type = "number",
					value = token.value
				}
			end
			return self.tokenStream:errorHere(true, "Not a number literal")
		end},
		{"string", function()
			local token = self.tokenStream:next()
			if token.type == "string" then
				return {
					type = "string",
					value = token.value
				}
			end
			return self.tokenStream:errorHere(true, "Not a string literal")
		end},
		{"table", function()
			local result = self:parseTableLiteral()
			if result.isError then return result end
			return {
				type = "table",
				value = result
			}
		end},
		{"vararg", function()
			self.tokenStream:expect({type="symbol",value="..."},true)
			return { type="vararg" }
		end},
		{"function", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="function"}) then
				return self.tokenStream:errorNext(true, "No function kw")
			end

			local impl = self:parseFunctionDefinition()
			if impl.isError then
				return impl:extend("While parsing function expression")
			end

			return {
				type = "funcDef",
				impl = impl,
			}
		end},
		{"prefix", function()
			local e,s = self:parsePrefixExpression()
			return e,s
		end},
	})
end

---@return UnaryExpression | PrimaryExpression | Error, Span
function Parser:parseUnary()
	if self.tokenStream:eq(
		{type="operator",value="~"},
		{type="operator",value="-"},
		{type="operator",value="#"},
		{type="operator",value="not"}
	) then
		local span = self.tokenStream:atNext()
		local operator = self.tokenStream:next()
		if operator == nil then
			return self.tokenStream:errorHere(true, "No operator")
		end
		if operator.type ~= "operator" then
			return self.tokenStream:errorHere(true, "Not an operator")
		end

		local right, rightSpan = self:parseUnary()
		if right.isError then
			return right:extend("While parsing unary " .. operator)
		end

		return {
			type = "unary",
			operator = operator.value,
			right = right,
		}, span + rightSpan
	end

	local e,s = self:parsePrimary()
	return e,s
end

---@param children fun(self: Parser): Expression|Error, Span
---@param operators Token[]
---@return fun(self: Parser): Expression|Error, Span
local function generatePrecedenceFunc(children, operators)
	return function(self)
		local expr, exprSpan = children(self)
		if expr.isError then return expr, expr.span end

		while self.tokenStream:eq(table.unpack(operators)) do
			local operator = self.tokenStream:next() --[[@as Token]]
			if operator == nil then return self.tokenStream:errorHere(true, "Missing operator") end
			if operator.type ~= "operator" then return self.tokenStream:errorHere(true, "Not an operator") end

			local right, rightSpan = children(self)
			if right.isError then return right:extend("While parsing binary " .. operator) end

			expr = {
				type = "binary",
				left = expr --[[@as Expression]],
				operator = operator.value --[[@as string]],
				right = right --[[@as Expression]],
			}
			exprSpan = exprSpan + rightSpan
		end

		return expr, exprSpan
	end
end

Parser.parseFactor = generatePrecedenceFunc(
	Parser.parseUnary,
	{
		{type="operator",value="*"},
		{type="operator",value="/"},
		{type="operator",value="%"},
		{type="operator",value="//"},
	}
)
Parser.parseTerm = generatePrecedenceFunc(
	Parser.parseFactor,
	{
		{type="operator",value="+"},
		{type="operator",value="-"},
		{type="operator",value=".."},
	}
)
Parser.parseComparison = generatePrecedenceFunc(
	Parser.parseTerm,
	{
		{type="operator",value="<"},
		{type="operator",value="<="},
		{type="operator",value=">"},
		{type="operator",value=">="},
		{type="operator",value="=="},
		{type="operator",value="~="},
	}
)
Parser.parseBoolAnd = generatePrecedenceFunc(
	Parser.parseComparison,
	{
		{type="operator",value="and"},
	}
)
Parser.parseBoolOr = generatePrecedenceFunc(
	Parser.parseBoolAnd,
	{
		{type="operator",value="or"},
	}
)

---@return PrefixExpression | Error, Span
function Parser:parsePrefixExpression()
	local access, span = self.tokenStream:scope("prefix start", {
		{"group", function()
			self.tokenStream:expect({type="symbol",value="("}, true)
			local exp, expSpan = self:parseExpression()
			if exp.isError then
				return exp, expSpan
			end
			if not self.tokenStream:nextIfEq({type="symbol",value=")"}) then
				return self.tokenStream:errorNext(false, "Missing close paren")
			end
			return {type="prefix",subtype="group",inner=exp}
		end},
		{"access", function()
			local ident = self.tokenStream:expect({type="identifier"},true)
			return {type="prefix",subtype="identifier",inner = ident.value}
		end},
	})

	if access.isError then return access, span end
	---@cast access -Error

	while true do
		local value, subspan = self.tokenStream:scope("prefix extensions", {
			{"Dot access", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="."}) then
					return self.tokenStream:errorNext(true, "No dot for dot access")
				end
				local sub = self.tokenStream:next()
				if sub == nil then return self.tokenStream:errorHere(false, "No subscript") end
				if sub.type ~= "identifier" then
					return self.tokenStream:errorHere(false, "Subscript is not an identifier")
				end

				return {
					type = "prefix",
					subtype = "dot",
					left = access,
					sub = sub.value,
				}
			end},
			{"Index access", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="["}) then
					return self.tokenStream:errorNext(true, "No open bracket")
				end
				local openBracket = self.tokenStream:here()

				local inner = self:parseExpression()
				if inner.isError then return inner end

				if not self.tokenStream:nextIfEq({type="symbol",value="]"}) then
					return openBracket:error(false, "No close bracket")
				end

				return {
					type = "prefix",
					subtype = "index",
					left = access,
					sub = inner,
				}
			end},
			{"Call", function()
				local call = self:parseFunctionCall(access)
				if call.isError then return call end
				return {
					type = "prefix",
					subtype = "call",
					call = call,
				}
			end},
		})
		if not value.isError then
			access = value
			span = span + subspan
		else
			if not value.recoverable then return value, span end
			break
		end
	end
	return access, span
end

---Because the only use case of this function is parsing assignment targets,
---it is a fatal error to parse an expression which is not an access.
---@return Access | Error, Span
function Parser:parseAccess()
	local value, span = self:parsePrefixExpression()
	if value.isError then return value:extend("While parsing access") end
	if value.subtype == "dot" or value.subtype == "index" or value.subtype == "identifier" then
		return value, span
	end
	return span:error(true, "Not an access")
end

---@param prefix PrefixExpression
---@return FunctionCall | Error, Span
function Parser:parseFunctionCall(prefix)
	local output, span = nil, self.tokenStream:atNext()
	while not self.tokenStream:isDone() do
		local name
		if self.tokenStream:nextIfEq({type="symbol",value=":"}) then
			name = self.tokenStream:next() -- todo assert this is identifier
		end

		if self.tokenStream:isDone() then return self.tokenStream:errorHere(true, "EOF before arguments") end

		local arguments, argumentSpan = self.tokenStream:scope("arguments", {
			{"Parenthetical arguments", function()
				self.tokenStream:expect({type="symbol",value="("}, true)

				local args
				if not self.tokenStream:nextIfEq({type="symbol",value=")"}) then
					args = self:parseSequence(self.parseExpression, {type="symbol",value=","})
					self.tokenStream:expect({type="symbol",value=")"},false)
				else
					args = {}
				end

				return args
			end},
			{"String arguments", function()
				local str = self.tokenStream:next()
				---@cast str -?
				if str.type ~= "string" then
					return self.tokenStream:errorHere(true, "Not a string literal")
				end
				return {{type="string",value=str.value}}
			end},
			{"Tabular arguments", function()
				local lit, tblSpan = self:parseTableLiteral()
				if lit.isError then return lit end
				return {{type="tableLiteral",value=lit}}, tblSpan
			end},
		})

		if arguments.isError then
			if arguments.recoverable then
				break
			else
				return arguments, argumentSpan
			end
		end

		if name then
			output = {
				type = "call",
				method = name.value,
				callee = output or prefix,
				args = arguments,
			}
		else
			output = {
				type = "call",
				callee = output or prefix,
				args = arguments,
			}
		end
	end

	if output == nil then
		return self.tokenStream:errorHere(true, "Not a call"), span
	end
	return output, span
end

end
