return {
	groupName = "String Literals",
	members = {
		{
			name = "Base",
			source = [["Hello, World!"]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Long Literal",
			source = [[ [=[Hello, "World!"]=] ]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Escapes",
			source = [["\a\b\f\n\r\t\v\\\"\'"]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Whitespace-skipping Escape",
			source = "\"ab\\z\r\n\t\tc\"",
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Decimal Escape",
			source = [["\27[31m"]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Hexadecimal Escape",
			source = [["\x1b[31m"]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Unicode Escape",
			source = [["\u{1F600}"]],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "No Escapes in Long Literal",
			source = [=[ [[\"]] ]=],
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Long Literals Skip First Newline",
			source = "[[\nabc]]",
			parser = "parseExpression",
			autotest = true,
		},
		{
			name = "Long Literals Assimilate Newlines",
			source = "[[abc\r\n]]",
			parser = "parseExpression",
			autotest = true,
		},
	},
}
