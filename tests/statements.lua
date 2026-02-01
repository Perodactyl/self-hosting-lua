return {
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
}
