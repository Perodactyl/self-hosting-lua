local util = {}

local defaultTruncationIndicator = "\x1b[40m...\x1b[49m"

---@param input string
---@param color boolean
---@param allowTruncation boolean
---@param escapeFormat? "lua5.1" | "lua5.2" | "json"
function util.formatString(input, color, allowTruncation, escapeFormat)
	local fullLength = #input
	local wasTruncated = false
	if allowTruncation then
		input = input:sub(1,80)
		wasTruncated = #input < fullLength
	end
	-- Any part beginning with \x1b is stripped if color is disabled.
	local outputParts = {'\x1b[32m', '"'}
	local lastPrintableSection = 0
	while lastPrintableSection < #input do
		local printableStart,printableEnd = input:find("[]-~#-[ !]+", lastPrintableSection+1)

		local printable, nonprintable
		if printableStart == nil or printableEnd == nil then
			printable = ""
			nonprintable = input:sub(lastPrintableSection+1)
			printableEnd = #input
		else
			printable = input:sub(printableStart, printableEnd)
			nonprintable = input:sub(lastPrintableSection+1, printableStart-1)
		end


		if #nonprintable > 0 then table.insert(outputParts, "\x1b[38;2;203;166;247m") end

		for i = 1,#nonprintable do
			local char = nonprintable:sub(i,i)
			local substitute
			if escapeFormat == "lua5.1" then
				substitute = string.format("\\%03u", char:byte())
			elseif escapeFormat == nil or escapeFormat == "lua5.2" then
				substitute = string.format("\\x%02x", char:byte())
			elseif escapeFormat == "json" then
				substitute = string.format("\\u%04x", char:byte())
			end

			if escapeFormat == "json" then
				if char == "\"" then substitute = "\\\"" end
				if char == "\\" then substitute = "\\\\" end
				if char == "/"  then substitute = "\\/" end
				if char == "\b" then substitute = "\\b" end
				if char == "\f" then substitute = "\\f" end
				if char == "\n" then substitute = "\\n" end
				if char == "\r" then substitute = "\\r" end
				if char == "\t" then substitute = "\\t" end
			else
				if char == "\a" then substitute = "\\a" end
				if char == "\b" then substitute = "\\b" end
				if char == "\f" then substitute = "\\f" end
				if char == "\n" then substitute = "\\n" end
				if char == "\r" then substitute = "\\r" end
				if char == "\t" then substitute = "\\t" end
				if char == "\v" then substitute = "\\v" end
				if char == "\\" then substitute = "\\\\" end
				if char == "\"" then substitute = "\\\"" end
			end

			table.insert(outputParts, substitute)
		end

		if #nonprintable > 0 then table.insert(outputParts, "\x1b[32m") end
		table.insert(outputParts, printable)
		lastPrintableSection = printableEnd
	end

	table.insert(outputParts, "\"")
	table.insert(outputParts, "\x1b[39m")

	if wasTruncated and color then table.insert(outputParts, defaultTruncationIndicator) end
	if wasTruncated and not color then table.insert(outputParts, "...") end

	local printedParts = {}
	if color == false then
		for _,v in ipairs(outputParts) do
			if v:sub(1,1) ~= "\x1b" then
				table.insert(printedParts, v)
			end
		end
	else
		printedParts = outputParts
	end
	return table.concat(printedParts, "")
end

function util.formatLiteral(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return '\x1b[38;2;250;179;135m' .. input .. '\x1b[39m'
end

function util.formatKeyword(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return '\x1b[38;2;203;166;247;3m' .. input .. '\x1b[39;23m'
end

function util.formatIdentifier(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return '\x1b[38;2;180;190;254;4m' .. input .. '\x1b[39;24m'
end

---@param tbl any
---@param color? boolean
---@param pretty? boolean
---@param state? any[]
function util.dump(tbl, color, pretty, state)
	if color == nil then color = true end
	if state == nil then state = {} end

	local uglySp = pretty and "" or " "
	local prettyLn = pretty and "\n" or ""
	local prettyLnT = pretty and "\n\t" or ""
	local prettySp = pretty and " " or ""

	if type(tbl) == "table" then
		local statePresent, stateIndex = util.hasV(state, tbl)
		if statePresent then
			return util.formatKeyword("recursion("..stateIndex..")", color)
		end
		table.insert(state, tbl)

		-- local out = util.formatKeyword("("..#state..")",color) .. " "
		local out = ""

		out = out .. "{"

		local keys = {}
		for k in pairs(tbl) do
			table.insert(keys, k)
		end

		table.sort(keys, function(a,b)
			if type(a) == "number" then
				return type(b) ~= "number" or a < b
			end
			return type(a) == "string" and type(b) == "string" and a < b
		end)

		for i,k in ipairs(keys) do
			local v = tbl[k]

			local keyStr
			if i == k then
				keyStr = ""
			elseif type(k) == "string" and string.match(k, "^[a-zA-Z_][a-zA-Z0-9_]+$") then
				keyStr = util.formatIdentifier(k, color) .. prettySp .. "=" .. prettySp
			else
				keyStr = '[' .. util.dump(k, color, pretty, state) .. ']' .. prettySp .. "=" .. prettySp
			end

			local valStr = util.dump(v, color, pretty, state)
			if pretty then
				local lines = {}
				for line in valStr:gmatch("[^\n]+") do
					table.insert(lines, line)
				end
				valStr = table.concat(lines, "\n\t")
			end

			out = out .. prettyLnT .. keyStr .. valStr
			if i < #keys then out = out .. "," .. uglySp end
		end
		out = out .. (#keys > 0 and prettyLn or "") .. "}"

		-- if pretty then
		-- 	local lines = {}
		-- 	for line in out:gmatch("[^\n]+") do
		-- 		table.insert(lines, line)
		-- 	end
		-- 	out = table.concat()
		-- end

		return out
	elseif type(tbl) == "string" then
		return util.formatString(tbl, color, true)
	elseif type(tbl) == "nil" or type(tbl) == "number" or type(tbl) == "boolean" then
		return util.formatLiteral(tbl, color)
	else
		return tostring(tbl)
	end
end

function util.isArray(tbl)
	local mt = getmetatable(tbl)
	if type(mt) == "table" and type(mt.__isObject) ~= "nil" then
		return false
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

---@param tbl any
---@param color? boolean
---@param state? any[] Used internally to track duplicate values
function util.dumpJSON(tbl, color, state)
	if state == nil then state = {} end

	if type(tbl) == "table" and util.hasV(state, tbl) then
		if color ~= false then return "\x1b[31;3m\"duplicate\"\x1b[39;23m"
		else return "\"duplicate\"" end
	end

	if type(tbl) == "table" then
		table.insert(state, tbl)
		if util.isArray(tbl) then
			local output = "["
			for i,v in ipairs(tbl) do
				output = output .. util.dumpJSON(v, color, state)
				if i ~= #tbl then output = output .. "," end
			end
			output = output .. "]"
			return output
		else
			local output = "{"
			for k,v in pairs(tbl) do
				output = output
					.. util.formatString(k, color, false, "json")
					.. ':'
					.. util.dumpJSON(v, color, state)

				if next(tbl,k) ~= nil then output = output .. "," end
			end
			output = output .. "}"
			return output
		end
	elseif type(tbl) == "string" then
		return util.formatString(tbl, color, false, "json")
	elseif type(tbl) == "number" or type(tbl) == "boolean" then
		return util.formatLiteral(tbl, color)
	elseif type(tbl) == "nil" then
		return util.formatKeyword("null", color)
	elseif type(tbl) == "function" then
		if color ~= false then return "\x1b[31;3m\"" ..tostring(tbl) .. "\"\x1b[39;23m"
		else return "\"" .. tostring(tbl) .. "\"" end
	end
	return tostring(tbl)
end

function util.hasK(tbl, key)
	for k,_ in pairs(tbl) do
		if k == key then return true end
	end
	return false
end

function util.hasV(tbl, val)
	for k,v in pairs(tbl) do
		if v == val then return true, k end
	end
	return false
end

---@param a any
---@param b any
---@param match "a" | "b" | false | nil When set to A, the first parameter can have keys not present in B. Likewise for B.
---@return boolean
function util.deepEq(a, b, match)
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
			if not util.deepEq(v, secondary[k], match) then
				return false
			end
		end

		if not match then
			for k in pairs(secondary) do
				if not util.hasV(discoveredInPrimary, k) then
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
---@param j? integer
---@param truncationIndicator? T
---@return T[]
function util.collect(next, j, truncationIndicator)
	require("debugger")()
	local output = {}
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
---@param value T[]
---@param startAccumulator A
---@param reducer fun(value: T, accumulator: A, index: integer): A
---@return A
function util.reduce(value, startAccumulator, reducer)
	local accumulator = startAccumulator
	for i,v in ipairs(value) do
		accumulator = reducer(v, accumulator, i)
	end
	return accumulator
end

---@generic I, O
---@param list I[]
---@param mapper fun(value: I, index: integer): O
---@return O[]
function util.map(list, mapper)
	local output = {}
	for i,v in ipairs(list) do
		output[i] = mapper(v,i)
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

---@generic T
---@param tbl (T|T[])[]
---@return T[]
function util.flattenIfTagged(tbl)
	local output = {}
	for _,v in ipairs(tbl) do
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

local function tableDefaultFormatter(key, row, color)
	if row == nil then
		if type(key) == "string" and string.match(key, "^[a-zA-Z][a-zA-Z0-9]+$") then
			return util.formatIdentifier(key, color)
		else
			return util.dump(key, color)
		end
	end
	if type(row[key]) == "string" then
		return util.formatString(row[key], color, true)
	end
	return util.dump(row[key], color)
end

function util.tokenListFormatter(key, row, color)
	if row == nil then return nil end

	if row.type == "..." then
		if color then return defaultTruncationIndicator
		else return "..." end
	end

	if key == "type" then
		return util.formatLiteral(util.toCase(tostring(row[key]), "SCREAMING_SNAKE_CASE"), color)
	end

	if key == "value" then
		if row.type == "keyword" then return util.formatKeyword(row.value, color) end
		if row.type == "identifier" then return util.formatIdentifier(row.value, color) end
		if row.type == "symbol" then return tostring(row.value) end
		if row.type == "operator" then return tostring(row.value) end
		if row.type == "assign" then return tostring(row.value) end
		if row.type == "nilLiteral" then return util.formatLiteral("nil", color) end
	end

	if key == "parsed" then
		if row.parsed then
			if color then return "\x1b[32mParsed\x1b[39m" else return "Parsed" end
		else
			if color then return "\x1b[31mUnparsed\x1b[39m" else return "Unparsed" end
		end
	end

	if key == "span" then
		return row.span:stringify(color)
	end
end

---@generic K,V
---@param values table<K,V>[]
---@param columnTitles? K[]
---@param formatter? fun(key:K, row:table<K,V>|nil, color:boolean): string|nil Return nil to use default formatter. If row is nil, key is the title of a column. Color must be respected for length calculation.
---@return string, number width, number height
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
				table.insert(col.members, { value = "<nil>", width = 6 })
				col.width = math.max(col.width, 6)
			end
		end
	end

	local outputLines = {}

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

	table.insert(outputLines, topFrameLine)
	table.insert(outputLines, titleLine)
	table.insert(outputLines, frameLine)

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

		table.insert(outputLines, line)

		-- if row ~= #values then
			-- print(frameLine)
		-- end
	end
	table.insert(outputLines, bottomFrameLine)
	return table.concat(outputLines, "\n"), #bottomFrameLine, #outputLines
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

---@param input string
---@param count? integer
function util.indent(input, count)
	if count == nil then count = 1 end
	return input:gsub("\n", "\n" .. ("\t"):rep(count))
end

---@generic T
---@param value T|Error
---@return T
---@overload fun(value: T|Error, span: Span): T, Span
function util.try(value, span)
	if type(value) == "table" and value.isError then
		error(value)
	end
	return value, span
end

return util
