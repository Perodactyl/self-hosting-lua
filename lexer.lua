local util = require("util")
local LazyStream = require("lazyStream")

---@alias Token { type: "string", value: string, [any]:any } | { type: "number", value: number, [any]:any } | { type: "keyword", value: Keyword, [any]:any } | { type: "operator", value: Operator, [any]:any } | { type: "symbol", value: Symbol, [any]:any } | { type: "assign", value: Assign, [any]:any } | { type: "identifier", value: string, [any]:any }
---@alias Operator UnaryOperator | BinaryOperator
---@alias Keyword "break" | "do" | "else" | "elseif" | "end" | "for" | "function" | "goto" | "if" | "in" | "local" | "repeat" | "return" | "then" | "until" | "while" | "local"
---@alias Symbol "{" | "}" | "(" | ")" | "[" | "]" | "," | "." | ":" | "::" | ";" | "..."
---@alias Assign "="

---@class Lexer
---@field charStream StringStream
local Lexer = {}

function Lexer.new(input)
	local lexer = { charStream = LazyStream.fromString(input) }
	return setmetatable(lexer, {
		__index = Lexer
	})
end

local function readN(charStream, n)
	local out = ""
	if n == nil then error("readN: n was nil", 2) end
	for _ = 1,n do
		out = out .. (charStream:next() or "")
	end
	return out
end

local function parsePaths(charStream, paths)
	local output = {}
	table.sort(paths, function(a,b) return #a.match > #b.match end)
	for _,path in ipairs(paths) do
		table.insert(output, function()
			if path.match == readN(charStream, #path.match) then
				if path.word then
					local ch = charStream:peek()
					if ch ~= nil and ch:match("[a-zA-Z0-9_]") then return nil end
				end
				local result = util.deepCopy(path.result)
				if path.autoSet ~= nil then result[path.autoSet] = path.match end
				return result
			end
		end)
	end
	return output
end

local function whiteSpace(charStream)
	while string.match(charStream:peek() or "", "%s") do charStream:next() end
end

---@param allowRichFormat boolean Enables hex literals, scientific notation, and floats
function Lexer:parseNumber(allowRichFormat)
	return self.charStream:scope("Number",
		"Hexadecimal Number Literal", function()
			if not allowRichFormat then return nil, "Not a rich number" end
			if not readN(self.charStream, 2):match("0[xX]") then
				return nil, "Not beginning with 0x or 0X"
			end
			local hasAnyDigits = false
			local value = 0
			local multiplier = 1
			local place = math.huge

			if self.charStream:nextIfEq("-") then
				multiplier = -1
			end

			while true do
				self.charStream:save()
				local char = self.charStream:next()

				if char ~= nil and string.match(char, "[0-9a-fA-F]") then
					local digit = tonumber(char, 16)
					if place == math.huge then
						value = value * 16 + digit
					else
						place = place - 1
						value = value + digit * 16^place
					end
					hasAnyDigits = true
				elseif char == "." and allowRichFormat then
					if place ~= math.huge then return nil, "Multiple dots in decimal" end
					place = 0
				elseif hasAnyDigits and (char == "p" or char == "P") and allowRichFormat then
					local exponent = self:parseNumber(false)
					if not exponent then return nil, "Failed to parse exponent" end
					multiplier = multiplier * 2 ^ exponent.value
				else
					self.charStream:recall()
					break
				end
			end

			if hasAnyDigits then
				return {type="number",value=value * multiplier}
			else
				return nil, "No digits"
			end
		end,
		"Decimal Number Literal", function()
			local hasAnyDigits = false
			local value = 0
			local multiplier = 1
			local place = math.huge

			if self.charStream:nextIfEq("-") then
				multiplier = -1
			end

			while true do
				self.charStream:save()
				local char = self.charStream:next()

				if char ~= nil and string.match(char, "[0-9]") then
					local digit = tonumber(char)
					if place == math.huge then
						value = value * 10 + digit
					else
						place = place - 1
						value = value + digit * 10^place
					end
					hasAnyDigits = true
				elseif char == "." and allowRichFormat then
					if place ~= math.huge then return nil, "Multiple dots in decimal" end
					place = 0
				elseif hasAnyDigits and (char == "e" or char == "E") and allowRichFormat then
					local exponent = self:parseNumber(false)
					if not exponent then return nil, "Failed to parse exponent" end
					multiplier = multiplier * 10 ^ exponent.value
				else
					self.charStream:recall()
					break
				end
			end

			if hasAnyDigits then
				return {type="number",value=value * multiplier}
			else
				return nil, "No digits"
			end
		end
	)
end

function Lexer:parseNextToken()
	return self.charStream:scope(table.unpack(util.flatten({
		function()
			if self.charStream:isDone() then return nil end
			if not self.charStream:nextIfEq("-") then return nil end
			if not self.charStream:nextIfEq("-") then return nil end
			if not self.charStream:nextIfEq("[") then return nil end

			local level = 0
			while self.charStream:nextIfEq("=") do
				level = level + 1
			end

			if not self.charStream:nextIfEq("[") then return nil end

			while not self.charStream:isDone() do
				if self.charStream:nextIfEq("]") then
					self.charStream:save()
					if readN(self.charStream, level + 1) == ("="):rep(level) .. "]" then
						self.charStream:continue()
						break
					else
						self.charStream:recall()
					end
				else
					self.charStream:next()
				end
			end

			return false
		end,
		function()
			if self.charStream:isDone() then return nil end
			if not self.charStream:nextIfEq("-") then return nil end
			if not self.charStream:nextIfEq("-") then return nil end

			while self.charStream:peek() ~= "\n" do
				self.charStream:next()
			end
			return false
		end,
		function()
			if self.charStream:isDone() then return nil end
			if not self.charStream:peek():match("['\"[]") then return nil end

			local stringContents = ""
			if self.charStream:nextIfEq("[") then
				self.charStream:save()

				local level = 0
				while self.charStream:nextIfEq("=") do
					level = level + 1
				end

				if not self.charStream:nextIfEq("[") then
					self.charStream:recall()
					return
				end
				self.charStream:continue()

				self.charStream:nextIfEq("\n")

				while not self.charStream:isDone() do
					if self.charStream:nextIfEq("]") then
						self.charStream:save()
						if readN(self.charStream, level + 1) == ("="):rep(level) .. "]" then
							self.charStream:continue()
							break
						else
							self.charStream:recall()
							stringContents = stringContents .. "]"
						end
					elseif self.charStream:nextIfEq("\n") then
						self.charStream:nextIfEq("\r")
						stringContents = stringContents .. "\n"
					elseif self.charStream:nextIfEq("\r") then
						self.charStream:nextIfEq("\n")
						stringContents = stringContents .. "\n"
					else
						stringContents = stringContents .. self.charStream:next()
					end
				end
			else
				local delim = self.charStream:next()
				while not self.charStream:isDone() do
					if self.charStream:nextIfEq(delim) then
						break
					elseif self.charStream:nextIfEq("\\") then
						local escapeChar = self.charStream:next()

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
								local next = self.charStream:peek()
								if next ~= nil and next:match("[0-9]") then
									parts = parts .. next
									self.charStream:next()
								else
									break
								end
							end
							stringContents = stringContents .. string.char(tonumber(parts,10))
						elseif escapeChar == "x" then
							local hex = readN(self.charStream, 2)
							stringContents = stringContents .. string.char(tonumber(hex,16))
						elseif escapeChar == "u" then
							if not self.charStream:nextIfEq("{") then error("Escape missing {") end
							local numParts = ""
							while not self.charStream:nextIfEq("}") do
								local digit = self.charStream:next()
								if not digit or not digit:match("[0-9a-fA-F]") then
									error("Unclosed unicode escape")
								end
								numParts = numParts .. digit
							end
							stringContents = stringContents .. utf8.char(tonumber(numParts, 16))
						elseif escapeChar == "z" then
							whiteSpace(self.charStream)
						else
							error("Invalid escape: \\" .. escapeChar)
						end
					else
						stringContents = stringContents .. self.charStream:next()
					end
				end
			end
			-- TODO escape sequences
			return { type = "string", value = stringContents }
		end,
		"Number Literal", function()
			return self:parseNumber(true)
		end,
		parsePaths(self.charStream, {
			{ match = "{",  result = { type = "symbol" }, autoSet = "value" },
			{ match = "}",  result = { type = "symbol" }, autoSet = "value" },
			{ match = "[",  result = { type = "symbol" }, autoSet = "value" },
			{ match = "]",  result = { type = "symbol" }, autoSet = "value" },
			{ match = "(",  result = { type = "symbol" }, autoSet = "value" },
			{ match = ")",  result = { type = "symbol" }, autoSet = "value" },
			{ match = ".",  result = { type = "symbol" }, autoSet = "value" },
			{ match = "...",result = { type = "symbol" }, autoSet = "value" },
			{ match = ",",  result = { type = "symbol" }, autoSet = "value" },
			{ match = ";",  result = { type = "symbol" }, autoSet = "value" },
			{ match = ":",  result = { type = "symbol" }, autoSet = "value" },
			{ match = "::", result = { type = "symbol" }, autoSet = "value" },
			{ match = "=",  result = { type = "assign" }, autoSet = "value" },

			{ match = "+", result = { type = "operator" }, autoSet = "value" },
			{ match = "-", result = { type = "operator" }, autoSet = "value" },
			{ match = "*", result = { type = "operator" }, autoSet = "value" },
			{ match = "/", result = { type = "operator" }, autoSet = "value" },
			{ match = "//",result = { type = "operator" }, autoSet = "value" },
			{ match = "%", result = { type = "operator" }, autoSet = "value" },
			{ match = "^", result = { type = "operator" }, autoSet = "value" },
			{ match = "&", result = { type = "operator" }, autoSet = "value" },
			{ match = "|", result = { type = "operator" }, autoSet = "value" },
			{ match = "~", result = { type = "operator" }, autoSet = "value" },
			{ match = "#", result = { type = "operator" }, autoSet = "value" },
			{ match = "..",result = { type = "operator" }, autoSet = "value" },

			{ match = "<",  result = { type = "operator" }, autoSet = "value" },
			{ match = "<=", result = { type = "operator" }, autoSet = "value" },
			{ match = "==", result = { type = "operator" }, autoSet = "value" },
			{ match = "~=", result = { type = "operator" }, autoSet = "value" },
			{ match = ">",  result = { type = "operator" }, autoSet = "value" },
			{ match = ">=", result = { type = "operator" }, autoSet = "value" },

			{ match = "not", result = { type = "operator" }, autoSet = "value", word=true },
			{ match = "and", result = { type = "operator" }, autoSet = "value", word=true },
			{ match = "or",  result = { type = "operator" }, autoSet = "value", word=true },

			{ match = "false", result = { type = "boolLiteral", value = false }, word=true },
			{ match = "true",  result = { type = "boolLiteral", value = true }, word=true },
			{ match = "nil",   result = { type = "nilLiteral" }, word=true },

			{ match = "break",    result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "do",       result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "else",     result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "elseif",   result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "end",      result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "for",      result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "function", result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "goto",     result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "if",       result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "in",       result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "repeat",   result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "return",   result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "then",     result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "until",    result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "while",    result = { type = "keyword" }, autoSet = "value", word=true },
			{ match = "local",    result = { type = "keyword" }, autoSet = "value", word=true },
		}),
		function()
			if self.charStream:isDone() then return nil end
			if not self.charStream:peek():match("[a-zA-Z_]") then return nil end

			local ident = ""
			while true do
				local char = self.charStream:peek()
				if char == nil then break end
				if string.match(char, "[a-zA-Z0-9_]") then
					ident = ident .. self.charStream:next()
				else break end
			end
			return { type = "identifier", value = ident }
		end,
		function()
			if not self.charStream:isDone() then
				return { type = "unknown", value = self.charStream:next() }
			end
		end
	})) --[[@as any]])
end

---@return fun(): Token | nil
function Lexer:createTokenGenerator()
	local index = 0
	return function()
		whiteSpace(self.charStream)
		local result = self:parseNextToken()
		while result == false do --Encountered a comment
			whiteSpace(self.charStream)
			result = self:parseNextToken()
		end
		-- print("Tokenizer: Generated " .. util.dump(result))
		if result ~= nil then
			index = index + 1
			result.supertype = "token"
			result.index = index
		end
		return result
	end
end

return Lexer
