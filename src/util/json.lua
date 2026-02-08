local LazyStream = require("lazyStream")
local Source = require("source")
local Error = require("source.error")

local format = require("util.format")
local tableUtils = require("util.table")
local prettyOutput = require("util.prettyOutput")
local List = require("util.list")

local JSON = {}

---@alias JSONTrue true
---@alias JSONFalse false
---@alias JSONBoolean JSONTrue | JSONFalse
---@alias JSONNumber number
---@alias JSONString string
---@class JSONNull
JSON.null = setmetatable({}, {__isNull=true})
---@alias JSONArray List<JSONValue>
---@alias JSONObject table<JSONString, JSONValue>
---@alias JSONValue JSONBoolean | JSONNumber | JSONString | JSONNull | JSONArray | JSONObject

---@param tbl any
---@param color? boolean
---@param state? any[] Used internally to track duplicate values
function JSON.stringifyAny(tbl, color, state)
	if state == nil then state = {} end
	if color == nil then color = false end

	if type(tbl) == "table" and tableUtils.hasV(state, tbl) then
		if color ~= false then return "\x1b[31;3m\"duplicate\"\x1b[39;23m"
		else return "\"duplicate\"" end
	end

	if type(tbl) == "table" then
		table.insert(state, tbl)
		if List.isList(tbl) then
			local output = "["
			for i,v in ipairs(tbl) do
				output = output .. prettyOutput.dumpJSON(v, color, state)
				if i ~= #tbl then output = output .. "," end
			end
			output = output .. "]"
			return output
		else
			local output = "{"
			for k,v in pairs(tbl) do
				output = output
					.. format.string(k, color, false, "json")
					.. ':'
					.. prettyOutput.dumpJSON(v, color, state)

				if next(tbl,k) ~= nil then output = output .. "," end
			end
			output = output .. "}"
			return output
		end
	elseif type(tbl) == "string" then
		return format.string(tbl, color, false, "json")
	elseif type(tbl) == "number" or type(tbl) == "boolean" then
		return format.literal(tbl, color)
	elseif type(tbl) == "nil" then
		return format.keyword("null", color)
	elseif type(tbl) == "function" then
		if color ~= false then return "\x1b[31;3m\"" ..tostring(tbl) .. "\"\x1b[39;23m"
		else return "\"" .. tostring(tbl) .. "\"" end
	end
	return tostring(tbl)
end

---@param value JSONValue
---@param color? boolean
---@param state? any[] Used internally to track duplicate values
---@return string
function JSON.stringify(value, color, state)
	if state == nil then state = {} end
	if color == nil then color = false end
	if state[value] ~= nil then
		return "\"duplicate\""
	end

	if JSON.type(value) == "null" then
		return format.literal("null", color)
	elseif JSON.type(value) == "number" then
		return format.literal(tostring(value), color)
	elseif JSON.type(value) == "boolean" then
		return format.literal(tostring(value), color)
	elseif JSON.type(value) == "string" then
		return format.string(value --[[@as string]], color, false, "json")
	elseif JSON.type(value) == "array" then
		---@cast value JSONArray
		local output = format.symbol("[", color)
		for i,subvalue in ipairs(value) do
			output = output .. JSON.stringify(subvalue, color, state)
			if i ~= #value then
				output = output .. format.symbol(",", color)
			end
		end
		output = output .. format.symbol("]", color)
		state[value] = true
		return output
	elseif JSON.type(value) == "object" then
		---@cast value JSONObject
		local output = format.symbol("{", color)
		local keys = tableUtils.keys(value)
		for i,key in ipairs(keys) do
			output = output .. format.string(key, color, false, "json")
			output = output .. format.symbol(":", color)
			output = output .. JSON.stringify(value[key], color, state)
			if i ~= #keys then
				output = output .. format.symbol(",", color)
			end
		end
		output = output .. format.symbol("}", color)
		state[value] = true
		return output
	end
	error("unreachable")
end

---@param json StringStream
local function parseJSONString(json)
	if not json:peek():match("['\"]") then
		return json:errorNext(true, "Missing quote")
	end

	local stringContents = ""
	local delim = json:next()
	while not json:isDone() do
		if json:nextIfEq(delim) then
			break
		elseif json:nextIfEq("\\") then --TODO make the list of escapes match JSON instead of lua
			local escapeChar = json:next()

			if     escapeChar == "a"  then stringContents = stringContents .. "\a"
			elseif escapeChar == "b"  then stringContents = stringContents .. "\b"
			elseif escapeChar == "f"  then stringContents = stringContents .. "\f"
			elseif escapeChar == "n"  then stringContents = stringContents .. "\n"
			elseif escapeChar == "r"  then stringContents = stringContents .. "\r"
			elseif escapeChar == "t"  then stringContents = stringContents .. "\t"
			elseif escapeChar == "v"  then stringContents = stringContents .. "\v"
			elseif escapeChar == "\\" then stringContents = stringContents .. "\\"
			elseif escapeChar == "\"" then stringContents = stringContents .. "\""
			elseif escapeChar == "'"  then stringContents = stringContents .. "'"
			elseif escapeChar:match("[0-9]") then
				local parts = escapeChar
				for _ = 1,2 do
					local next = json:peek()
					if next ~= nil and next:match("[0-9]") then
						parts = parts .. next
						json:next()
					else
						break
					end
				end
				stringContents = stringContents .. string.char(tonumber(parts,10))
			elseif escapeChar == "x" then
				local hex = json:readN(2)
				stringContents = stringContents .. string.char(tonumber(hex,16))
			elseif escapeChar == "u" then
				if not json:nextIfEq("{") then error("Escape missing {") end
				local numParts = ""
				while not json:nextIfEq("}") do
					local digit = json:next()
					if not digit or not digit:match("[0-9a-fA-F]") then
						return json:errorHere(false, "Unclosed unicode escape")
					end
					numParts = numParts .. digit
				end
				stringContents = stringContents .. utf8.char(tonumber(numParts, 16))
			else
				return json:errorHere(false, "Invalid escape: \\" .. escapeChar)
			end
		else
			stringContents = stringContents .. json:next()
		end
	end
	return stringContents
end

local function parseJSONNumber(json, allowRichFormat)
	local hasAnyDigits = false
	local value = 0
	local multiplier = 1
	local place = math.huge

	if json:nextIfEq("-") then
		multiplier = -1
	end

	while true do
		json:save()
		local char = json:next()

		if char ~= nil and string.match(char, "[0-9]") then
			local digit = tonumber(char)
			if place == math.huge then
				value = value * 10 + digit
			else
				place = place - 1
				value = value + digit * 10^place
			end
			hasAnyDigits = true
		elseif char == "." then
			if place ~= math.huge then return json:errorHere(not hasAnyDigits, "Multiple dots in decimal") end
			place = 0
		elseif hasAnyDigits and (char == "e" or char == "E") and allowRichFormat then
			local exponent = parseJSONNumber(json, false)
			if exponent.isError then
				return exponent:extend("Failed to parse exponent", json:here()):unrecoverable()
			end
			multiplier = multiplier * 10 ^ exponent.value
		else
			json:recall()
			break
		end
	end

	if hasAnyDigits then
		return value * multiplier
	else
		return json:errorNext(true, "No digits")
	end
end

---@param json StringStream
---@return JSONValue | Error
---@overload fun(json: string): JSONValue
function JSON.parse(json)
	if type(json) == "string" then
		local src = Source.new("LSP message", json)
		json = LazyStream.fromString(src.sourceText, src)
	end

	json:skipWhiteSpace()
	local result = json:scope("JSON", {
		{"true",function()
			json:expectStr("true", true)
			return true
		end},
		{"false",function()
			json:expectStr("false", true)
			return false
		end},
		{"null",function()
			json:expectStr("null", true)
			return JSON.null
		end},
		{"number", function()
			return parseJSONNumber(json, true)
		end},
		{"string", function()
			return parseJSONString(json)
		end},
		{"array", function()
			json:expect("[", true)
			local output = List()
			if not json:eq("]") then
				local i = 1
				while true do
					local value = Error.try(JSON.parse(json))
					output[i] = value
					i = i + 1
					if not json:nextIfEq(",") then
						break
					end
				end
			end
			json:expect("]", false)
			return output
		end},
		{"object", function()
			json:expect("{", true)
			local output = tableUtils()
			if not json:eq("}") then
				while true do
					local key = Error.try(parseJSONString(json))
					json:expect(":", false)
					local value = Error.try(JSON.parse(json))
					output[key] = value
					if not json:nextIfEq(",") then
						break
					end
				end
			end
			json:expect("}", false)
			return output
		end},
	})
	if type("result") == "table" and result.isError then
		error(result:stringify(), 2)
	end
	return result
end

---@param value JSONValue
---@return "boolean" | "number" | "string" | "null" | "object" | "array"
function JSON.type(value)
	if value == JSON.null then return "null" end
	if type(value) == "boolean" then return "boolean" end
	if type(value) == "number" then return "number" end
	if type(value) == "string" then return "string" end

	if type(value) == "table" then
		local mt = getmetatable(value)
		if type(mt) == "table" and mt.__isNull == true then
			return "null"
		elseif type(mt) == "table" and mt.__isObject ~= nil then
			return mt.__isObject and "object" or "array"
		else
			return List.isList(mt) and "array" or "object"
		end
	end
	error("Not a JSONValue")
end

return JSON
