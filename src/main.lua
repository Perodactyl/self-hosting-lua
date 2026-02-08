package.path = "src/?.lua;src/?/init.lua;" .. package.path

local Parser = require("parser")
local transformer = require("transformer")
local autotest = require("autotest")
local util = require("util")
local tests = require("tests")
local Source = require("source")

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
	local source = Source.new("=test", test.source)
	local parser = Parser.new(source)

	local uncrashed, result = xpcall(parser[test.parser], debug.traceback, parser)

	local success = uncrashed and result ~= nil and not result.isError and (test.result == nil or util.tableUtils.deepEq(test.result, result))

	if not success then

		print("Test " .. name .. " \x1b[31;1;4mfailed\x1b[39;21;24m")

		-- local remainingTokens = 0
		-- if uncrashed then
		-- 	while parser.tokenStream:next() ~= nil do
		-- 		remainingTokens = remainingTokens + 1
		-- 	end
		-- end

		-- require("debugger")()

		-- local debugLexer = Lexer.new(source)
		-- local debugGen = debugLexer:createTokenGenerator()
		-- local tokens = util.collect(debugGen)
		-- for i,token in ipairs(tokens) do
		-- 	token.parsed = i <= #tokens - remainingTokens
		-- end
		--
		-- print((util.table(tokens, {"index", "type", "value", "parsed", "span"}, util.tokenListFormatter)))
		-- print("")

		if uncrashed then -- Code did not crash, but did not parse
			local tokens = source.sourceTokens.buffer
			print((util.table(tokens, {"index", "type", "value", "span"}, util.tokenListFormatter)))
			print("")

			if not result.isError and not util.deepEq(test.result, result) then
				print("Expected Result: " .. util.dump(test.result,true,true))
			else
				print(result:stringify())
			end
		else -- Code crashed
			print(result)
		end

	elseif not parser.tokenStream:isDone() then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m with \x1b[33mremaining tokens\x1b[39m")

		local tokens = source.sourceTokens.buffer
		print((util.table(tokens, {"index", "type", "value", "span"}, util.tokenListFormatter)))
		print("")
	elseif test.autotest and test.result == nil and os.getenv("SHOW_MISSING_AUTOTEST") ~= "0" then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m with \x1b[33mno autotest constraint\x1b[39m")
	elseif alwaysPrintTestName then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m")
	end

	if showSuccess or not success or (test.autotest and test.result == nil and os.getenv("SHOW_MISSING_AUTOTEST") ~= "0") or not parser.tokenStream:isDone() then
		if uncrashed then
			print("")
			if result.isError then
				print(result:stringify())
			else
				print("Result: " .. util.dump(result, true, true))
			end
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
	local file
	if path == "-" then
		file = io.stdin
	else
		local handle, errmsg = io.open(path, "r")
		if handle == nil then error("Failed to open file: " .. errmsg, 0) end
		file = handle
	end
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

			local success, result = runTest(name, test, showAllResults, showAllNames)
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
				local annotatedTokens = transformer.retokenize(result)
				local code = transformer.serializeTokens(annotatedTokens, false)

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
