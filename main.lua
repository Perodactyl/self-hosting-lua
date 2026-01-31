package.path = "./?.lua;./?/init.lua;" .. package.path
local STP = require("stacktraceplus")

local Lexer = require("lexer")
local Parser = require("parser")
local codegen = require("codegen")
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
		groupName = "Literals",
		members = {
			{
				name = "Nil Literal",
				source = [[nil]],
				parser = "parseExpression",
			},
			{
				name = "Bool Literal",
				source = [[true]],
				parser = "parseExpression",
			},
			{
				name = "Number Literal",
				source = [[0.5]],
				parser = "parseExpression",
			},
			{
				name = "String Literal",
				source = [["Hello, World!"]],
				parser = "parseExpression",
			},
			{
				name = "Long String Literal",
				source = [[ [=[Hello, "World!"]=] ]],
				parser = "parseExpression",
			},
			-- add tests for escape sequences and nested long strings
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
			{
				name = "Table Literal",
				source = [[{key=value}]],
				parser = "parseExpression",
				result = {
					type = "table",
					value = {
						{
							key={type="string",value="key"},
							value={type="prefix",subtype="identifier",inner="value"},
						}
					}
				},
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
				result = {type="prefix",subtype="identifier",inner="testIdentifier"}
			},
			{
				name = "Dot Access",
				source = [[table.insert]],
				parser = "parsePrefixExpression",
				result = {
					type="prefix",subtype="dot",
					left = {type="prefix",subtype="identifier",inner="table"},
					sub = "insert",
				}
			},
			{
				name = "Index Access",
				source = [=[elements[i]]=],
				parser = "parsePrefixExpression",
				result = {
					type="prefix",subtype="index",
					left = {type="prefix",subtype="identifier",inner="elements"},
					sub = {type="prefix",subtype="identifier",inner="i"},
				}
			},
			{
				name = "Call",
				source = [[table.insert("a")]],
				parser = "parsePrefixExpression",
				result = {
					type = "prefix",
					subtype = "call",
					call = {
						type = "call",
						args = {
							{ type = "string", value = "a" },
						},
						callee = {
							type = "prefix",
							subtype = "dot",
							left = {
								inner = "table",
								subtype = "identifier",
								type = "prefix",
							},
							sub = "insert",
						},
					},
				},
			},
			{
				name = "Group",
				source = [[(1+1)]],
				parser = "parsePrefixExpression",
				result = {
					type = "prefix",
					subtype = "group",
					inner = {
						type = "binary",
						left = {type="number",value=1},
						operator = "+",
						right = {type="number",value=1},
					},
				},
			},
			{
				name = "IIFE",
				source = [[(function() print("hi") end)()]],
				parser = "parsePrefixExpression",
				result = {
					type = "prefix",
					subtype = "call",
					call = {
						type = "call",
						callee = {
							type = "prefix",
							subtype = "group",
							inner = {
								type = "funcDef",
								impl = {
									parameters = {},
									rest = false,
									body = {
										type = "block",
										statements = {
											{
												args = {
													{
														type = "string",
														value = "hi"
													}
												},
												callee = {
													inner = "print",
													subtype = "identifier",
													type = "prefix"
												},
												type = "call"
											}
										},
									},
								},
							},
						},
						args = {},
					},
				},
			},
		},
	},
	{
		groupName = "Unary Expressions",
		members = {
			{
				name = "Negation",
				source = [[-3]],
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
				result = {
					type = "binary",
					left = {type="prefix",subtype="identifier",inner="input"},
					operator = "==",
					right = {type="string",value="test"},
				},
			},
			{
				name = "Comparison",
				source = "#tbl <= 3",
				parser = "parseExpression",
				result = {
					type = "binary",
					left = {
						type="unary",operator="#",
						right={type="prefix",subtype="identifier",inner="tbl"},
					},
					operator = "<=",
					right = {type="number",value=3},
				},
			},
			{
				name = "Term",
				source = "1 + 2 - 3",
				parser = "parseExpression",
				result = {
					type = "binary",
					left = {
						type="binary",operator="+",
						left={type="number",value=1},
						right={type="number",value=2},
					},
					operator = "-",
					right = {type="number",value=3},
				},
			},
			{
				name = "Factor",
				source = "3 * 2 / 3 % 4 // 2",
				parser = "parseExpression",
				result = {
					type = "binary", operator = "//",
					left = {
						type = "binary", operator = "%",
						left = {
							type = "binary",
							left = {
								type="binary",operator="*",
								left={type="number",value=3},
								right={type="number",value=2},
							},
							operator = "/",
							right = {type="number",value=3},
						},
						right = {type="number",value=4},
					},
					right = {type="number",value=2},
				},
			},
			{
				name = "Boolean AND",
				source = "a < b and b < c",
				parser = "parseExpression",
				result = {
					type = "binary",
					left = {
						type="binary",operator="<",
						left={type="prefix",subtype="identifier",inner="a"},
						right={type="prefix",subtype="identifier",inner="b"},
					},
					operator = "and",
					right = {
						type="binary",operator="<",
						left={type="prefix",subtype="identifier",inner="b"},
						right={type="prefix",subtype="identifier",inner="c"},
					},
				},
			},
			{
				name = "Boolean OR",
				source = "a < b and b < c or override",
				parser = "parseExpression",
				result = {
					type = "binary", operator="or",
					left = {
						type = "binary",
						left = {
							type="binary",operator="<",
							left={type="prefix",subtype="identifier",inner="a"},
							right={type="prefix",subtype="identifier",inner="b"},
						},
						operator = "and",
						right = {
							type="binary",operator="<",
							left={type="prefix",subtype="identifier",inner="b"},
							right={type="prefix",subtype="identifier",inner="c"},
						},
					},
					right = {type="prefix",subtype="identifier",inner="override"},
				},
			},
			{
				name = "Concatenation",
				source = [["Lorem" .. "Ipsum"]],
				parser = "parseExpression",
				result = {
					type="binary", operator="..",
					left = {type="string",value="Lorem"},
					right = {type="string",value="Ipsum"},
				},
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
				result = {
					type = "if",
					condition = {
						type = "binary",
						left = {
							inner = "a",
							subtype = "identifier",
							type = "prefix"
						},
						operator = "<",
						right = {
							inner = "b",
							subtype = "identifier",
							type = "prefix"
						},
					},
					body = {
						statements = {
							{
								args = {},
								callee = {
									inner = "swap",
									subtype = "identifier",
									type = "prefix"
								},
								type = "call"
							}
						},
						type = "block"
					},
					elseifs = {},
				},
			},
		},
	},
	-- {
	-- 	groupName = "The Ultimate Test",
	-- 	members = {
	-- 		{
	-- 			name = "main.lua",
	-- 			source = (function()
	-- 				local file = io.open("main.lua", "r")
	-- 				if file then
	-- 					local content = file:read("a")
	-- 					file:close()
	-- 					return content
	-- 				end
	-- 				return "poop"
	-- 			end)(),
	-- 			parser = "parseChunk"
	-- 		},
	-- 	},
	-- },
}

local function runTest(name, test, showSuccess, alwaysPrintTestName)
	local lexer = Lexer.new(test.source)
	local gen = lexer:createTokenGenerator()

	local parser = Parser.new(gen)

	local uncrashed, result, resultReason = xpcall(parser[test.parser], debug.traceback, parser)

	local success = uncrashed and result ~= nil and (test.result == nil or util.deepEq(test.result, result))

	if not success then

		print("Test " .. name .. " \x1b[31;1;4mfailed\x1b[39;21;24m")

		local debugLexer = Lexer.new(test.source)
		local debugGen = debugLexer:createTokenGenerator()
		local tokens = util.collect(debugGen)
		util.table(tokens, { "index", "type", "value" }, util.tokenListFormatter)

		if uncrashed then -- Code did not crash, but did not parse
			if test.result ~= nil and not util.deepEq(test.result, result) then
				print("Output was " .. util.dump(result,true,true) .. " but expected " .. util.dump(test.result,true,true))
			else
				print(resultReason)
			end
		else -- Code crashed
			print(result)
		end

	elseif alwaysPrintTestName then
		print("Test " .. name .. " \x1b[32;1;4mpassed\x1b[39;21;24m")
	end

	if showSuccess or not success then
		if uncrashed then
			print("Result: " .. util.dump(result, true, true))
			local remainingTokens = util.collect(
				function() return parser.tokenStream:next() end,
				15,
				{index="...", type="...",value="..."}
			)
			if #remainingTokens > 0 then
				print("Remaining tokens:")
				util.table(remainingTokens, {"index", "type","value"}, util.tokenListFormatter)
			else
				print("No remaining tokens")
			end
		else
			print(result)
		end
	end

	return success
end

local targetTests, showAllResults, showAllNames

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

			local result = runTest(util.formatKeyword(name,true), test, showAllResults, showAllNames)
			if result then testsPassed = testsPassed + 1 end
			testsRun = testsRun + 1
		end
	end

	print(testsPassed .. " / " .. testsRun .. " tests passed")

	if testsPassed < testsRun then
		os.exit(1)
	end
end


-- do
--
-- 	local lexer = Lexer.new(source)
-- 	local gen = lexer:createTokenGenerator()
--
-- 	local parser = Parser.new(gen)
-- 	local success, result, resultReason = xpcall(parser.parseExpression, debug.traceback, parser)
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
-- 		local treeFile = io.open("tree.json", "w")
-- 		if treeFile then
-- 			treeFile:write(util.dumpJSON(result, false) .. "\n")
-- 			treeFile:close()
-- 		end
--
-- 		print("")
--
-- 		local code = codegen.block(result, false)
-- 		print(code)
-- 		local outFile = io.open("output.lua", "w")
-- 		if outFile then
-- 			outFile:write(code)
-- 			outFile:close()
-- 		end
-- 	else
-- 		print(resultReason)
-- 	end
-- end
