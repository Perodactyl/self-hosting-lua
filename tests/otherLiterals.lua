return {
	groupName = "Other Literals",
	members = {
		{
			name = "Nil Literal",
			source = [[nil]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Bool Literal",
			source = [[true]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Integer Literal",
			source = [[321]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Float Literal",
			source = [[3.14]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Decimal Scientific Notation",
			source = [[1e-3]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Hexadecimal Integer Literal",
			source = [[0xff]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Hexadecimal Float Literal",
			source = [[0xff.a]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Hexadecimal Scientific Notation",
			source = [[0x1p9]],
			parser = "parseExpression",
			autotest = true,
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
		{
			name = "Line Comment",
			source = "-- This is a comment\nnil",
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Block Comment",
			source = "--[=[This is a comment\n]=] nil",
			parser = "parseExpression",
			autotest = true,
		},
	},
}
