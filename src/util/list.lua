---@class List<T>: { [integer]: T }
local List
List = setmetatable({}, {
	__call=function(_, data)
		return List.new(data)
	end,
})

---@generic T
---@param data T[] | List<T>
---@return List<T>
function List.new(data)
	return setmetatable(data or {}, {__isObject=false, __index=List})
end

function List.isList(tbl)
	if type(tbl) ~= "table" then return false end

	local mt = getmetatable(tbl)
	if type(mt) == "table" and mt.__index == List then
		return true
	end
	if type(mt) == "table" and type(mt.__isObject) == "boolean" then
		return not mt.__isObject
	end

	local keys = {}
	for k in pairs(tbl) do
		table.insert(keys, k)
	end

	for i,k in ipairs(keys) do
		if i ~= k then return false end
	end

	return true
end

---@generic T
---@param next fun(): T
---@param j? integer
---@param truncationIndicator? T
---@return T[]
function List.collect(next, j, truncationIndicator)
	require("debugger")()
	local output = List()
	local i = 1
	while true do
		local value = next()
		i = i + 1
		if j ~= nil and i > j then
			if truncationIndicator ~= nil then
				table.insert(output, truncationIndicator)
			end
			break
		end
		if value ~= nil then
			table.insert(output, value)
		else
			break
		end
	end
	return output
end

---@generic T, A
---@param startAccumulator A
---@param reducer fun(value: T, accumulator: A, index: integer): A
---@return A
function List:reduce(startAccumulator, reducer)
	local accumulator = startAccumulator
	for i,v in ipairs(self) do
		accumulator = reducer(v, accumulator, i)
	end
	return accumulator
end

---@generic I, O
---@param self List<I>
---@param mapper fun(value: I, index: integer): O
---@return List<O>
function List:map(mapper)
	local output = List()
	for i,v in ipairs(self) do
		output[i] = mapper(v,i)
	end
	return output
end

---@generic T
---@param self List<T|T[]>
---@return List<T>
function List:flatten()
	local output = List()
	for _,v in ipairs(self) do
		if type(v) == "table" then
			for _,v2 in ipairs(v) do
				table.insert(output,v2)
			end
		else
			table.insert(output,v)
		end
	end
	return output
end

---@generic T
---@param self List<T|T[]>
---@return List<T>
function List:flattenIfTagged()
	local output = List()
	for _,v in ipairs(self) do
		---@diagnostic disable-next-line: undefined-field
		if type(v) == "table" and v.__flattenable == true then
			for _,v2 in ipairs(v) do
				table.insert(output,v2)
			end
		else
			table.insert(output,v)
		end
	end
	return output
end

---@generic T
---@param self List<T>
---@param ... T
function List:push(...)
	for i = 1, select("#", ...) do
		table.insert(self, (select(i, ...)))
	end
end

---@generic T
---@param self List<T>
---@param predicate fun(value: T, index: integer): boolean
---@return T | nil
function List:find(predicate)
	for i = 1, #self do
		if predicate(self[i], i) then
			return self[i]
		end
	end
end

return List
