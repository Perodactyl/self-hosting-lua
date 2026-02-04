local util = require("util")

---@class Error
---@field recoverable boolean If true, parser will continue to try and parse other branches.
---@field message string
---@field children Error[] Child is a lower-level error.
---@field span Span
---@field programInfo? table
local Error = { isError = true }

---@alias SpanUnit "char" | "token"

---@class Span
---@field start integer
---@field stop integer
---@field source Source
---@field unit SpanUnit
local Span = {}

---@type metatable
local spanMt = {
	__index = Span,
	__eq=function(a,b)
		if type(b) == "nil" then
			print(debug.traceback("Warning: compared an Error against nil", 2))
			return true
		end
		if a.source ~= b.source then return false end
		if a.start ~= b.start then return false end
		if a.stop ~= b.stop then return false end
		return true
	end,
	__add=function(a,b) return a:join(b) end,
	__concat=function(a,b) return a:join(b) end,
	__bor=function(a,b) return a:join(b) end,
	__shl=function(self, dist)
		return Span.new(self.start - dist, self.stop - dist, self.source, self.unit)
	end,
	__shr=function(self, dist)
		return Span.new(self.start + dist, self.stop + dist, self.source, self.unit)
	end,
	__band=function(a, b) return a:min(b) end,
}

---@param start integer
---@param stop integer
---@param source Source
---@param unit SpanUnit
---@return Span
function Span.new(start,stop,source,unit)
	if start == 0 then
		-- print(debug.traceback("Span at 0 created",2))
		error("Span at 0", 2)
	end
	return setmetatable({start=start,stop=stop,source=source,unit=unit}, spanMt)
end

---@param point integer
---@param source Source
---@param unit SpanUnit
---@return Span
function Span.point(point,source,unit)
	return Span.new(point,point,source,unit)
end

---Creates a span that fully encloses this span and the other span.
---@param other Span
function Span:join(other)
	if self.source ~= other.source then error("Other span has a different source", 2) end
	return Span.new(
		math.min(self.start, other.start),
		math.max(self.stop, other.stop),
		self.source, self.unit
	)
end

---@param ... Span
---@return Span
function Span:min(...)
	if select("#",...) == 0 then error("Expected a list of spans", 2) end

	return util.reduce({...}, {start=-math.huge,stop=math.huge,source=select(1,...).source}, function(value,accum)
		accum.start = math.max(accum.start, value.start)
		accum.stop  = math.min(accum.stop,  value.stop )
		return accum
	end)
end

---@param ... Span
---@return Span
function Span:max(...)
	if select("#",...) == 0 then error("Expected a list of spans", 2) end
	return util.reduce({...}, select(1,...), function(value,accum)
		return value:join(accum)
	end)
end

---Cast a Span in tokens to a span in chars
---@return Span
function Span:cast()
	if self.unit == "char" then return self end
	local start = self.source.sourceTokens:get(self.start, false)
	local stop  = self.source.sourceTokens:get(self.stop,  false)
	-- print(util.dump(self,true,true))

	local startRef, stopRef
	if start then
		startRef = start.span
	else
		error("Span starts at token " .. self.start .. ", which is not generated yet", 2)
	end

	if stop then
		stopRef  = stop.span
	else
		-- error("Span stops at token " .. self.stop .. ", which is not generated yet", 2)
		print(debug.traceback("Span stops at token " .. self.stop .. ", which is not generated yet", 2))
		return Span.point(1, self.source, "char")
	end

	if startRef.source ~= stopRef.source then error("Reference spans come from different sources", 2) end
	return Span.new(
		startRef.start,
		stopRef.stop,
		startRef.source,
		"char"
	)
end

---@return Error error, Span self
function Span:error(recoverable, message)
	return Error.new(recoverable, message, self), self
end

---@return string
function Span:lookup()
	return self.source:lookup(self.start, self.stop)
end

---@return string
function Span:stringify(color)
	if self.unit == "token" then
		self = self:cast()
	end
	-- print(util.dump(self, color))
	-- os.exit()

	local name = util.formatIdentifier(self.source:displayName(), color)

	local rangeText = self.start .. "-" .. self.stop
	if self.start == self.stop then rangeText = tostring(self.start) end
	local range = util.formatLiteral(rangeText, color)

	local preview = self:lookup()

	return name .. "(" .. range .. "):" .. preview
end

---@type metatable
local errorMt = {
	__index=Error
}

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
---@param errors Error[]
---@return Error, Span
function Error.group(message, errors)
	if #errors == 0 then error("Expected a list of errors", 2) end
	local span = Span:max(table.unpack(util.map(errors, function(e) return e.span end)))
	return setmetatable({
		recoverable = util.reduce(errors,true,function(e,a) return a and e.recoverable end),
		message = message,
		children = errors,
		span = span
	}, errorMt), span
end

function Error:stringify()
	local output = "\x1b[7m" .. self.span:stringify(true) .. "\x1b[27m " .. self.message
	if #self.children == 1 then
		output = output .. "\n" .. self.children[1]:stringify()
	else
		for i,child in ipairs(self.children) do
			output = output .. "\n\t" .. i .. ". " .. util.indent(child:stringify(), 2)
		end
	end
	return output
end

return {Error=Error, Span=Span}
