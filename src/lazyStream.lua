local Span = require("source.span")
local Error = require("source.error")
local tableUtils = require("util.table")
local prettyOutput = require("util.prettyOutput")

---Temporary fix because LuaLS doesn't understand that class generics should be visible in fields.
---@alias T Token

---@alias Chunkname string

---@generic T
---@class LazyStream<T>
---@field generateNext fun(): T
---@field private buffer T[]
---@field private recallPoints integer[]
---@field index integer
---@field source Source
---@field unit SpanUnit
local LazyStream = {}

---@generic T
---@param generateNext fun(): T
---@param source Source
---@param unit SpanUnit
---@return LazyStream<T>
function LazyStream.new(generateNext, source, unit)
	local stream = {
		generateNext = generateNext,
		buffer = {},
		index = 1,
		source = source,
		unit = unit,
		recallPoints = {},
	}
	return setmetatable(stream, {
		__index = LazyStream
	})
end

---@class StringStream: LazyStream<string>
---@field private buffer string
---@field private recallPoints integer[]
---@field private index integer
local StringStream = setmetatable({}, {__index = LazyStream}) --[[@as StringStream]]

function StringStream:next()
	self.index = self.index + 1
	if self.index - 1 <= #self.buffer then
		return self.buffer:sub(self.index - 1, self.index - 1)
	end
end

function StringStream:peek()
	if self.index <= #self.buffer then
		return self.buffer:sub(self.index, self.index)
	end
end

function StringStream:readN(n)
	local out = ""
	if n == nil then error("n was nil", 2) end
	for _ = 1,n do
		out = out .. (self:next() or "")
	end
	return out
end

---@param value string
---@param recoverable boolean
---@param message? string
function StringStream:expectStr(value,recoverable,message)
	self:save()
	if self:readN(#value) == value then
		self:continue()
		return true
	else
		self:recall()
		error((self:errorNext(recoverable, message or ("Expected '" .. value .. "'"))))
	end
end

function StringStream:skipWhiteSpace()
	while string.match(self:peek() or "", "%s") do self:next() end
end


---@param input string
---@param source Source
---@return StringStream
function LazyStream.fromString(input, source)
	local stream = {
		generateNext = function() return nil end,
		buffer = input,
		index = 1,
		source = source,
		recallPoints = {},
		unit = "char",
	}
	return setmetatable(stream, {
		__index = StringStream
	})
end

local function populateBuffer(self, targetLength)
	if targetLength == nil then targetLength = self.index end
	-- print("Populate: has " .. #self.buffer .. " needs " .. self.index)
	while #self.buffer < targetLength do
		local value = self.generateNext()
		-- print("Populate: appending " .. util.dump(value))
		if value ~= nil and value.isError then
			print(value:stringify())
		elseif value ~= nil then
			table.insert(self.buffer, value)
		else
			return false
		end
	end
	return true
end

function LazyStream:next()
	if not populateBuffer(self) then return nil, "Failed to generate more items of stream" end
	self.index = self.index + 1
	-- print("LazyStream: next = " .. util.dump(self.buffer[self.index - 1]) .. " (index = " .. self.index .. ")")
	return self.buffer[self.index - 1]
end

function LazyStream:peek()
	if not populateBuffer(self) then return nil, "Failed to generate more items of stream" end
	-- print("LazyStream: peek = " .. util.dump(self.buffer[self.index]) .. " (index = " .. self.index .. ")")
	return self.buffer[self.index]
end

function LazyStream:get(index, allowPopulating)
	if allowPopulating and not populateBuffer(self, index) then return nil end
	return self.buffer[index]
end

function LazyStream:eq(value, ...)
	if tableUtils.deepEq(self:peek(), value, "b") then
		return true
	end
	for i = 1, select("#",...) do
		if tableUtils.deepEq(self:peek(), select(i,...), "b") then
			return true
		end
	end
	return false
end

function LazyStream:nextIfEq(value, ...)
	if self:eq(value, ...) then
		self:next()
		return true
	end
	return false
end

---@param value any
---@param recoverable boolean
---@param message? string
function LazyStream:expect(value,recoverable,message)
	if not self:eq(value) then
		error((self:errorNext(recoverable, message or ("Expected " .. prettyOutput.dump(value, false)))))
	end
	return self:next()
end

function LazyStream:isDone()
	return self:peek() == nil
end

function LazyStream:save()
	table.insert(self.recallPoints, self.index)
	-- if self.next == LazyStream.next then print("save " .. util.dump(self.recallPoints)) end
end

---@return Span
function LazyStream:recall()
	-- if self.next == LazyStream.next then print(debug.traceback("recall " .. util.dump(self.recallPoints) .. " returning to " .. self.recallPoints[#self.recallPoints],2)) end
	if #self.recallPoints == 0 then error("Recall not matched to Save", 2) end
	local stop = self.index
	self.index = table.remove(self.recallPoints)
	return Span.new(self.index,stop,self.source,self.unit)
end

---@return Span
function LazyStream:continue()
	-- if self.next == LazyStream.next then print("continue " .. util.dump(self.recallPoints) .. " staying at " .. self.index) end
	if #self.recallPoints == 0 then error("Continue not matched to Save", 2) end
	local start,stop = table.remove(self.recallPoints), self.index
	return Span.new(start,stop,self.source,self.unit)
end

---@return Span
function LazyStream:here()
	return Span.point(self.index-1, self.source, self.unit)
end

---@return Span
function LazyStream:atNext()
	return Span.point(self.index, self.source, self.unit)
end

---@return Error, Span
function LazyStream:errorHere(recoverable, message)
	local e,s = self:here():error(recoverable, message)
	return e,s
end

---@return Error, Span
function LazyStream:errorNext(recoverable, message)
	return self:atNext():error(recoverable, message)
end

---Calls fun within a save/recall block. If fun returns nil, recalls. Otherwise, continues. When passed multiple functions, calls them in order and returns the first non-nil result. Callbacks should not have side effects, otherwise non-cannon syntax trees (trees that are somewhat valid and overlap with the cannon result) might escape.
---Optionally, a scope name may be the first parameter. Optionally, each function can have a parameter before it to name it.
---@generic T
---@param name string
---@param members { [1]:string, [2]:fun():T|Error,Span|nil }[]
---@return T|Error, Span
function LazyStream:scope(name, members)
	local errors = {}
	for _,fun in ipairs(members) do
		self:save()
		local span = self:atNext()
		local success, value, nilErrorMessage = pcall(fun[2])

		if not success then
			if type(value) == "table" and value.isError then
				local propagatedError = value:extend("While parsing '" .. fun[1] .. "' branch of '" .. name .. "'", span)
				if value.recoverable then
					table.insert(errors, propagatedError)
				else
					return propagatedError, span
				end
			else
				error("'"..fun[1].."' branch of " .. name .. ": " .. value, 0)
			end
		end

		if value == nil then
			error(name .. ":" .. fun[1] .. " returned nil: " .. tostring(nilErrorMessage), 2)
		end

		if type(value) == "table" and value.isError then
			span = span + self:atNext()
			self:recall()
			local propagatedError = value:extend("While parsing '" .. fun[1] .. "' branch of '" .. name .. "'", span)

			if value.recoverable then
				table.insert(errors, propagatedError)
			else
				return propagatedError, span
			end
		else
			span = span + self:here()
			self:continue()
			return value, span
		end
	end

	return Error.group("Expected " .. name, errors)
end

return LazyStream
