package.path = "./?.lua;./?/init.lua;" .. package.path
local STP = require("stacktraceplus")

local Lexer = require("lexer")
local Parser = require("parser")
local codegen = require("codegen")
local util = require("util")

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

local sourceFile = io.open(arg[0], "r")
if sourceFile == nil then error("Failed to open sourceFile") end
-- local source = sourceFile:read("a")
sourceFile:close()

local source = [[package.path = "./?.lua;./?/init.lua;" .. package.path]]
-- local source = [[package.path]]

do
	local lexer = Lexer.new(source)
	local gen = lexer:createTokenGenerator()

	local output = util.collect(gen)
	util.table(output, { "type", "value" }, util.tokenListFormatter)
end

do
	local lexer = Lexer.new(source)
	local gen = lexer:createTokenGenerator()

	local parser = Parser.new(gen)
	local success, result = xpcall(parser.parseChunk, debug.traceback, parser)

	if success then
		print(util.dump(result, true, true))

		local treeFile = io.open("tree.json", "w")
		if treeFile then
			treeFile:write(util.dumpJSON(result, false) .. "\n")
			treeFile:close()
		end

		print("")

		local code = codegen.block(result, false)
		print(code)
		local outFile = io.open("output.lua", "w")
		if outFile then
			outFile:write(code)
			outFile:close()
		end
	else
		print(result)
	end
end
