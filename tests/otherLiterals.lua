return {
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
		{
			name = "Line Comment",
			source = "-- This is a comment\nnil",
			parser = "parseExpression",
			result = {type="nil"},
		},
		{
			name = "Block Comment",
			source = "--[=[This is a comment\n]=] nil",
			parser = "parseExpression",
			result = {type="nil"},
		},
	},
}
