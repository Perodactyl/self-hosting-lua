local tableUtils
tableUtils = setmetatable({}, {
	__call=function(_,data)
		return tableUtils.new(data)
	end
})

---@param data table
function tableUtils.new(data)
	return setmetatable(data or {}, {__isObject=true})
end

function tableUtils.hasK(tbl, key)
	for k,_ in pairs(tbl) do
		if k == key then return true end
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
---@return T
function tableUtils.deepCopy(value)
	if type(value) == "table" then
		local output = {}
		for k,v in pairs(value) do
			output[tableUtils.deepCopy(k)] = tableUtils.deepCopy(v)
		end
		return output
	else
		return value
	end
end

return tableUtils
