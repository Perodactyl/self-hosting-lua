local LazyStream = require("lazyStream")
local util = require("util")

---@class Parser
---@field tokenStream LazyStream<Token>
local Parser = {}

function Parser.new(tokenGenerator)
	local parser = { tokenStream = LazyStream.new(tokenGenerator) }
	return setmetatable(parser, {
		__index = Parser,
		__name = "Parser",
	})
end

function Parser:parseChunk()
	return (self:parseBlock(nil))
end

---@param lastToken Token | nil never ends if nil
---@param ... Token alternative valid last tokens
---@return Block
function Parser:parseBlock(lastToken, ...)
	local statements = {}
	local returnStatement = nil

	while not self.tokenStream:isDone() and not self.tokenStream:eq(lastToken, ...) do
		local statement = self:parseStatement()
		print("Parsed " .. util.dump(statement, true, true))
		-- print(util.dumpJSON(statement))
		if statement == nil then break end
		if statement.type == "return" then
			returnStatement = statement.values
		elseif returnStatement ~= nil then
			error("Return before end of block")
		else
			table.insert(statements, statement)
		end
	end

	return {
		type = "block",
		statements = statements,
		returnStatement = returnStatement,
	}
end

---@return Statement | ReturnStatement | nil
function Parser:parseStatement()
	return (self.tokenStream:scope(
		function() -- assignment
			if self.tokenStream:peek().type ~= "identifier" then return nil end

			local variables = self:parseSequence(self.parseAccess, {type="symbol",value=","})
			if not variables then return nil end

			local assign = self.tokenStream:next()
			if assign == nil then return end
			if assign.type ~= "assign" then return nil end

			local values = self:parseSequence(self.parseExpression, {type="symbol",value=","})
			if not values then return nil end

			return {type="assignment",variables=variables,values=values}
		end,

		function() --call
			local callee = self:parsePrefixExpression()
			if callee == nil then return end
			return (self:parseFunctionCall(callee))
		end,

		function() -- do block
			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil end
			local body = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil end
			return {
				type = "do",
				body = body,
			}
		end,

		---@return If | nil
		function() --if
			if not self.tokenStream:nextIfEq({type="keyword",value="if"}) then return nil end
			local condition = self:parseExpression()
			if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then return nil end
			local body = self:parseBlock(
				{type="keyword",value="end"},
				{type="keyword",value="elseif"},
				{type="keyword",value="else"}
			)
			local elseifs = {}
			local elseBody

			while true do
				local lastSymbol = self.tokenStream:next()
				if lastSymbol == nil then break end

				if lastSymbol.value == "elseif" then
					local elseifCondition = self:parseExpression()
					if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then return nil end
					local elseifBody = self:parseBlock(
						{type="keyword",value="end"},
						{type="keyword",value="elseif"},
						{type="keyword",value="else"}
					)
					table.insert(elseifs, {condition=elseifCondition,body=elseifBody})
				elseif lastSymbol.value == "else" then
					elseBody = self:parseBlock({type="keyword",value="end"})
					self.tokenStream:next() -- skip end kw
					break
				elseif lastSymbol.value == "end" then
					break
				end
			end

			return {
				type = "if",
				condition = condition,
				body = body,
				elseifs = elseifs,
				elseBody = elseBody,
			}
		end,

		function() -- numeric for loop
			if not self.tokenStream:nextIfEq({type="keyword",value="for"}) then return nil end

			local name = self.tokenStream:next()
			if name == nil then return nil end
			if name.type ~= "identifier" then return nil end

			if not self.tokenStream:nextIfEq({type="assign",value="="}) then return nil end
			local min = self:parseExpression()
			if not self.tokenStream:nextIfEq({type="symbol",value=","}) then return nil end
			local max = self:parseExpression()
			local step
			if self.tokenStream:nextIfEq({type="symbol",value=","}) then
				step = self:parseExpression()
			end

			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil end
			local body = self:parseBlock({type="keyword",value="end"})
			self.tokenStream:next()
			if body == nil then return nil end

			return {
				type = "forRange",
				iterVar = name.value,
				min = min,
				max = max,
				step = step,
				body = body,
			}
		end,

		---@return FuncDef | nil
		function() -- function definition
			if not self.tokenStream:nextIfEq({type="keyword",value="function"}) then return nil end
			local name = {
				base = self.tokenStream:next().value,
				accesses = {},
				method = nil,
			}
			while not self.tokenStream:isDone() do
				if self.tokenStream:nextIfEq({type="symbol",value="."}) then
					table.insert(name.accesses, self.tokenStream:next().value)
				elseif self.tokenStream:nextIfEq({type="symbol",value=":"}) then
					name.method = self.tokenStream:next().value
					break
				elseif self.tokenStream:eq({type="symbol",value="("}) then
					break
				end
			end

			if not self.tokenStream:nextIfEq({type="symbol",value="("}) then return nil end
			local parameters = self:parseSequence(function()
				local token = self.tokenStream:peek()
				if token ~= nil and token.type == "identifier" then
					self.tokenStream:next()
					return token.value --[[@as string]]
				end
				return nil
			end, {type="symbol",value=")"})
			-- TODO rest parameter

			-- if not self.tokenStream:nextIfEq({type="symbol",value=")"}) then return nil end

			local body = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil end
			self.tokenStream:next() -- skip end kw
			return {
				type = "funcDef",
				name = name,
				parameters = parameters,
				rest = false,
				body = body,
			}
		end,
		function() --return
			if not self.tokenStream:nextIfEq({type="keyword",value="return"}) then return nil end
			local returnValues = self:parseExpression()
			return {
				type = "return",
				values = {returnValues},
			}
		end,

		function()
			util.table(util.collect(
				function() return self.tokenStream:next() end,
				15,
				{type="...",value="..."}
			), {"type","value"}, util.tokenListFormatter)
			error("Unhandled statement from above token list")
		end
	))
end

---@return Expression | nil
function Parser:parseExpression()
	return (self:parseEquality())
end

---@return NilLiteralExpression | BoolLiteralExpression | NumLiteralExpression | StringLiteralExpression | TableLiteralExpression | VarArgExpression | FunctionExpression | PrefixExpression | nil, string?
function Parser:parsePrimary()
	return self.tokenStream:scope(
		function()
			local token = self.tokenStream:next()
			if token == nil then return nil end
			if token.type == "nilLiteral" then
				return {
					type = "nil",
				}
			end
			return nil, "Not a nil literal"
		end,
		function()
			local token = self.tokenStream:next()
			if token == nil then return nil end
			if token.type == "boolLiteral" then
				return {
					type = "bool",
					value = token.value
				}
			end
			return nil, "Not a bool literal"
		end,
		function()
			local token = self.tokenStream:next()
			if token == nil then return nil end
			if token.type == "number" then
				return {
					type = "number",
					value = token.value
				}
			end
			return nil, "Not a number literal"
		end,
		function()
			local token = self.tokenStream:next()
			if token == nil then return nil end
			if token.type == "string" then
				return {
					type = "string",
					value = token.value
				}
			end
			return nil, "Not a string literal"
		end,
		function() -- TODO table literal
			return nil, "Table Literals not implemented"
		end,
		function() -- TODO vararg
			return nil, "Rest Parameters not implemented"
		end,
		function() -- TODO function expression
			return nil, "Function Expressions not implemented"
		end,
		function()
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
		local right = self:parseUnary()
		return {
			type = "unary",
			operator = operator,
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
		local expr = children(self)

		while self.tokenStream:eq(table.unpack(operators)) do
			local operator = self.tokenStream:next() --[[@as Token]]
			local right = children(self)
			if expr == nil or operator == nil or right == nil then return nil end
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
	}
)
Parser.parseEquality = generatePrecedenceFunc(
	Parser.parseComparison,
	{
		{type="operator",value="=="},
		{type="operator",value="~="},
	}
)
---@return PrefixExpression | nil
function Parser:parsePrefixExpression()
	return (self.tokenStream:scope(
		function()
			if self.tokenStream:nextIfEq({type="symbol",value="("}) then
				local exp = self:parseExpression()
				if self.tokenStream:nextIfEq({type="symbol",value=")"}) then
					return {type="prefix",subtype="group",inner=exp}
				end
			end
		end,
		function()
			local ident = self.tokenStream:next()
			if ident == nil then return end
			---@cast ident Token
			if ident.type ~= "identifier" then return end

			local access = {
				type = "prefix",
				subtype = "identifier",
				inner = ident.value --[[@as string]],
			}

			while true do
				local value = self.tokenStream:scope(
					function()
						if not self.tokenStream:nextIfEq({type="symbol",value="."}) then return nil end
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
					function()
						if not self.tokenStream:nextIfEq({type="symbol",value="["}) then return nil end
						local inner = self:parseExpression()
						if inner == nil then return end
						if not self.tokenStream:nextIfEq({type="symbol",value="]"}) then return nil end
						return {
							type = "prefix",
							subtype = "index",
							left = access,
							sub = inner,
						}
					end,
					function()
						return self:parseFunctionCall(access)
					end
				)
				if value ~= nil then
					access = value
				else
					break
				end
			end
			return access
		end
	))
end

---@return Access | nil, string?
function Parser:parseAccess()
	local value, reason = self:parsePrefixExpression()
	if value == nil then return nil, "Failed to parse prefix: " .. (reason or "<unknown>") end
	if value.subtype == "dot" or value.subtype == "index" or value.subtype == "identifier" then
		return value
	end
	return nil, "Value was of subtype " .. value.subtype
end

---@param prefix PrefixExpression
---@return FunctionCall | nil
function Parser:parseFunctionCall(prefix)
	local output
	while not self.tokenStream:isDone() do
		local name
		if self.tokenStream:nextIfEq({type="symbol",value=":"}) then
			name = self.tokenStream:next() -- todo assert this is identifier
		end

		---@type Arguments | nil
		local arguments = self.tokenStream:scope(
			function()
				if self.tokenStream:nextIfEq({type="symbol",value="("}) then
					local args = self:parseSequence(self.parseExpression, {type="symbol",value=","})
					if self.tokenStream:nextIfEq({type="symbol",value=")"}) then
						return {type="parenthesis",arguments=args}
					end
				end
				return nil
			end,
			function()
				if (self.tokenStream:peek() --[[@as Token]]).type == "string" then
					return {type="string",value=self.tokenStream:next().value --[[@as string]]}
				end
				return nil
			end,
			function()
				return (self:parseTableLiteral())
			end
		)
		if arguments == nil then break end
		if name then
			output = {
				type = "callMethod",
				method = name,
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
	return output
end

function Parser:parseTableLiteral()
	return nil
end

---@generic T
---@param memberParser fun(self: Parser): T
---@param separator Token
---@return T[]|nil
function Parser:parseSequence(memberParser, separator)
	if self.tokenStream:isDone() then return end
	local output = {}
	while not self.tokenStream:isDone() do
		local parseResult = memberParser(self)
		if parseResult == nil then break end
		table.insert(output, parseResult)
		if not self.tokenStream:nextIfEq(separator) then break end
	end
	if #output == 0 then return nil end
	return output
end

return Parser
