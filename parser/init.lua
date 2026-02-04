local LazyStream = require("lazyStream")

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

---@generic T
---@param memberParser fun(self: Parser): T|Error,Span?
---@param separator Token
---@param name? string
---@return T[]|Error,Span
function Parser:parseSequence(memberParser, separator, name)
	if self.tokenStream:isDone() then return self.tokenStream:errorHere(true, "EOF before sequence") end
	self.tokenStream:save()
	local output = {}
	while not self.tokenStream:isDone() do

		local parseResult = memberParser(self)

		if parseResult == nil then
			break
		end

		if parseResult.isError then
			self.tokenStream:recall()
			local debugName = "sequence"
			if name then debugName = debugName .. " '" .. name .. "'" end
			return parseResult:extend("On element " .. #output+1 .. " of " .. debugName)
		end

		table.insert(output, parseResult)

		if not self.tokenStream:nextIfEq(separator) then
			break
		end
	end
	local span = self.tokenStream:continue()
	return output, span
end

---@return TableLiteral | Error, Span
function Parser:parseTableLiteral()
	self.tokenStream:expect({type="symbol",value="{"},true)

	local fields = {}
	local span = self.tokenStream:here()
	local i = 0
	while not self.tokenStream:isDone() do
		if self.tokenStream:nextIfEq({type="symbol",value="}"}) then
			break
		end

		local field, fieldSpan = self.tokenStream:scope("Table field", {
			{"Identifier", function()
				local key = self.tokenStream:next()
				if not key then return self.tokenStream:errorHere(true, "No key") end
				if key.type ~= "identifier" then
					return self.tokenStream:errorHere(true, "Key not an identifier")
				end

				if not self.tokenStream:nextIfEq({type="assign",value="="}) then
					return self.tokenStream:errorHere(true, "No equal after key")
				end

				local value = self:parseExpression()
				if value.isError then return value:unrecoverable() end

				return {key={type="string",value=key.value}, value=value}
			end},
			{"Expression-keyed", function()
				if not self.tokenStream:nextIfEq({type="symbol",value="["}) then
					return self.tokenStream:errorHere(true, "No open-bracket")
				end

				local key = self:parseExpression()
				if key.isError then return key:unrecoverable() end

				if not self.tokenStream:nextIfEq({type="symbol",value="]"}) then
					return self.tokenStream:errorHere(true, "No close-bracket"):unrecoverable()
				end

				if not self.tokenStream:nextIfEq({type="assign",value="="}) then
					return self.tokenStream:errorHere(true, "No equal after key"):unrecoverable()
				end

				local value = self:parseExpression()
				if value.isError then return value:unrecoverable() end

				return {key=key, value=value}
			end},
			{"Auto-keyed", function()
				local value = self:parseExpression()
				if value.isError then return value:unrecoverable() end

				i = i + 1

				return {key={type="number",value=i},value=value}
			end},
		})

		if field.isError then return field, fieldSpan end
		table.insert(fields, field)
		span = span + fieldSpan

		local sep = self.tokenStream:next()
		if sep == nil then return self.tokenStream:errorHere(false, "Unterminated table literal") end
		if sep.type == "symbol" and sep.value == "}" then
			break
		elseif sep.type == "symbol" and (sep.value == ";" or sep.value == ",") then
			-- 
		else
			return self.tokenStream:errorHere(false, "No separator between elements")
		end
	end

	return fields, span
end

---@return FuncImpl|Error, Span
function Parser:parseFunctionDefinition()
	if not self.tokenStream:nextIfEq({type="symbol",value="("}) then
		return self.tokenStream:errorHere(true, "No open paren after name")
	end
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
	-- TODO rest parameter

	if not self.tokenStream:nextIfEq({type="symbol",value=")"}) then
		return self.tokenStream:errorHere(false, "No close paren after params")
	end

	local body, bodySpan = self:parseBlock({type="keyword",value="end"})
	if body.isError then return body, bodySpan end
	self.tokenStream:next() -- skip end kw

	return {
		parameters = parameters,
		rest = false,
		body = body,
	}, span + (bodySpan >> 1)
end

return Parser
