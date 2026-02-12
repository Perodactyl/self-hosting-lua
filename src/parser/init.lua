local Error = require("source.error")

---@class Parser
---@field tokenStream LazyStream<Token>
local Parser = {}

function Parser.new(source)
	local parser = { tokenStream = source.sourceTokens }
	return setmetatable(parser, {
		__index = Parser,
		__name = "Parser",
	})
end

require("parser.expression")(Parser)
require("parser.statement")(Parser)

function Parser:parseChunk()
	return self:parseBlock()
end

---@generic T, S: Token
---@param memberParser fun(self: Parser): T|Error,Span?
---@param separator S
---@param name? string
---@return Sequence<T, S>|Error,Span
function Parser:parseSequence(memberParser, separator, name)
	if self.tokenStream:isDone() then return self.tokenStream:errorHere(true, "EOF before sequence") end
	self.tokenStream:save()
	local output = {}
	local separators = {}
	while not self.tokenStream:isDone() do

		local parseResult = memberParser(self)

		if parseResult == nil then
			break
		end

		if parseResult.isError then
			self.tokenStream:recall()
			local debugName = "sequence"
			if name then debugName = debugName .. " '" .. name .. "'" end
			local e,s = parseResult:extend("On element " .. #output+1 .. " of " .. debugName)
			e.programInfo = {length=#output}
			return e,s
		end

		table.insert(output, parseResult)

		if not self.tokenStream:eq(separator) then
			break
		end
		table.insert(separators, (self.tokenStream:next() --[[@as Token]]))
	end
	local span = self.tokenStream:continue()
	return {values=output,separators=separators}, span
end

---@return TableLiteral | Error, Span
function Parser:parseTableLiteral()
	local openBrace = self.tokenStream:expect({type="symbol",value="{"},true)
	local closeBrace

	local fields = {}
	local separators = {}
	local span = self.tokenStream:here()
	local i = 0
	while not self.tokenStream:isDone() do
		if self.tokenStream:eq({type="symbol",value="}"}) then
			closeBrace = self.tokenStream:next()
			break
		end

		local field, fieldSpan = self.tokenStream:scope("Table field", {
			{"Identifier", function()
				local key = self.tokenStream:expect({type="identifier"},true) --[[@as IdentifierToken]]
				local assign = self.tokenStream:expect({type="assign",value="="}, true)
				local value = self:parseExpression()
				if value.isError then return value:unrecoverable() end

				return {
					tokens={type="identifier",assign=assign},
					key={type="string",value=key.value},
					value=value
				}
			end},
			{"Expression-keyed", function()
				local openBracket = self.tokenStream:expect({type="symbol",value="["}, true)
				local key = Error.try(self:parseExpression())
				local closeBracket = self.tokenStream:expect({type="symbol",value="]"}, true)
				local assign = self.tokenStream:expect({type="assign",value="="}, true)
				local value = self:parseExpression()
				if value.isError then return value:unrecoverable() end

				return {
					tokens={
						type="expression",
						openBracket=openBracket,
						closeBracket=closeBracket,
						assign=assign
					},
					key=key,
					value=value,
				}
			end},
			{"Auto-keyed", function()
				local value = self:parseExpression()
				if value.isError then return value:unrecoverable() end

				i = i + 1

				return {
					tokens={type="auto"},
					key={type="number",value=i},
					value=value
				}
			end},
		})

		if field.isError then return field --[[@as Error]], fieldSpan end
		table.insert(fields, field)
		span = span + fieldSpan

		local sep = self.tokenStream:next()
		if sep == nil then return self.tokenStream:errorHere(false, "Unterminated table literal") end
		if sep.type == "symbol" and sep.value == "}" then
			closeBrace = sep
			break
		elseif sep.type == "symbol" and (sep.value == ";" or sep.value == ",") then
			table.insert(separators, sep)
		else
			return self.tokenStream:errorHere(false, "No separator between elements")
		end
	end

	return {
		openBrace = openBrace,
		closeBrace = closeBrace,
		fields = { values = fields, separators = separators },
	}, span
end

---@return FuncImpl|Error, Span
function Parser:parseFunctionDefinition()
	local openParen = self.tokenStream:expect({type="symbol",value="("}, true)
	local span = self.tokenStream:here()

	local parameters, parametersSpan = self:parseSequence(function()
		if self.tokenStream:eq({type="symbol",value=")"}) then
			return nil
		end

		local token = self.tokenStream:peek()
		if token == nil then
			return self.tokenStream:errorHere(false, "EOF before parameter")
		elseif token.isError then
			return token
		elseif token.type ~= "identifier" then
			return self.tokenStream:errorNext(false, "Expected parameter to be an identifier")
		else
			self.tokenStream:next()
			return token.value --[[@as string]]
		end
	end, {type="symbol",value=","}, "parameters")

	if parameters.isError then
		return parameters, parametersSpan
	end

	local closeParen = self.tokenStream:expect({type="symbol",value=")"}, false)

	local body, bodySpan = Error.try(self:parseBlock({type="keyword",value="end"}))
	local endToken = self.tokenStream:expect({type="keyword",value="end"}, false)

	return {
		parameters = parameters,
		rest = nil,
		body = body,
		openParen = openParen,
		closeParen = closeParen,
		endToken = endToken,
	}, span + (bodySpan:shr(1))
end

---@param prefix PrefixExpression
---@return FunctionCall | Error, Span
function Parser:parseFunctionCall(prefix)
	local output, span = nil, self.tokenStream:atNext()
	while not self.tokenStream:isDone() do
		local method
		local methodColon = self.tokenStream:nextIfEq({type="symbol",value=":"})
		if methodColon ~= nil then
			method = {
				token = methodColon,
				name = self.tokenStream:expect({type="identifier"}, false, nil, "cause")
			}
		end

		local arguments, argumentSpan = self.tokenStream:scope("arguments", {
			---@return ParenthesisArguments | Error
			{"Parenthetical arguments", function()
				local openParen = self.tokenStream:expect({type="symbol",value="("}, true, nil, "entry")

				local args
				local closeParen = self.tokenStream:nextIfEq({type="symbol",value=")"})
				if not closeParen then
					args = self:parseSequence(self.parseExpression, {type="symbol",value=","})
					closeParen = self.tokenStream:expect({type="symbol",value=")"},false)
				else
					args = {values={},separators={}}
				end

				return {
					type = "parenthesis",
					arguments = args,
					openParen = openParen,
					closeParen = closeParen,
				}
			end},
			{"String arguments", function()
				local str = self.tokenStream:expect({type="string"}, true, nil, "entry")
				return str
			end},
			{"Tabular arguments", function()
				local lit, tblSpan = self:parseTableLiteral()
				if lit.isError then return lit end
				return lit, tblSpan
			end},
		})

		if arguments.isError then
			if arguments.recoverable then
				break
			else
				return arguments, argumentSpan
			end
		end

		output = {
			type = "call",
			method = method,
			callee = output or prefix,
			args = arguments,
		}
	end

	if output == nil then
		return self.tokenStream:errorHere(true, "Not a call"), span
	end
	return output, span
end

return Parser
