-- local STP = require("stacktraceplus")

local Lexer = require("lexer")
local Parser = require("parser")
local codegen = require("codegen")
local autotest = require("autotest")
local util = require("util")

local tests = {
	{
		groupName = "Table literals",
		members = {
			{
				name = "Empty",
				source = "{}",
				parser = "parseTableLiteral",
			},
			{
				name = "Ident keys",
				source = "{a=true,b=false}",
				parser = "parseTableLiteral",
			},
			{
				name = "Expr keys",
				source = [[{["a"]=true,[5]=false,[true]="a"}]],
				parser = "parseTableLiteral",
			},
			{
				name = "Auto keys",
				source = [[{1,2,3}]],
				parser = "parseTableLiteral",
			},
			{
				name = "Semicolons",
				source = [[{x=1;y=1}]],
				parser = "parseTableLiteral",
			},
			{
				name = "Trailing Separator",
				source = [[{1,2,3,}]],
				parser = "parseTableLiteral",
			},
			{
				name = "Mixed keys",
				source = [[{"a","b","c",__name="example list",[-1]="How did we get here?"}]],
				parser = "parseTableLiteral",
			},
			{
				name = "Nesting",
				source = [[{{groupName="Table Literals",members={}},{}}]],
				parser = "parseTableLiteral",
			},
		},
	},
	{
		groupName = "String Literals",
		members = {
			{
				name = "Base",
				source = [["Hello, World!"]],
				parser = "parseExpression",
				result = {type="string",value="Hello, World!"}
			},
			{
				name = "Long Literal",
				source = [[ [=[Hello, "World!"]=] ]],
				parser = "parseExpression",
				result = {type="string",value=[=[Hello, "World!"]=]}
			},
			{
				name = "Escapes",
				source = [["\a\b\f\n\r\t\v\\\"\'"]],
				parser = "parseExpression",
				result = {type="string",value="\a\b\f\n\r\t\v\\\"\'"},
			},
			{
				name = "Whitespace-skipping Escape",
				source = "\"ab\\z\r\n\t\tc\"",
				parser = "parseExpression",
				result = {type="string",value="abc"},
			},
			{
				name = "Decimal Escape",
				source = [["\27[31m"]],
				parser = "parseExpression",
				result = {type="string",value="\x1b[31m"},
			},
			{
				name = "Hexadecimal Escape",
				source = [["\x1b[31m"]],
				parser = "parseExpression",
				result = {type="string",value="\x1b[31m"},
			},
			{
				name = "Unicode Escape",
				source = [["\u{1F600}"]],
				parser = "parseExpression",
				result = {type="string",value="\u{1F600}"},
			},
			{
				name = "No Escapes in Long Literal",
				source = [=[ [[\"]] ]=],
				parser = "parseExpression",
				result = {type="string",value="\\\""},
			},
			{
				name = "Long Literals Skip First Newline",
				source = "[[\nabc]]",
				parser = "parseExpression",
				result = {type="string",value="abc"},
			},
			{
				name = "Long Literals Assimilate Newlines",
				source = "[[abc\r\n]]",
				parser = "parseExpression",
				result = {type="string",value="abc\n"},
			},
		},
	},
	{
		groupName = "Other Literals",
		members = {
			{
				name = "Nil Literal",
				source = [[nil]],
				parser = "parseExpression",
				result = {type="nil"}
			},
			{
				name = "Bool Literal",
				source = [[true]],
				parser = "parseExpression",
				result = {type="bool",value=true}
			},
			{
				name = "Integer Literal",
				source = [[321]],
				parser = "parseExpression",
				result = {type="number",value=321}
			},
			{
				name = "Float Literal",
				source = [[3.14]],
				parser = "parseExpression",
				result = {type="number",value=3.14}
			},
			{
				name = "Decimal Scientific Notation",
				source = [[1e-3]],
				parser = "parseExpression",
				result = {type="number",value=0.001}
			},
			{
				name = "Hexadecimal Integer Literal",
				source = [[0xff]],
				parser = "parseExpression",
				result = {type="number",value=255}
			},
			{
				name = "Hexadecimal Float Literal",
				source = [[0xff.a]],
				parser = "parseExpression",
				result = {type="number",value=255.625}
			},
			{
				name = "Hexadecimal Scientific Notation",
				source = [[0x1p9]],
				parser = "parseExpression",
				result = {type="number",value=512}
			},
			{
				name = "Vararg",
				source = [[...]],
				parser = "parseExpression",
			},
			{
				name = "Function expression",
				source = [[function() end]],
				parser = "parseExpression",
			},
		},
	},
	{
		groupName = "Prefix Expressions",
		members = {
			{
				name = "Identifier Access",
				source = [[testIdentifier]],
				parser = "parsePrefixExpression",
				autotest = true,
			},
			{
				name = "Dot Access",
				source = [[table.insert]],
				parser = "parsePrefixExpression",
				autotest = true,
			},
			{
				name = "Index Access",
				source = [=[elements[i]]=],
				parser = "parsePrefixExpression",
				autotest = true,
			},
			{
				name = "Call",
				source = [[table.insert("a")]],
				parser = "parsePrefixExpression",
				autotest = true,
			},
			{
				name = "Group",
				source = [[(1+1)]],
				parser = "parsePrefixExpression",
				autotest = true,
			},
			{
				name = "IIFE",
				source = [[(function() print("hi") end)()]],
				parser = "parsePrefixExpression",
				autotest = true,
			},
		},
	},
	{
		groupName = "Unary Expressions",
		members = {
			{
				name = "Negation",
				source = [[- 3]],
				parser = "parseExpression",
				result = {type="unary",operator="-",right={type="number",value=3}},
			},
			{
				name = "Boolean Not",
				source = [[not true]],
				parser = "parseExpression",
				result = {type="unary",operator="not",right={type="bool",value=true}},
			},
			{
				name = "Length",
				source = [[#string]],
				parser = "parseExpression",
				result = {type="unary",operator="#",right={type="prefix",subtype="identifier",inner="string"}},
			},
			{
				name = "Bitwise NOT",
				source = [[~3]],
				parser = "parseExpression",
				result = {type="unary",operator="~",right={type="number",value=3}},
			},
		},
	},
	{
		groupName = "Binary Expressions",
		members = {
			{
				name = "Equality",
				source = "input == 'test'",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Inquality",
				source = "input ~= 'test'",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Less",
				source = "#tbl < 3",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Less-Equal",
				source = "#tbl <= 3",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Greater",
				source = "#tbl > 3",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Greater-Equal",
				source = "#tbl >= 3",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Term",
				source = "1 + 2 - 3",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Factor",
				source = "3 * 2 / 3 % 4 // 2",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Boolean AND",
				source = "a < b and b < c",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Boolean OR",
				source = "a < b and b < c or override",
				parser = "parseExpression",
				autotest = true,
			},
			{
				name = "Concatenation",
				source = [["Lorem" .. "Ipsum"]],
				parser = "parseExpression",
				autotest = true,
			},
		},
	},
	{
		groupName = "Control flow",
		members = {
			{
				name = "Simple If",
				source = [[if a < b then swap() end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "If-Else",
				source = [[if a < b then swap() else print("Not swapped") end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "If-Elseif",
				source = [[if a < b then swap() elseif a > b then print("Greater") end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "If-Elseif-Else",
				source = [[if a < b then swap() elseif a > b then print("Greater") else print("Equal") end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "While",
				source = [[while #val < target do table.insert(val,#val) end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Repeat Until",
				source = [[repeat local block = file:read(math.huge) until block == nil]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Numeric For",
				source = [[for i = 1,10 do print(i) end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Numeric For with Step",
				source = [[for i = 0,1,0.1 do print(i) end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Iterative For",
				source = [[for i,v in ipairs(args) do print(v) end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Goto",
				source = [[
					for i = 1,10 do
						if i % 2 == 0 then goto continue end
						print(v)
						
						::continue::
					end
				]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Do",
				source = [[do print("Hello, World!") end]],
				parser = "parseStatement",
				autotest = true,
			},
		},
	},
	{
		groupName = "Statements",
		members = {
			{
				name = "Assignment",
				source = [[a,b,c = 1,2,3]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Local Assignment",
				source = [[local a,b,c = 1,2,3]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Local Declaration",
				source = [[local a,b,c]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Function definition",
				source = [[function test() print("hi") end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Function definition on a table",
				source = [[local lib = {} function lib.test() print("hi") end]],
				parser = "parseChunk",
				autotest = true,
			},
			{
				name = "Method definition on a table",
				source = [[local lib = {} function lib:test() print(self) end]],
				parser = "parseChunk",
				autotest = true,
			},
			{
				name = "Local function definition",
				source = [[local function test() print("hi") end]],
				parser = "parseStatement",
				autotest = true,
			},
			{
				name = "Return",
				source = [[return "test", false]],
				parser = "parseStatement",
				autotest = true,
			},
		},
	},
}

autotest.load()

for i,group in ipairs(tests) do
	for j,test in ipairs(group.members) do
		if test.autotest then
			test.result = autotest.get(i .. "." .. j .. "-" .. group.groupName .. "-" .. test.name)
			if test.result == nil then
				print("\x1b[31mAutotest: Missing " .. i .. "." .. j .. "\x1b[39m")
			end
		end
	end
end

local function runTest(name, test, showSuccess, alwaysPrintTestName)
	local lexer = Lexer.new(test.source)
	local gen = lexer:createTokenGenerator()

	local parser = Parser.new(gen)

	local uncrashed, result, resultReason = xpcall(parser[test.parser], debug.traceback, parser)

	local success = uncrashed and result ~= nil and (test.result == nil or util.deepEq(test.result, result))

	if not success then

		print("Test " .. name .. " \x1b[31;1;4mfailed\x1b[39;21;24m")

		local remainingTokens = 0
		while parser.tokenStream:next() ~= nil do
			remainingTokens = remainingTokens + 1
		end

		local debugLexer = Lexer.new(test.source)
		local debugGen = debugLexer:createTokenGenerator()
		local tokens = util.collect(debugGen)
		for i,token in ipairs(tokens) do
			token.parsed = i <= #tokens - remainingTokens
		end

		print((util.table(tokens, { "index", "type", "value", "parsed" }, util.tokenListFormatter)))
		print("")

		if uncrashed then -- Code did not crash, but did not parse
			if test.result ~= nil and not util.deepEq(test.result, result) then
				print("Expected Result: " .. util.dump(test.result,true,true))
			else
				print(resultReason)
			end
		else -- Code crashed
			print(result)
		end

	elseif not parser.tokenStream:isDone() then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m with \x1b[33mremaining tokens\x1b[39m")
		local remainingTokens = 0
		while parser.tokenStream:next() ~= nil do
			remainingTokens = remainingTokens + 1
		end

		local debugLexer = Lexer.new(test.source)
		local debugGen = debugLexer:createTokenGenerator()
		local tokens = util.collect(debugGen)
		for i,token in ipairs(tokens) do
			token.parsed = i <= #tokens - remainingTokens
		end
		print((util.table(tokens, { "index", "type", "value", "parsed" }, util.tokenListFormatter)))
		print("")
	elseif test.autotest and test.result == nil and os.getenv("SHOW_MISSING_AUTOTEST") ~= "0" then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m with \x1b[33mno autotest constraint\x1b[39m")
	elseif alwaysPrintTestName then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m")
	end

	if showSuccess or not success or (test.autotest and test.result == nil and os.getenv("SHOW_MISSING_AUTOTEST") ~= "0") or not parser.tokenStream:isDone() then
		if uncrashed then
			print("")
			print("Result: " .. util.dump(result, true, true))
			print("\n")
		else
			print(result)
			print("\n")
		end
	end

	return success, result
end

local targetTests, showAllResults, showAllNames, saveTree, saveCode

local SHOW_TEST = arg[1]

if SHOW_TEST == nil then
	targetTests = tests
	showAllResults = os.getenv("SHOW_SUCCESSES") == "1"
	showAllNames = os.getenv("SHOW_SUCCESSES") == "1"
elseif SHOW_TEST:match("^[0-9]+%.?$") then
	local i,dot = SHOW_TEST:match("^([0-9]+)(%.?)$")
	local group = tests[tonumber(i)]
	group.index = tonumber(i)
	targetTests = {group}
	showAllResults = dot ~= ""
	showAllNames = true
elseif SHOW_TEST:match("^[0-9]+%.[0-9]+$") then
	local i,j = SHOW_TEST:match("([0-9]+)%.([0-9]+)")
	local group = tests[tonumber(i)]
	local member = group.members[tonumber(j)]
	member.index = tonumber(j)
	targetTests = {
		{
			groupName = group.groupName,
			members = {member},
			index = tonumber(i),
		},
	}
	showAllResults = true
	showAllNames = true
elseif SHOW_TEST == "at:save" or SHOW_TEST == "at:append" then

	if SHOW_TEST == "at:save" then autotest.reset() end
	local any_fail = false

	for i,group in ipairs(tests) do
		for j,test in ipairs(group.members) do
			if not test.autotest then goto continue end
			if SHOW_TEST == "at:append" then
				if test.result ~= nil then goto continue end
			else
				test.result = nil
			end

			if group.index ~= nil then i = group.index end
			if test.index ~= nil then j = test.index end

			local name = i .. "." .. j .. " (" .. group.groupName .. ": " ..test.name .. ")"

			local success,result = runTest(util.formatKeyword(name,true), test, true, true)
			if success then
				autotest.set(i .. "." .. j .. "-" .. group.groupName .. "-" .. test.name, result)
			else
				any_fail = true
			end
			::continue::
		end
	end

	if not any_fail or SHOW_TEST == "at:append" then
		autotest.save()
	else
		print("Autotest: errors occured, not saving")
	end
	return
elseif SHOW_TEST == "at:evict" and #arg == 2 then
	local i,j = arg[2]:match("([0-9]+)%.([0-9]+)")
	local group = tests[tonumber(i)]
	local test = group.members[tonumber(j)]

	autotest.set(i .. "." .. j .. "-" .. group.groupName .. "-" .. test.name, nil)

	autotest.save()
	return
elseif SHOW_TEST == "custom" and #arg == 2 then
	local path = arg[2]
	local file, errmsg = io.open(path, "r")
	if file == nil then error("Failed to open file: " .. errmsg, 0) end
	local content = file:read("a")
	file:close()
	targetTests = {
		{
			groupName = "Specified File",
			members = {
				{
					name = path,
					source = content,
					parser = "parseChunk",
				},
			},
		},
	}
	showAllResults = true
	showAllNames = true
	saveTree = os.getenv("SAVE_TREE")
	saveCode = os.getenv("SAVE_CODE")
else
	targetTests = tests
	showAllResults = false
	showAllNames = true
end

do
	local testsRun = 0
	local testsPassed = 0
	for i,group in ipairs(targetTests) do
		for j,test in ipairs(group.members) do
			if group.index ~= nil then i = group.index end
			if test.index ~= nil then j = test.index end
			local name = i .. "." .. j .. " (" .. group.groupName .. ": " ..test.name .. ")"

			local success, result = runTest(util.formatKeyword(name,true), test, showAllResults, showAllNames)
			if success then testsPassed = testsPassed + 1 end
			if success and saveTree then
				local file, errmsg = io.open(saveTree, "w")
				if file then
					file:write(util.dumpJSON(result, false))
					file:close()
				else
					print("Failed to save tree: " .. errmsg)
				end
			end
			if success and saveCode then
				local code = codegen.generate(result, false)
				local file, errmsg = io.open(saveCode, "w")
				if file then
					file:write(code)
					file:close()
				else
					print("Failed to save code: " .. errmsg)
				end
			end
			testsRun = testsRun + 1
		end
	end

	print(testsPassed .. " / " .. testsRun .. " tests passed")

	if testsPassed < testsRun then
		os.exit(1)
	end
end

-- do
-- 	local lexer = Lexer.new([[
-- 		for i = 1,10 do
-- 			print(i)
-- 		end]])
-- 	local gen = lexer:createTokenGenerator()
--
-- 	local parser = Parser.new(gen)
-- 	local success, result, resultReason = xpcall(parser.parseChunk, debug.traceback, parser)
--
-- 	if success then
-- 		if result == nil then
-- 			print(resultReason)
-- 			util.table(util.collect(
-- 				function() return parser.tokenStream:next() end,
-- 				15,
-- 				{index="...", type="...",value="..."}
-- 			), {"index", "type","value"}, util.tokenListFormatter)
-- 			return
-- 		end
-- 		print(util.dump(result, true, true))
--
-- 		print("")
--
-- 		local code = codegen.generate(result)
-- 		print(code)
-- 	else
-- 		print(resultReason)
-- 	end
-- end
