local util = require("util")
local LazyStream = require("lazyStream")

---@alias Token { type: "string", value: string } | { type: "number", value: number } | { type: "keyword", value: Keyword } | { type: "operator", value: Operator } | { type: "symbol", value: Symbol } | { type: "assign", value: Assign } | { type: "identifier", value: string }
---@alias Operator UnaryOperator | BinaryOperator
---@alias Keyword "break" | "do" | "else" | "elseif" | "end" | "for" | "function" | "goto" | "if" | "in" | "local" | "repeat" | "return" | "then" | "until" | "while"
---@alias Symbol "{" | "}" | "(" | ")" | "[" | "]" | "," | "." | ":" | "::" | ";"
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

---@return fun(): Token | nil
function Lexer:createTokenGenerator()
	return function()
		whiteSpace(self.charStream)
		local result = self.charStream:scope(table.unpack(util.flatten({
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
						else
							stringContents = stringContents .. self.charStream:next()
						end
					end
				else
					local delim = self.charStream:next()
					while not self.charStream:isDone() do
						if self.charStream:nextIfEq(delim) then
							break
						else
							stringContents = stringContents .. self.charStream:next()
						end
					end
				end
				-- TODO escape sequences
				return { type = "string", value = stringContents }
			end,
			parsePaths(self.charStream, {
				{ match = "{",  result = { type = "symbol" }, autoSet = "value" },
				{ match = "}",  result = { type = "symbol" }, autoSet = "value" },
				{ match = "[",  result = { type = "symbol" }, autoSet = "value" },
				{ match = "]",  result = { type = "symbol" }, autoSet = "value" },
				{ match = "(",  result = { type = "symbol" }, autoSet = "value" },
				{ match = ")",  result = { type = "symbol" }, autoSet = "value" },
				{ match = ".",  result = { type = "symbol" }, autoSet = "value" },
				{ match = ",",  result = { type = "symbol" }, autoSet = "value" },
				{ match = ";",  result = { type = "symbol" }, autoSet = "value" },
				{ match = ":",  result = { type = "symbol" }, autoSet = "value" },
				{ match = "::", result = { type = "symbol" }, autoSet = "value" },
				{ match = "=",  result = { type = "assign" }, autoSet = "value" },

				{ match = "+", result = { type = "operator" }, autoSet = "value" },
				{ match = "-", result = { type = "operator" }, autoSet = "value" },
				{ match = "*", result = { type = "operator" }, autoSet = "value" },
				{ match = "/", result = { type = "operator" }, autoSet = "value" },
				{ match = "%", result = { type = "operator" }, autoSet = "value" },
				{ match = "^", result = { type = "operator" }, autoSet = "value" },
				{ match = "&", result = { type = "operator" }, autoSet = "value" },
				{ match = "|", result = { type = "operator" }, autoSet = "value" },
				{ match = "~", result = { type = "operator" }, autoSet = "value" },
				{ match = "..",result = { type = "operator" }, autoSet = "value" },

				{ match = "<",  result = { type = "operator" }, autoSet = "value" },
				{ match = "<=", result = { type = "operator" }, autoSet = "value" },
				{ match = "==", result = { type = "operator" }, autoSet = "value" },
				{ match = "!=", result = { type = "operator" }, autoSet = "value" },
				{ match = ">",  result = { type = "operator" }, autoSet = "value" },
				{ match = ">=", result = { type = "operator" }, autoSet = "value" },

				{ match = "not", result = { type = "operator" }, autoSet = "value" },
				{ match = "and", result = { type = "operator" }, autoSet = "value" },
				{ match = "or",  result = { type = "operator" }, autoSet = "value" },

				{ match = "false", result = { type = "boolLiteral", value = false } },
				{ match = "true",  result = { type = "boolLiteral", value = true } },
				{ match = "nil",   result = { type = "nilLiteral" } },

				{ match = "break",    result = { type = "keyword" }, autoSet = "value" },
				{ match = "do",       result = { type = "keyword" }, autoSet = "value" },
				{ match = "else",     result = { type = "keyword" }, autoSet = "value" },
				{ match = "elseif",   result = { type = "keyword" }, autoSet = "value" },
				{ match = "end",      result = { type = "keyword" }, autoSet = "value" },
				{ match = "for",      result = { type = "keyword" }, autoSet = "value" },
				{ match = "function", result = { type = "keyword" }, autoSet = "value" },
				{ match = "goto",     result = { type = "keyword" }, autoSet = "value" },
				{ match = "if",       result = { type = "keyword" }, autoSet = "value" },
				{ match = "in",       result = { type = "keyword" }, autoSet = "value" },
				{ match = "repeat",   result = { type = "keyword" }, autoSet = "value" },
				{ match = "return",   result = { type = "keyword" }, autoSet = "value" },
				{ match = "then",     result = { type = "keyword" }, autoSet = "value" },
				{ match = "until",    result = { type = "keyword" }, autoSet = "value" },
				{ match = "while",    result = { type = "keyword" }, autoSet = "value" },
			}),
			function()
				if self.charStream:isDone() then return nil end
				if not self.charStream:peek():match("[a-zA-Z]") then return nil end

				local ident = ""
				while true do
					local char = self.charStream:peek()
					if char == nil then break end
					if string.match(char, "[a-zA-Z0-9]") then
						ident = ident .. self.charStream:next()
					else break end
				end
				return { type = "identifier", value = ident }
			end,
			function()
				if self.charStream:isDone() then return nil end
				if not self.charStream:peek():match("[0-9]") then return nil end

				local firstChar = self.charStream:next()
				local mode = "dec"
				local value = 0

				if firstChar == "0" and self.charStream:nextIfEq("x") then
					mode = "hex"
				else
					value = tonumber(firstChar) or 0
				end

				while true do
					local char = self.charStream:peek()
					if char == nil then break end

					if mode == "dec" and char:match("[0-9]") then
						value = 10 * value + tonumber(self.charStream:next())
					elseif mode == "hex" and char:match("[0-9a-fA-F]") then
						value = 16 * value + tonumber(self.charStream:next(), 16)
					else
						break
					end
				end

				-- TODO Support decimal and hexadecimal scientific notation
				return { type = "number", value = value }
			end,
			function()
				if not self.charStream:isDone() then
					return { type = "unknown", value = self.charStream:next() }
				end
			end
		})) --[[@as any]])
		-- print("Tokenizer: Generated " .. util.dump(result))
		if result ~= nil then result.supertype = "token" end
		return result
	end
end

return Lexer
