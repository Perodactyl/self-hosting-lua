return {
	groupName = "Unary Expressions",
	members = {
		{
			name = "Negation",
			source = [[- 3]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Boolean Not",
			source = [[not true]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Length",
			source = [[#string]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Bitwise NOT",
			source = [[~3]],
			parser = "parseExpression",
			autotest = true,
		},
	},
}
