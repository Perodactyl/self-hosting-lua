local util = require("util")
---@param parser Parser
return function(parser)

---@class Parser
local Parser = parser

---@return Expression | nil, string?
function Parser:parseExpression()
	return self:parseBoolOr()
end

---@return NilLiteralExpression | BoolLiteralExpression | NumLiteralExpression | StringLiteralExpression | TableLiteralExpression | VarArgExpression | FunctionExpression | PrefixExpression | nil, string?
function Parser:parsePrimary()
	return self.tokenStream:scope("primary expression",
		"Nil literal expression", function()
			local token = self.tokenStream:next()
			if token == nil then return nil, "No token" end
			if token.type == "nilLiteral" then
				return {
					type = "nil",
				}
			end
			return nil, "Not a nil literal"
		end,
		"Boolean literal expression", function()
			local token = self.tokenStream:next()
			if token == nil then return nil, "No token" end
			if token.type == "boolLiteral" then
				return {
					type = "bool",
					value = token.value
				}
			end
			return nil, "Not a bool literal"
		end,
		"Number literal expression", function()
			local token = self.tokenStream:next()
			if token == nil then return nil, "No token" end
			if token.type == "number" then
				return {
					type = "number",
					value = token.value
				}
			end
			return nil, "Not a number literal"
		end,
		"String literal expression", function()
			local token = self.tokenStream:next()
			if token == nil then return nil, "No token" end
			if token.type == "string" then
				return {
					type = "string",
					value = token.value
				}
			end
			return nil, "Not a string literal"
		end,
		"Table literal expression", function()
			local result,reason = self:parseTableLiteral()
			if result == nil then return nil, reason end
			return {
				type = "table",
				value = result
			}
		end,
		"Vararg expression", function()
			local token = self.tokenStream:next()
			if token == nil then return nil, "No token" end
			if token.type ~= "symbol" then return nil, "No ellipsis" end
			if token.value ~= "..." then return nil, "No ellipsis" end
			return { type="vararg" }
		end,
		"Function expression", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="function"}) then return nil, "No function kw" end

			local impl, implReason = self:parseFunctionDefinition()
			if impl == nil then return nil, "No function impl: " .. (implReason or "") end

			return {
				type = "funcDef",
				impl = impl,
			}
		end,
		"Prefix expression", function()
			return self:parsePrefixExpression()
		end
	)
end

function Parser:parseUnary()
	if self.tokenStream:eq(
		{type="operator",value="~"},
		{type="operator",value="-"},
		{type="operator",value="#"},
		{type="operator",value="not"}
	) then
		local operator = self.tokenStream:next()
		if operator == nil then return nil, "No operator" end
		if operator.type ~= "operator" then return nil, "Not an operator" end
		local right = self:parseUnary()
		return {
			type = "unary",
			operator = operator.value,
			right = right,
		}
	end
	return self:parsePrimary()
end

---@param children fun(self: Parser): Expression|nil, string?
---@param operators Token[]
---@return fun(self: Parser): Expression|nil, string?
local function generatePrecedenceFunc(children, operators)
	return function(self)
		local expr, exprReason = children(self)

		while self.tokenStream:eq(table.unpack(operators)) do
			local operator = self.tokenStream:next() --[[@as Token]]
			local right, rightReason = children(self)

			if expr == nil then return nil, "Missing expression: " .. (exprReason or "") end
			if operator == nil then return nil, "Missing operator" end
			if right == nil then return nil, "Missing right-hand side: " .. (rightReason or "") end

			expr = {
				type = "binary",
				left = expr,
				operator = operator.value --[[@as string]],
				right = right,
			}
		end

		return expr
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

---@return PrefixExpression | nil, string?
function Parser:parsePrefixExpression()
	local access, beginReason = self.tokenStream:scope("prefix expression start",
		"Group prefix", function()
			if self.tokenStream:nextIfEq({type="symbol",value="("}) then
				local exp = self:parseExpression()
				if self.tokenStream:nextIfEq({type="symbol",value=")"}) then
					return {type="prefix",subtype="group",inner=exp}
				end
			end
			return nil, "No parens for group expression"
		end,
		"Access prefix", function()
			local ident = self.tokenStream:next()
			if ident == nil then return nil, "No identifier for access" end
			if ident.type ~= "identifier" then return nil, "Not an identifier for access" end
			return {type="prefix",subtype="identifier",inner = ident.value}
		end
	)

	if not access then return nil, beginReason end

	local reasons = {}

	while true do
		local value, reason = self.tokenStream:scope("prefix chaining",
			"Chain dot access", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="."}) then return nil, "No dot for dot access" end
				local sub = self.tokenStream:next()
				if sub == nil then return end
				---@cast sub Token
				if sub.type == "identifier" then
					return {
						type = "prefix",
						subtype = "dot",
						left = access,
						sub = sub.value,
					}
				end
			end,
			"Chain indexing access", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="["}) then return nil, "No open bracket for index access" end
				local inner = self:parseExpression()
				if inner == nil then return end
				if not self.tokenStream:nextIfEq({type="symbol",value="]"}) then return nil, "No close bracket for index access" end
				return {
					type = "prefix",
					subtype = "index",
					left = access,
					sub = inner,
				}
			end,
			"Chain call", function()
				local call,callReason = self:parseFunctionCall(access)
				if not call then return nil, "Failed to parse call: " .. (callReason or "") end
				return {
					type = "prefix",
					subtype = "call",
					call = call,
				}
			end
		)
		table.insert(reasons, reason)
		if value ~= nil then
			access = value
		else
			break
		end
	end
	return access, table.concat(reasons, "\n\t")
end

---@return Access | nil, string?
function Parser:parseAccess()
	local value, reason = self:parsePrefixExpression()
	if value == nil then return nil, "Failed to parse prefix: " .. (reason or "") end
	if value.subtype == "dot" or value.subtype == "index" or value.subtype == "identifier" then
		return value
	end
	return nil, "Not an Access: " .. util.dump(value, true, true)
end

---@param prefix PrefixExpression
---@return FunctionCall | nil, string?
function Parser:parseFunctionCall(prefix)
	if prefix == nil then return nil, "Call prefix was nil" end
	if prefix.type ~= "prefix" then return nil, debug.traceback("Call prefix was not a prefix",2) end

	local output, lastReason
	while true do
		if self.tokenStream:isDone() then
			lastReason = "No arguments to parse before EOF"
			break
		end
		local name
		if self.tokenStream:nextIfEq({type="symbol",value=":"}) then
			name = self.tokenStream:next() -- todo assert this is identifier
		end

		---@type Expression[] | nil
		local arguments, reason = self.tokenStream:scope("arguments",
			"Parenthetical arguments", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="("}) then
					return nil, "No open paren for parenthetical arguments"
				end

				local args,argsReason = self:parseSequence(self.parseExpression, {type="symbol",value=","})
				if args == nil then return nil, "Failed to parse parenthetical argument sequence: " .. (argsReason or "") end

				if not self.tokenStream:nextIfEq({type="symbol",value=")"}) then
					return nil, "No close paren for parenthetical arguments"
				end

				return args, "Success"
			end,
			"String arguments", function()
				local str = self.tokenStream:next()
				if str == nil then return nil, "No string to be an argument" end
				if str.type ~= "string" then return nil, "Not a string literal" end
				return {{type="string",value=str.value}}
			end,
			"Tabular arguments", function()
				local lit, reason = self:parseTableLiteral()
				if not lit then return nil, "No table literal: " .. (reason or "") end
				return {{type="tableLiteral",value=lit}}
			end
		)

		if arguments == nil then
			lastReason = reason
			break
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
	if output ~= nil then
		return output
	else
		return nil, "(prefix of " .. util.dump(prefix, true) .. ") " .. (lastReason or "<no reason>")
	end
end

end
