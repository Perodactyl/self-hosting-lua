local format = {}

format.defaultTruncationIndicator = "\x1b[40m...\x1b[49m"

---@param input string
---@param color boolean
---@param allowTruncation boolean
---@param escapeFormat? "lua5.1" | "lua5.2" | "json"
function format.string(input, color, allowTruncation, escapeFormat)
	input = tostring(input)
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

	if wasTruncated and color then table.insert(outputParts, format.defaultTruncationIndicator) end
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

function format.literal(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return '\x1b[38;2;250;179;135m' .. input .. '\x1b[39m'
end

function format.keyword(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return '\x1b[38;2;203;166;247;3m' .. input .. '\x1b[39;23m'
end

function format.identifier(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return '\x1b[38;2;180;190;254;4m' .. input .. '\x1b[39;24m'
end

function format.symbol(input, color)
	input = tostring(input)
	if #input == 0 then return "" end
	if color == false then return input end
	return input
end

return format
