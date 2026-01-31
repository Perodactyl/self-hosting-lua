local original_print = print
local function print(...)
	-- original_print(debug.traceback())
	original_print(...)
end
local util = require("util")

---Temporary fix because LuaLS doesn't understand that class generics should be visible in fields.
---@alias T Token

---@generic T
---@class LazyStream<T>
---@field generateNext fun(): T
---@field private buffer T[]
---@field private recallPoints integer[]
---@field index integer
local LazyStream = {}

---@generic T
---@param generateNext fun(): T
---@return LazyStream<T>
function LazyStream.new(generateNext)
	local index = 1
	local stream = {
		generateNext = generateNext,
		buffer = {},
		-- index = 1,
		recallPoints = {},
	}
	return setmetatable(stream, {
		__index = function(self, key)
			if rawget(self, key) ~= nil then return rawget(self, key) end
			if key == "index" then
				-- print("GET: index = " .. index)
				return index
			end
			return LazyStream[key]
		end,
		__newindex= function(self, key, value)
			if key == "index" then
				-- print("SET: index = " .. value .. " (was " .. index .. ")")
				index = value
			else
				rawset(self, key, value)
			end
		end,
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
	if not populateBuffer(self) then return nil, "Failed to generate more items of stream" end
	self.index = self.index + 1
	-- print("LazyStream: next = " .. util.dump(self.buffer[self.index - 1]) .. " (index = " .. self.index .. ")")
	return self.buffer[self.index - 1], "Item in buffer"
end

function LazyStream:peek()
	if not populateBuffer(self) then return nil, "Failed to generate more items of stream" end
	-- print("LazyStream: peek = " .. util.dump(self.buffer[self.index]) .. " (index = " .. self.index .. ")")
	return self.buffer[self.index]
end

function LazyStream:eq(value, ...)
	if util.deepEq(self:peek(), value, "b") then
		return true
	end
	for i = 1, select("#",...) do
		if util.deepEq(self:peek(), select(i,...), "b") then
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
	table.insert(self.recallPoints, self.index)
	-- if self.next == LazyStream.next then print("save " .. util.dump(self.recallPoints)) end
end

function LazyStream:recall()
	-- if self.next == LazyStream.next then print(debug.traceback("recall " .. util.dump(self.recallPoints) .. " returning to " .. self.recallPoints[#self.recallPoints],2)) end
	if #self.recallPoints == 0 then error("Recall not matched to Save", 2) end
	self.index = table.remove(self.recallPoints)
end

function LazyStream:continue()
	-- if self.next == LazyStream.next then print("continue " .. util.dump(self.recallPoints) .. " staying at " .. self.index) end
	if #self.recallPoints == 0 then error("Continue not matched to Save", 2) end
	table.remove(self.recallPoints)
end

-- local DEBUG_PRINT_DEPTH = 0

---Calls fun within a save/recall block. If fun returns nil, recalls. Otherwise, continues. When passed multiple functions, calls them in order and returns the first non-nil result. Callbacks should not have side effects, otherwise non-cannon syntax trees (trees that are somewhat valid and overlap with the cannon result) might escape.
---@generic T
---@param fun1 fun(): T|nil, string?
---@param ... fun(): T|nil, string?
---@overload fun(desc:string, fun1: (fun(): T|nil, string?), ...: (fun(): T|nil, string?)): T|nil, string
---@return T|nil, string
function LazyStream:scope(fun1,fun2,...)
	local functions
	local name
	if type(fun1) == "string" then
		name = fun1
		functions = {fun2,...}
	elseif fun2 ~= nil then
		functions = {fun1,fun2,...}
	else
		functions = {fun1,...}
	end

	local errorReasonLines = {}

	if name then
		table.insert(errorReasonLines, "No parse trees matched: " .. name)
	end

	-- if self.next == LazyStream.next then
	-- 	print(("\t"):rep(DEBUG_PRINT_DEPTH) .. name .. ":")
	-- end

	local lastName = nil
	local i = 0
	for _,fun in ipairs(functions) do
		local funcName = tostring(i)
		i = i + 1
		if type(fun) == "string" then
			lastName = fun
			i = i - 1
			goto continue
		elseif lastName ~= nil then
			funcName = tostring(i) .. "(" .. lastName .. ")"
			lastName = nil
		end

		self:save()
		local value, reason = fun()

		if value == nil then
			-- if self.next == LazyStream.next then
			-- 	print(funcName .. ": " .. tostring(reason or "no reason"))
			-- end
			self:recall()

			reason = reason or "<failed>"
			local j = 1
			for line in reason:gmatch("[^\n]+") do
				if j == 1 then
					table.insert(errorReasonLines, funcName .. ". " .. line)
				else
					table.insert(errorReasonLines, "\t" .. line)
				end
				j = j + 1
			end
		else
			-- if self.next == LazyStream.next then
			-- 	print(("\t"):rep(DEBUG_PRINT_DEPTH) .. "success on " .. funcName .. ": " .. (reason or ""))
			-- 	DEBUG_PRINT_DEPTH = DEBUG_PRINT_DEPTH - 1
			-- end
			self:continue()
			return value, "Success on parse tree " .. i
		end
	    ::continue::
	end

	-- if self.next == LazyStream.next then
	-- 	DEBUG_PRINT_DEPTH = DEBUG_PRINT_DEPTH - 1
	-- end
	return nil, table.concat(errorReasonLines, "\n")
end

return LazyStream
