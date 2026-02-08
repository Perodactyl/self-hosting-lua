local List = require("util.list")
local prettyOutput = require("util.prettyOutput")

---@class Span
local Span = require("source.span")

---@class Error
local Error = { isError = true }

---@type metatable
local errorMt = {
	__index=Error
}

--This is in this file to resolve a dependency loop
---@return Error error, Span self
function Span:error(recoverable, message)
	return Error.new(recoverable, message, self), self
end

function Error.new(recoverable, message, span)
	return setmetatable({
		recoverable = recoverable,
		message = message,
		children = {},
		span = span,
	}, errorMt)
end

---@param message string
---@param span? Span
---@return Error, Span
function Error:extend(message, span)
	return setmetatable({
		recoverable = self.recoverable,
		message = message,
		children = {self},
		span = span and span + self.span or self.span,
	}, errorMt), span and span + self.span or self.span
end

--- Modifies self in place, but returns self for chaining
---@return Error
function Error:unrecoverable()
	self.recoverable = false
	return self
end

---@param message string
---@param errors List<Error> | Error[]
---@return Error, Span
function Error.group(message, errors)
	errors = List(errors)
	if #errors == 0 then error("Expected a list of errors", 2) end
	local span = Span:max(table.unpack(errors:map(function(e) return e.span end)))
	return setmetatable({
		recoverable = errors:reduce(true,function(e,a) return a and e.recoverable end),
		message = message,
		children = errors,
		span = span
	}, errorMt), span
end

---@param color? boolean
function Error:stringify(color)
	if color == nil then color = true end
	local output = ""

	if color then
		output = output .. "\x1b[7m"
		output = output .. self.span:stringify(color)
		output = output .. "\x1b[27m "
	end

	output = output .. (self.message or "<nil message>")

	if #self.children == 1 then
		output = output .. "\n" .. self.children[1]:stringify(color)
	else
		for i,child in ipairs(self.children) do
			output = output .. "\n\t" .. i .. ". " .. prettyOutput.indent(child:stringify(color), 2)
		end
	end
	return output
end

---@generic T
---@param value T|Error
---@return T
---@overload fun(value: T|Error, span: Span): T, Span
function Error.try(value, span)
	if type(value) == "table" and value.isError then
		error(value)
	end
	return value, span
end

return Error
