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
		type = "normal",
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

---Modifies self in place, but returns self for chaining
---@return Error, Span
function Error:unrecoverable()
	self.recoverable = false
	return self, self.span
end

---Modifies self in place, but returns self for chaining
---@param type "normal" | "quantifier" | "cause" | "entry" | nil
---@return Error, Span
function Error:ofType(type)
	if type ~= nil then
		self.type = type
	end
	return self, self.span
end

---Errors are like onions. This function unwraps the layers of an error to find the root cause.
---@return Error
function Error:findCause()
	-- return self
	if self.type == "cause" or not self.recoverable then
		return self
	elseif #self.children == 0 then
		return self
	elseif #self.children == 1 then
		return self.children[1]:findCause()
	else
		local causes = {}
		for _,child in ipairs(self.children) do
			local c = child:findCause()
			if c.type ~= "entry" then
				table.insert(causes, c)
			elseif c.type == "cause" then
				return c
			end
		end
		if #causes == 0 then
			causes = self.children
		end
		if #causes == 1 then
			return causes[1]:extend(self.message, self.span):ofType(self.type):findCause()
		end
		local group = Error.group(self.message, causes)
		return group
	end
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
