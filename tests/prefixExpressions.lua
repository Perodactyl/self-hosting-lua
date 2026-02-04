return {
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
			name = "Method Call",
			source = [[self:info("a")]],
			parser = "parsePrefixExpression",
			autotest = true,
		},
		{
			name = "Access-Method Call",
			source = [[self.helpGenerator:info("a")]],
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
		{
			name = "Group Call",
			source = [[(print)("Hi")]],
			parser = "parsePrefixExpression",
			autotest = true,
		},
	},
}
