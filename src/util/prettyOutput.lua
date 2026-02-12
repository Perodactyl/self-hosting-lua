local format = require("util.format")
local tableUtils = require("util.table")
local prettyOutput = {}

---@param tbl any
---@param color? boolean
---@param pretty? boolean
---@param state? any[]
function prettyOutput.dump(tbl, color, pretty, state)
	if color == nil then color = true end
	if state == nil then state = {} end

	local uglySp = pretty and "" or " "
	local prettyLn = pretty and "\n" or ""
	local prettyLnT = pretty and "\n\t" or ""
	local prettySp = pretty and " " or ""

	if type(tbl) == "table" then
		local statePresent, stateIndex = tableUtils.hasV(state, tbl)
		if statePresent then
			return format.keyword("recursion("..stateIndex..")", color)
		end
		table.insert(state, tbl)

		-- local out = format.formatKeyword("("..#state..")",color) .. " "
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
			elseif type(k) == "string" and string.match(k, "^[a-zA-Z_][a-zA-Z0-9_]*$") then
				keyStr = format.identifier(k, color) .. prettySp .. "=" .. prettySp
			else
				keyStr = '[' .. prettyOutput.dump(k, color, pretty, state) .. ']' .. prettySp .. "=" .. prettySp
			end

			local valStr = prettyOutput.dump(v, color, pretty, state)
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
		return format.string(tbl, color, true, "lua5.2")
	elseif type(tbl) == "nil" or type(tbl) == "number" or type(tbl) == "boolean" then
		return format.literal(tbl, color)
	else
		return tostring(tbl)
	end
end

function prettyOutput.tableDefaultFormatter(key, row, color)
	if row == nil then
		if type(key) == "string" and string.match(key, "^[a-zA-Z][a-zA-Z0-9]+$") then
			return format.identifier(key, color)
		else
			return prettyOutput.dump(key, color)
		end
	end
	if type(row[key]) == "string" then
		return format.string(row[key], color, true)
	end
	return prettyOutput.dump(row[key], color)
end

function prettyOutput.tokenListFormatter(key, row, color)
	if row == nil then return nil end

	if row.type == "..." then
		if color then return format.defaultTruncationIndicator
		else return "..." end
	end

	if key == "type" then
		return format.literal(prettyOutput.toCase(tostring(row[key]), "SCREAMING_SNAKE_CASE"), color)
	end

	if key == "value" then
		if row.type == "keyword" then return format.keyword(row.value, color) end
		if row.type == "identifier" then return format.identifier(row.value, color) end
		if row.type == "symbol" then return tostring(row.value) end
		if row.type == "operator" then return tostring(row.value) end
		if row.type == "assign" then return tostring(row.value) end
		if row.type == "nil" then return format.literal("nil", color) end
		if row.type == "bool" then return format.literal(tostring(row.value), color) end
		if row.type == "string" then return format.string(row.value, color, true, "lua5.2") end
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
function prettyOutput.table(values, columnTitles, formatter)
	local standardFormatter
	if formatter == nil then
		standardFormatter = prettyOutput.tableDefaultFormatter
	else standardFormatter = formatter end

	formatter = function(key,row,color)
		local out = standardFormatter(key,row,color)
		if out == nil then return prettyOutput.tableDefaultFormatter(key,row,color) end
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
				width = titleLength + 1,
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
function prettyOutput.toCase(input, targetCase)
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
function prettyOutput.indent(input, count)
	if count == nil then count = 1 end
	return input:gsub("\n", "\n" .. ("\t"):rep(count))
end

function prettyOutput.eprint(...) io.stderr:write(..., "\n") end

return prettyOutput
