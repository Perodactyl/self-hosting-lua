local util = {}

function util.formatIdentifier(input, color)
	if color == false then return input end
	return '\x1b[38;2;180;190;254m' .. input .. '\x1b[39m'
end

function util.formatString(input, color)
	if color == false then return '"' .. input .. '"' end
	return '\x1b[32m"' .. input .. '"\x1b[39m'
end

function util.formatLiteral(input, color)
	if color == false then return tostring(input) end
	return '\x1b[38;2;250;179;135m' .. tostring(input) .. '\x1b[39m'
end

function util.formatKeyword(input, color)
	if color == false then return tostring(input) end
	return '\x1b[38;2;203;166;247m' .. tostring(input) .. '\x1b[39m'
end

function util.dump(tbl, color)
	if color == nil then color = true end

	if type(tbl) == "table" then
		local out = "{"
		for k,v in pairs(tbl) do
			local keyStr
			if type(k) == "string" and string.match(k, "^[a-zA-Z][a-zA-Z0-9]+$") then
				keyStr = util.formatIdentifier(k, color)
			else
				keyStr = '[' .. util.dump(k, color) .. ']'
			end
			out = out .. keyStr .. "=" .. util.dump(v, color)
			if next(tbl,k) ~= nil then out = out .. ", " end
		end
		return out .. "}"
	elseif type(tbl) == "string" then
		return util.formatString(tbl, color)
	elseif type(tbl) == "nil" or type(tbl) == "number" or type(tbl) == "boolean" then
		return util.formatLiteral(tbl, color)
	else
		return tostring(tbl)
	end
end

function util.dumpJSON(tbl)
	if type(tbl) == "table" then
		local output = "{"
		for k,v in pairs(tbl) do
			output = output .. '"' .. tostring(k) .. '":' .. util.dumpJSON(v)
			if next(tbl,k) ~= nil then output = output .. "," end
		end
		output = output .. "}"
		return output
	elseif type(tbl) == "string" then
		return '"' .. tbl .. '"'
	elseif type(tbl) == "number" then
		return tostring(tbl)
	elseif type(tbl) == "boolean" then
		return tostring(tbl)
	elseif type(tbl) == "nil" then
		return "null"
	end
end

function util.hasK(tbl, key)
	for k,v in pairs(tbl) do
		if k == key then return true end
	end
	return false
end

function util.hasV(tbl, val)
	for k,v in pairs(tbl) do
		if v == val then return true end
	end
	return false
end

---@param a any
---@param b any
---@return boolean
function util.deepEq(a, b)
	if type(a) == "table" and type(b) == "table" then
		local discoveredInA = {}
		for k,v in pairs(a) do
			table.insert(discoveredInA, k)
			if not util.deepEq(v, b[k]) then
				return false
			end
		end
		for k,v in pairs(b) do
			if not util.hasV(discoveredInA, k) then
				return false
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
function util.deepCopy(value)
	if type(value) == "table" then
		local output = {}
		for k,v in pairs(value) do
			output[util.deepCopy(k)] = util.deepCopy(v)
		end
		return output
	else
		return value
	end
end

---@generic T
---@param next fun(): T
---@return T[]
function util.collect(next)
	local output = {}
	while true do
		local value = next()
		if value ~= nil then
			table.insert(output, value)
		else
			break
		end
	end
	return output
end


---@generic T
---@param tbl (T|T[])[]
---@return T[]
function util.flatten(tbl)
	local output = {}
	for _,v in ipairs(tbl) do
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

local function tableDefaultFormatter(key, row, color)
	if row == nil then
		if type(key) == "string" and string.match(key, "^[a-zA-Z][a-zA-Z0-9]+$") then
			return util.formatIdentifier(key, color)
		else
			return util.dump(key, color)
		end
	end
	return util.dump(row[key], color)
end

---@generic K,V
---@param values table<K,V>[]
---@param columnTitles? K[]
---@param formatter? fun(key:K, row:table<K,V>|nil, color:boolean): string|nil Return nil to use default formatter. If row is nil, key is the title of a column. Color must be respected for length calculation.
function util.table(values, columnTitles, formatter)
	local standardFormatter
	if formatter == nil then
		standardFormatter = tableDefaultFormatter
	else standardFormatter = formatter end
	formatter = function(key,row,color)
		local out = standardFormatter(key,row,color)
		if out == nil then return tableDefaultFormatter(key,row,color) end
		return out
	end

	local columns = {}

	if columnTitles ~= nil then
		for _,title in ipairs(columnTitles) do
			local titleStr = formatter(title, nil, true)
			local titleLength = #formatter(title, nil, false)

			table.insert(columns, {
				title = titleStr,
				titleWidth = titleLength,
				width = titleLength,
				members = {},
			})
		end
	end

	for i,set in ipairs(values) do
		for k in pairs(set) do
			local titleStr = formatter(k, nil, true)
			local titleLength = #formatter(k, nil, false)

			local valueStr = formatter(k, set, true)
			local valueLength = #formatter(k, set, false) + 1

			local foundColumn = false
			for _, col in ipairs(columns) do
				if col.title == titleStr then
					foundColumn = true
					table.insert(col.members, { value = valueStr, width = valueLength })
					col.width = math.max(col.width, valueLength)
					break
				end
			end

			if columnTitles == nil and not foundColumn then
				table.insert(columns, {
					title = titleStr,
					titleWidth = titleLength,
					width = math.max(titleLength, valueLength),
					members = { { value = valueStr, width = valueLength } }
				})
			end
		end
		for _,col in ipairs(columns) do
			if #col.members < i then
				table.insert(col.members, { value = "", width = 0 })
			end
		end
	end

	local topFrameLine    = "┏━"
	local titleLine       = "┃ "
	local frameLine       = "┣━"
	local bottomFrameLine = "┗━"

	for i, col in ipairs(columns) do
		topFrameLine = topFrameLine .. ("━"):rep(col.width)
		titleLine = titleLine .. col.title .. (" "):rep(col.width - col.titleWidth)
		frameLine = frameLine .. ("━"):rep(col.width)
		bottomFrameLine = bottomFrameLine .. ("━"):rep(col.width)
		if i ~= #columns then
			topFrameLine    = topFrameLine    .. "┳━"
			titleLine       = titleLine       .. "┃ "
			frameLine       = frameLine       .. "╋━"
			bottomFrameLine = bottomFrameLine .. "┻━"
		else
			topFrameLine    = topFrameLine    .. "┓"
			titleLine       = titleLine       .. "┃"
			frameLine       = frameLine       .. "┫"
			bottomFrameLine = bottomFrameLine .. "┛"
		end
	end

	print(topFrameLine)
	print(titleLine)
	print(frameLine)

	for row = 1, #values do
		local line = "┃ "

		for i,col in ipairs(columns) do
			line = line .. col.members[row].value .. (" "):rep(col.width - col.members[row].width)
			if i ~= #columns then
				line = line .. " ┃ "
			else
				line = line .. " ┃"
			end
		end

		print(line)

		if row ~= #values then
			-- print(frameLine)
		end
	end
	print(bottomFrameLine)
end

---@param input string
---@param targetCase "camelCase" | "PascalCase" | "snake_case" | "SCREAMING_SNAKE_CASE" | "kebab-case" | "SCREAMING-KEBAB-CASE"
---@return string
function util.toCase(input, targetCase)
	local words = {}
	local start = 1
	for i = 1, #input do
		local word = input:sub(start, i)
		local next = input:sub(i+1, i+1)
		if not next:match("[a-zA-Z0-9]") or next:upper() == next then
			table.insert(words, word:lower())
			start = i+1
		end
	end

	local output = ""
	for i,word in ipairs(words) do
		if targetCase == "camelCase" then
			if i == 1 then output = output .. word
			else output = output .. word:sub(1,1):upper() .. word:sub(2)
			end
		elseif targetCase == "PascalCase" then
			output = output .. word:sub(1,1):upper() .. word:sub(2)
		elseif targetCase == "snake_case" then
			if i == 1 then output = output .. word
			else output = output .. "_" .. word
			end
		elseif targetCase == "SCREAMING_SNAKE_CASE" then
			if i == 1 then output = output .. word:upper()
			else output = output .. "_" .. word:upper()
			end
		elseif targetCase == "kebab-case" then
			if i == 1 then output = output .. word
			else output = output .. "-" .. word
			end
		elseif targetCase == "SCREAMING-KEBAB-CASE" then
			if i == 1 then output = output .. word:upper()
			else output = output .. "-" .. word:upper()
			end
		end
	end
	return output
end

return util
