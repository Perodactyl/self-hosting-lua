local tableUtils
tableUtils = setmetatable({}, {
	__call=function(_,data)
		return tableUtils.new(data)
	end
})

---@param data? table
function tableUtils.new(data)
	return setmetatable(data or {}, {__isObject=true, __index=tableUtils})
end

---@param names string[]
---@param outputType "{k=v}" | "{v=k}" | "{k=v,v=k}"
---@return table
function tableUtils.newEnum(names, outputType)
	local keys, values = tableUtils.new(), tableUtils.new()

	for i = 1,#names do
		table.insert(keys, i)
		table.insert(values, names[i])
	end

	local outputTable = {}
	if outputType == "{k=v}" or outputType == "{k=v,v=k}" then
		for i = 1,#names do
			outputTable[keys[i]] = values[i]
		end
	end
	if outputType == "{v=k}" or outputType == "{k=v,v=k}" then
		for i = 1,#names do
			outputTable[values[i]] = keys[i]
		end
	end

	return setmetatable(outputTable, {
		__isObject = outputType ~= "{k=v}",
		__index = function(_, key)
			local keyPresent, keyIndex = keys:hasV(key)
			local valPresent, valIndex = values:hasV(key)
			if keyPresent then
				return values[keyIndex]
			elseif valPresent then
				return keys[valIndex]
			end
		end
	})
end

function tableUtils.merge(...)
	local output = tableUtils.new()
	for i = 1, select("#", ...) do
		local object = select(i, ...)
		for k,v in pairs(object) do
			output[k] = v
		end
	end
	return output
end

function tableUtils.hasK(tbl, key)
	for k,v in pairs(tbl) do
		if k == key then return true, v end
	end
	return false
end

function tableUtils.hasV(tbl, val)
	for k,v in pairs(tbl) do
		if v == val then return true, k end
	end
	return false
end

---@generic K, V
---@param tbl table<K, V>
---@return K[]
function tableUtils.keys(tbl)
	local keys = {}
	for k,_ in pairs(tbl) do
		table.insert(keys, k)
	end

	table.sort(keys, function(a,b)
		if type(a) == "number" then
			return type(b) ~= "number" or a < b
		end
		return type(a) == "string" and type(b) == "string" and a < b
	end)

	return keys
end

---@param a any
---@param b any
---@param match "a" | "b" | false | nil When set to A, the first parameter can have keys not present in B. Likewise for B.
---@return boolean
function tableUtils.deepEq(a, b, match)
	if type(a) == "table" and type(b) == "table" then
		local primary = a
		local secondary = b
		if match == "b" then
			primary = b
			secondary = a
		end

		local discoveredInPrimary = {}

		for k,v in pairs(primary) do
			table.insert(discoveredInPrimary, k)
			if not tableUtils.deepEq(v, secondary[k], match) then
				return false
			end
		end

		if not match then
			for k in pairs(secondary) do
				if not tableUtils.hasV(discoveredInPrimary, k) then
					return false
				end
			end
		end
		return true
	elseif type(a) == type(b) then
		return a == b
	else
		return false
	end
end

---@generic T
---@param value T
---@param state? any[]
---@return T
function tableUtils.deepCopy(value, state)
	if state == nil then state = {} end
	if state[value] ~= nil then
		return state[value]
	elseif type(value) == "table" then
		local output = {}
		state[value] = output
		for k,v in pairs(value) do
			output[tableUtils.deepCopy(k, state)] = tableUtils.deepCopy(v, state)
		end
		return output
	else
		return value
	end
end

return tableUtils
