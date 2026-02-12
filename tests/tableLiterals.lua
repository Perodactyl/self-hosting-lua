return {
	groupName = "Table literals",
	members = {
		{
			name = "Empty",
			source = "{}",
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Ident keys",
			source = "{a=true,b=false}",
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Expr keys",
			source = [[{["a"]=true,[5]=false,[true]="a"}]],
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Auto keys",
			source = [[{1,2,3}]],
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Semicolons",
			source = [[{x=1;y=1}]],
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Trailing Separator",
			source = [[{1,2,3,}]],
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Mixed keys",
			source = [[{"a","b","c",__name="example list",[-1]="How did we get here?"}]],
			parser = "parseTableLiteral",
			autotest = true,
		},
		{
			name = "Nesting",
			source = [[{{groupName="Table Literals",members={}},{}}]],
			parser = "parseTableLiteral",
			autotest = true,
		},
	},
}
