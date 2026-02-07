return {
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
}
