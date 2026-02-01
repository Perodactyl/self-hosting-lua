return {
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
}
