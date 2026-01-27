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
		if statement.type == "return" then
			returnStatement = statement
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
			if assign.type ~= "assign" then return nil end

			local values = self:parseSequence(self.parseExpression, {type="symbol",value=","})
			if not values then return nil end

			return {type="assignment",variables=variables,values=values}
		end,

		function() --call
			return (self:parseFunctionCall())
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
				if lastSymbol.value == "elseif" then
					local condition = self:parseExpression()
					if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then return nil end
					local body = self:parseBlock(
						{type="keyword",value="end"},
						{type="keyword",value="elseif"},
						{type="keyword",value="else"}
					)
					table.insert(elseifs, {condition=condition,body=body})
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
				iterVar = name,
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
			local parameters = self:parseSequence(self:generateTokenGrabber("identifier",true),{type="symbol",value=")"})
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
			local returnValue = self:parseExpression()
			return {
				type = "return",
				value = returnValue,
			}
		end,

		function()
			error("statement starting with remaining: " .. util.dump(util.collect(function() return self.tokenStream:next() end)))
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
			if self.tokenStream:isDone() then return nil end
			local token = self.tokenStream:next()
			if token.type == "nilLiteral" then
				return {
					type = "nil",
				}
			end
			return nil, "Not a nil literal"
		end,
		function()
			if self.tokenStream:isDone() then return nil end
			local token = self.tokenStream:next()
			if token.type == "boolLiteral" then
				return {
					type = "bool",
					value = token.value
				}
			end
			return nil, "Not a bool literal"
		end,
		function()
			if self.tokenStream:isDone() then return nil end
			local token = self.tokenStream:next()
			if token.type == "number" then
				return {
					type = "number",
					value = token.value
				}
			end
			return nil, "Not a number literal"
		end,
		function()
			if self.tokenStream:isDone() then return nil end
			local token = self.tokenStream:next()
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
			return self:parsePrefixExpression(true, true)
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
			local operator = self.tokenStream:next()
			local right = children(self)
			if expr == nil or operator == nil or right == nil then return nil end
			expr = {
				type = "binary",
				left = expr,
				operator = operator.value,
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
---@param allowCalls? boolean
---@param allowAccesses? boolean
---@return PrefixExpression | nil
function Parser:parsePrefixExpression(allowCalls, allowAccesses)
	return (self.tokenStream:scope(
		function()
			if allowCalls == false then return nil end
			local call = self:parseFunctionCall()
			if call then
				return {type="prefix",subtype="call",call=call}
			end
		end,
		function()
			if allowAccesses == false then return nil end
			local access = self:parseAccess()
			if access then
				return {type="prefix",subtype="access",key=access}
			end
		end,
		function()
			if self.tokenStream:nextIfEq({type="symbol",value="("}) then
				local exp = self:parseExpression()
				if self.tokenStream:nextIfEq({type="symbol",value=")"}) then
					return {type="prefix",subtype="group",inner=exp}
				end
			end
		end
	))
end

---@return Access | nil
function Parser:parseAccess()
	return (self.tokenStream:scope(
		-- function()
		-- 	local output
		-- 	local ident = self.tokenStream:next()
		-- 	if ident.type == "identifier" then
		-- 		output = {
		-- 			type = "ident",
		-- 			inner = ident,
		-- 		}
		-- 	else return nil end
		-- 	while not self.tokenStream:isDone() do
		-- 		if self.tokenStream:nextIfEq({type="symbol",value="."}) then
		-- 			output = {
		-- 				type = "dot",
		-- 				left = output,
		-- 				sub = self.tokenStream:next()
		-- 			}
		-- 		else
		-- 			break
		-- 		end
		-- 	end
		-- 	return output
		-- end,
		function()
			local pre = self:parsePrefixExpression(false, false)
			if not self.tokenStream:nextIfEq({type="symbol",value="."}) then return nil end
			local sub = self.tokenStream:next()
			if sub.type == "identifier" then
				return {
					type = "dot",
					left = pre,
					sub = sub,
				}
			end
		end,
		function()
			local pre = self:parsePrefixExpression(false, false)
			if not self.tokenStream:nextIfEq({type="symbol",value="["}) then return nil end
			local inner = self:parseExpression()
			if not self.tokenStream:nextIfEq({type="symbol",value="]"}) then return nil end
			return {
				type = "index",
				left = pre,
				sub = inner,
			}
		end,
		function()
			if self.tokenStream:isDone() then return end
			local ident = self.tokenStream:next()
			if ident.type == "identifier" then
				return {
					type = "ident",
					inner = ident,
				}
			end
		end
	))
end

---@return FunctionCall | nil
function Parser:parseFunctionCall()
	local prefix = self:parsePrefixExpression(false)
	if prefix == nil then return nil end

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
				if self.tokenStream:peek().type == "string" then
					return {type="string",value=self.tokenStream:next().value}
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

---@param type string
---@param strip false if true, returns value
---@return fun(self: Parser): Token|nil
---@overload fun(self: Parser, type: string, strip: true): fun(self: Parser): string|number|boolean|nil
function Parser:generateTokenGrabber(type,strip)
	return function(self)
		if self.tokenStream:isDone() then return end
		if self.tokenStream:peek().type == type then
			if strip then
				return self.tokenStream:next().value
			else
				return self.tokenStream:next()
			end
		else
			return nil
		end
	end
end

return Parser
