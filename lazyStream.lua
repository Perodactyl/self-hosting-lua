local util = require("util")

---@generic T
---@class LazyStream<T>
---@field generateNext fun(): T
---@field private buffer T[]
---@field private recallPoints integer[]
---@field private index integer
local LazyStream = {}

---@generic T
---@param generateNext fun(): T
---@return LazyStream<T>
function LazyStream.new(generateNext)
	local stream = {
		generateNext = generateNext,
		buffer = {},
		index = 1,
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
local StringStream = setmetatable({}, {__index = LazyStream})

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

function LazyStream.fromString(input)
	local stream = {
		generateNext = function() return nil end,
		buffer = input,
		index = 1,
		recallPoints = {},
	}
	return setmetatable(stream, {
		__index = StringStream
	})
end

local function populateBuffer(self)
	-- print("Populate: has " .. #self.buffer .. " needs " .. self.index)
	while self.index > #self.buffer do
		local value = self.generateNext()
		-- print("Populate: appending " .. util.dump(value))
		if value ~= nil then
			table.insert(self.buffer, value)
		else
			return false
		end
	end
	return true
end

function LazyStream:next()
	if not populateBuffer(self) then return nil end
	self.index = self.index + 1
	-- print("LazyStream: next = " .. util.dump(self.buffer[self.index - 1]))
	return self.buffer[self.index - 1]
end

function LazyStream:peek()
	if not populateBuffer(self) then return nil end
	-- print("LazyStream: peek = " .. util.dump(self.buffer[self.index]))
	return self.buffer[self.index]
end

function LazyStream:eq(value, ...)
	if util.deepEq(self:peek(), value) then
		return true
	end
	for i = 1, select("#",...) do
		if util.deepEq(self:peek(), select(i,...)) then
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

function LazyStream:isDone()
	return self:peek() == nil
end

function LazyStream:save()
	-- print("save " .. util.dump(self.recallPoints) .. debug.traceback(nil, 2))
	table.insert(self.recallPoints, self.index)
end

function LazyStream:recall()
	-- print("recall " .. util.dump(self.recallPoints) .. debug.traceback(nil, 2))
	if #self.recallPoints == 0 then error("Recall not matched to Save", 2) end
	self.index = table.remove(self.recallPoints)
end

function LazyStream:continue()
	-- print("continue " .. util.dump(self.recallPoints) .. debug.traceback(nil, 2))
	if #self.recallPoints == 0 then error("Continue not matched to Save", 2) end
	table.remove(self.recallPoints)
end

---Calls fun within a save/recall block. If fun returns nil, recalls. Otherwise, continues. When passed multiple functions, calls them in order and returns the first non-nil result.
---@generic T
---@param fun fun(): T|nil, string?
---@param ... fun(): T|nil, string?
---@return T|nil, string
function LazyStream:scope(fun1,...)
	for i,fun in ipairs({fun1, ...}) do
		self:save()
		local value = fun()

		if value == nil then
			self:recall()
		else
			self:continue()
			return value, "Success on parse tree " .. i
		end
	end

	return nil, "No parse trees matched"
end

return LazyStream
