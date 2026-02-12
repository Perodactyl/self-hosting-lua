return {
	groupName = "Control flow",
	members = {
		{
			name = "Simple If",
			source = [[if a < b then swap() end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "If-Else",
			source = [[if a < b then swap() else print("Not swapped") end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "If-Elseif",
			source = [[if a < b then swap() elseif a > b then print("Greater") end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "If-Elseif-Else",
			source = [[if a < b then swap() elseif a > b then print("Greater") else print("Equal") end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "While",
			source = [[while #val < target do table.insert(val,#val) end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "Repeat Until",
			source = [[repeat local block = file:read(math.huge) until block == nil]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "Numeric For",
			source = [[for i = 1,10 do print(i) end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "Numeric For with Step",
			source = [[for i = 0,1,0.1 do print(i) end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "Iterative For",
			source = [[for i,v in ipairs(args) do print(v) end]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "Goto",
			source = [[
				for i = 1,10 do
					if i % 2 == 0 then goto continue end
					print(v)
					
					::continue::
				end
			]],
			parser = "parseStatement",
			autotest = true,
		},
		{
			name = "Do",
			source = [[do print("Hello, World!") end]],
			parser = "parseStatement",
			autotest = true,
		},
	},
}
