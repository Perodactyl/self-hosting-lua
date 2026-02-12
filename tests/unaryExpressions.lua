return {
	groupName = "Unary Expressions",
	members = {
		{
			name = "Negation",
			source = [[- 3]],
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
}
