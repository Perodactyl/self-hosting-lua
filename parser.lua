
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
	return self:parseBlock(nil)
end

---@param lastToken Token | nil never ends if nil
---@param ... Token alternative valid last tokens
---@return Block | nil, string?
function Parser:parseBlock(lastToken, ...)
	local statements = {}
	local returnStatement = nil

	while not self.tokenStream:isDone() and not self.tokenStream:eq(lastToken, ...) do
		local statement, errorReason = self:parseStatement()
		if statement == nil then
			return nil, "Statement " .. (#statements + 1) .. " (starting at token " .. self.tokenStream.index .. ") returned nil: " .. (errorReason or "")
		end
		-- print("Parsed " .. util.dump(statement, true, true))
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

---@return Statement | ReturnStatement | nil, string?
function Parser:parseStatement()
	local a,b = self.tokenStream:scope("statement",
		"Assignment statement", function() -- assignment
			local localKw = self.tokenStream:nextIfEq({type="keyword",value="local"})
			if self.tokenStream:peek().type ~= "identifier" then return nil, "No identifiers to begin assignment" end

			local variables, variablesReason = self:parseSequence(self.parseAccess, {type="symbol",value=","})
			-- local variables = {self:parseAccess()}
			if not variables then return nil, "No variable sequence: " .. (variablesReason or "") end

			local assign = self.tokenStream:next()
			if assign == nil then return nil, "No assignment operator" end
			if assign.type ~= "assign" then return nil, "Assignment operator was not of type assign" end
			if localKw and assign.value ~= "=" then
				error("Local definitions only allow assignment with =")
			end

			local values, valuesReason = self:parseSequence(self.parseExpression, {type="symbol",value=","})
			if not values then return nil, "No values sequence: " .. (valuesReason or "") end

			if localKw then
				return {type="localAssignment",variables=variables,values=values}
			else
				return {type="assignment",variables=variables,values=values}
			end
		end,

		"Call statement", function() --call
			local callee, calleeReason = self:parsePrefixExpression()
			if callee == nil then return nil, "No callee: " .. (calleeReason or nil) end
			if callee.subtype == "call" then return callee.call, "PrefixExpression was a call" end
			return nil, "Prefix was not of type call"
		end,

		"Do block statement", function() -- do block
			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil, "No do kw" end
			local body, bodyReason = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil, "Do block parsing failed: " .. (bodyReason or "") end
			self.tokenStream:next() -- end
			return {
				type = "do",
				body = body,
			}
		end,

		"If statement", function() --if
			if not self.tokenStream:nextIfEq({type="keyword",value="if"}) then return nil, "No if kw" end
			local condition, conditionReason = self:parseExpression()
			if not condition then return nil, "Failed to parse condition: " .. (conditionReason or "") end
			if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then return nil, "No then kw" end

			local body, bodyReason = self:parseBlock(
				{type="keyword",value="end"},
				{type="keyword",value="elseif"},
				{type="keyword",value="else"}
			)
			if not body then return nil, "Failed to parse if body: " .. (bodyReason or "") end

			local elseifs = {}
			local elseBody

			while true do
				local lastSymbol = self.tokenStream:next()
				if lastSymbol == nil then break end

				if lastSymbol.value == "elseif" then
					local elseifCondition = self:parseExpression()
					if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then return nil, "Elseif clause missing then kw" end
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

		"Numeric for loop statement", function() -- numeric for loop
			if not self.tokenStream:nextIfEq({type="keyword",value="for"}) then return nil, "No for kw" end

			local name = self.tokenStream:next()
			if name == nil then return nil, "Missing variable name" end
			if name.type ~= "identifier" then return nil, "Variable name is not an identifier" end

			if not self.tokenStream:nextIfEq({type="assign",value="="}) then return nil, "Missing = in for" end
			local min = self:parseExpression()
			if not self.tokenStream:nextIfEq({type="symbol",value=","}) then return nil, "Missing max in for" end
			local max = self:parseExpression()
			local step
			if self.tokenStream:nextIfEq({type="symbol",value=","}) then
				step = self:parseExpression()
			end

			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil, "No do kw" end
			local body, bodyReason = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil, "Failed to parse for body: " .. (bodyReason or "") end
			self.tokenStream:next()

			return {
				type = "forRange",
				iterVar = name.value,
				min = min,
				max = max,
				step = step,
				body = body,
			}
		end,

		"Iterator for loop statement", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="for"}) then return nil, "No for kw" end
			local variables, variablesReason = self:parseSequence(function()
				local name = self.tokenStream:next()
				if name == nil then return nil, "Missing variable name" end
				if name.type ~= "identifier" then return nil, "Variable name is not an identifier" end
				return name.value
			end, {type="symbol",value=","})

			if not variables then return nil, variablesReason end

			if not self.tokenStream:nextIfEq({type="keyword",value="in"}) then return nil, "No in kw" end

			local iterator, iteratorReason = self:parseExpression()
			if not iterator then return nil, "Faield to parse iterator: " .. (iteratorReason or "") end


			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil, "No do kw" end
			local body, bodyReason = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil, "Failed to parse for body: " .. (bodyReason or "") end
			self.tokenStream:next()

			return {
				type = "forIn",
				variables = variables,
				expressions = {iterator},
				body = body,
			}
		end,

		"While loop statement", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="while"}) then return nil, "No while kw" end
			local condition = self:parseExpression()

			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil, "No do kw" end
			local body, bodyReason = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil, "Failed to parse while body: " .. (bodyReason or "") end
			self.tokenStream:next()

			return {
				type = "while",
				condition = condition,
				body = body,
			}
		end,

		"Repeat until statement", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="repeat"}) then return nil, "No while kw" end
			local body, bodyReason = self:parseBlock({type="keyword",value="until"})
			if body == nil then return nil, "Failed to parse repeat-until body: " .. (bodyReason or "") end
			self.tokenStream:next()

			local condition, conditionReason = self:parseExpression()
			if not condition then return nil, "Failed to parse repeat-until condition: " .. (conditionReason or "") end

			return {
				type = "repeatUntil",
				body = body,
				condition = condition,
			}
		end,

		---@return FuncDef | LocalFuncDef | nil, string?
		"Function definition statement", function() -- function definition
			local localKw = self.tokenStream:nextIfEq({type="keyword",value="local"})
			if not self.tokenStream:nextIfEq({type="keyword",value="function"}) then return nil, "No function kw" end

			local name
			if not localKw then
				name = {
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
			else
				local ident = self.tokenStream:next()
				if ident == nil then return nil, "No local fn name" end
				if ident.type ~= "identifier" then return nil, "Local fn name not an identifier" end
				name = ident.value
			end

			local impl, implReason = self:parseFunctionDefinition()
			if impl == nil then return nil, "No function impl: " .. (implReason or "") end

			return {
				type = localKw and "localFuncDef" or "funcDef",
				name = name,
				impl = impl,
			}
		end,
		"Return statement", function() --return
			if not self.tokenStream:nextIfEq({type="keyword",value="return"}) then return nil, "No return kw" end
			local returnValues = self:parseExpression()
			return {
				type = "return",
				values = {returnValues},
			}
		end,
		"Label definition statement", function()
			if not self.tokenStream:nextIfEq({type="symbol",value="::"}) then return nil, "No start double colon" end
			local name = self.tokenStream:next()
			if name == nil then return nil, "No label name" end
			if name.type ~= "identifier" then return nil, "Label name is not an identifier" end
			if not self.tokenStream:nextIfEq({type="symbol",value="::"}) then return nil, "No end double colon" end

			return {
				type = "label",
				name = name.value,
			}
		end,
		"Goto statement", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="goto"}) then return nil, "No goto kw" end

			local name = self.tokenStream:next()
			if name == nil then return nil, "No label name" end
			if name.type ~= "identifier" then return nil, "Label name is not an identifier" end

			return {
				type = "goto",
				destination = name.value,
			}
		end
	)
	return a,b --Prevents TCO, making traceback more informative
end

---@return FuncImpl?, string?
function Parser:parseFunctionDefinition()
	if not self.tokenStream:nextIfEq({type="symbol",value="("}) then return nil, "No open paren after name" end
	local parameters, parametersReason = self:parseSequence(function()
		local token = self.tokenStream:peek()
		if token ~= nil and token.type == "identifier" then
			self.tokenStream:next()
			return token.value --[[@as string]]
		end
		return nil
	end, {type="symbol",value=","})
	-- TODO rest parameter

	if parameters == nil then return nil, "No parameters: " .. (parametersReason or "") end

	if not self.tokenStream:nextIfEq({type="symbol",value=")"}) then return nil, "No close paren after params" end

	local body, bodyReason = self:parseBlock({type="keyword",value="end"})
	if body == nil then return nil, "No body: " .. (bodyReason or "") end
	self.tokenStream:next() -- skip end kw

	return {
		parameters = parameters,
		rest = false,
		body = body,
	}
end

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
	if output ~= nil then
		return output
	else
		return nil, "(prefix of " .. util.dump(prefix, true) .. ") " .. (lastReason or "<no reason>")
	end
end

function Parser:parseTableLiteral()
	if not self.tokenStream:nextIfEq({type="symbol",value="{"}) then return nil, "Missing open brace to start table literal" end

	local fields = {}
	local i = 0
	while not self.tokenStream:isDone() do
		if self.tokenStream:nextIfEq({type="symbol",value="}"}) then
			break
		end

		local field, reason = self.tokenStream:scope("Table field",
			"Identifier field", function()
				local key = self.tokenStream:next()
				if not key then return nil, "No key" end
				if key.type ~= "identifier" then return nil, "Key not an identifier" end

				if not self.tokenStream:nextIfEq({type="assign",value="="}) then return nil, "No equal after key" end

				local value, valueReason = self:parseExpression()
				if not value then return nil, "Failed to parse value: " .. (valueReason or "") end

				return {key={type="string",value=key.value}, value=value}
			end,
			"Expression-keyed field", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="["}) then return nil, "No open-bracket to start key" end
				local key, keyReason = self:parseExpression()
				if not key then return nil, "No key: " .. (keyReason or "") end

				if not self.tokenStream:nextIfEq({type="symbol",value="]"}) then return nil, "No close-bracket to end key" end
				if not self.tokenStream:nextIfEq({type="assign",value="="}) then return nil, "No equal after key" end

				local value, valueReason = self:parseExpression()
				if not value then return nil, "Failed to parse value: " .. (valueReason or "") end

				return {key=key, value=value}
			end,
			"Auto-keyed field", function()
				local value, valueReason = self:parseExpression()
				if not value then return nil, "Failed to parse value: " .. (valueReason or "") end

				i = i + 1

				return {key={type="number",value=i},value=value}
			end
		)
		if not field then return nil, reason end
		table.insert(fields, field)

		local sep = self.tokenStream:next()
		if sep == nil then return nil, "Missing close brace to end table literal" end
		if sep.type == "symbol" and sep.value == "}" then
			break
		elseif sep.type == "symbol" and (sep.value == ";" or sep.value == ",") then
			-- 
		else
			return nil, "No separator between elements: " .. util.dump(sep, true)
		end
	end

	return fields
end

---@generic T
---@param memberParser fun(self: Parser): T|nil, string?
---@param separator Token
---@return T[]|nil, string?
function Parser:parseSequence(memberParser, separator)
	if self.tokenStream:isDone() then return nil, "Cannot parse sequence: EOF" end
	local output = {}
	local info = "Sequence"
	while not self.tokenStream:isDone() do
		local parseResult, parseReason = memberParser(self)
		if parseResult == nil then
			info = info .. "\n" .. (#output+1) .. ". " .. (parseReason or "Error")
			break
		else
			info = info .. "\n" .. (#output+1) .. ". Success"
		end
		table.insert(output, parseResult)
		if not self.tokenStream:nextIfEq(separator) then
			info = info .. "\n" .. (#output+1) .. ". No separator (not attempting to parse)"
			break
		end
	end
	-- if #output == 0 then return nil, "Sequence of no elements\n" .. info end
	return output
end

return Parser
