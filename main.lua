package.path = "./?.lua;./?/init.lua;" .. package.path
local STP = require("stacktraceplus")

local Lexer = require("lexer")
local Parser = require("parser")
local util = require("util")

local function tokenListFormatter(key, row, color)
	if row == nil then return nil end
	if key == "type" then return util.formatLiteral(util.toCase(tostring(row[key]), "SCREAMING_SNAKE_CASE"), color) end
	if key == "value" then
		if row.type == "keyword" then return util.formatKeyword(row.value, color) end
		if row.type == "identifier" then return tostring(row.value) end
		if row.type == "symbol" then return tostring(row.value) end
		if row.type == "operator" then return tostring(row.value) end
		if row.type == "assign" then return tostring(row.value) end
	end
end

local testProgram = [============[
a,b,c = 1,2,3
print("Hello World!")
function fizzbuzz(n)
	if n % 15 == 0 then return "FizzBuzz"
	elseif n % 5 == 0 then return "Buzz"
	elseif n % 3 == 0 then return "Fizz"
	else return tostring(n) end
end
for i = 1,30 do print(fizzbuzz(n)) end
]============]

local source = testProgram

do
	local lexer = Lexer.new(source)
	local gen = lexer:createTokenGenerator()

	local output = util.collect(gen)
	util.table(output, { "type", "value" }, tokenListFormatter)
end

do
	local lexer = Lexer.new(source)
	local gen = lexer:createTokenGenerator()

	local parser = Parser.new(gen)
	local success, result = xpcall(parser.parseChunk, STP.stacktrace, parser)

	if success then
		print(util.dump(result))
		print(util.dumpJSON(result))
	else
		print(result)
	end
end
