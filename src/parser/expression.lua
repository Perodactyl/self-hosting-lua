local util = require("util")
local Error = require("source.error")

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
	local r,s = self.tokenStream:scope("primary expression", {
		{"nil", function()
			local token = self.tokenStream:next()
			if token == nil then error("EOF", 0) end
			if token.type == "nil" then
				return token
			end
			return self.tokenStream:errorHere(true, "Not a nil literal")
		end},
		{"boolean", function()
			local token = self.tokenStream:next()
			if token == nil then error("EOF", 0) end
			if token.type == "boolean" then
				return token
			end
			return self.tokenStream:errorHere(true, "Not a bool literal")
		end},
		{"number", function()
			local token = self.tokenStream:next()
			if token == nil then error("EOF", 0) end
			if token.type == "number" then
				return token
			end
			return self.tokenStream:errorHere(true, "Not a number literal")
		end},
		{"string", function()
			local token = self.tokenStream:next()
			if token == nil then error("EOF", 0) end
			if token.type == "string" then
				return token
			end
			return self.tokenStream:errorHere(true, "Not a string literal")
		end},
		{"table", function()
			local result = Error.try(self:parseTableLiteral())
			return result
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
	return r --[[@as PrimaryExpression]],s
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
			return right:extend("While parsing unary " .. operator.value)
		end

		return {
			type = "unary",
			operator = operator,
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
			if right.isError then return right:extend("While parsing binary " .. operator.value) end

			expr = {
				type = "binary",
				left = expr --[[@as Expression]],
				operator = operator --[[@as OperatorToken]],
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
			local openParen = self.tokenStream:expect({type="symbol",value="("}, true)
			local exp, expSpan = self:parseExpression()
			if exp.isError then
				return exp, expSpan
			end
			local closeParen = self.tokenStream:expect({type="symbol",value=")"}, false)
			return {type="prefix",subtype="group",inner=exp, openParen=openParen, closeParen=closeParen}
		end},
		{"access", function()
			local ident = self.tokenStream:expect({type="identifier"},true)
			return {type="prefix",subtype="identifier",inner = ident}
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

end
