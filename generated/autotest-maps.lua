--[[ File is auto generated 02/06/26 23:00:00 EST UTC-0500 ]]
return {
	["4.1-Prefix Expressions-Identifier Access"] = {
		inner = "testIdentifier",
		subtype = "identifier",
		type = "prefix"
	},
	["4.2-Prefix Expressions-Dot Access"] = {
		left = {
			inner = "table",
			subtype = "identifier",
			type = "prefix"
		},
		sub = "insert",
		subtype = "dot",
		type = "prefix"
	},
	["4.3-Prefix Expressions-Index Access"] = {
		left = {
			inner = "elements",
			subtype = "identifier",
			type = "prefix"
		},
		sub = {
			inner = "i",
			subtype = "identifier",
			type = "prefix"
		},
		subtype = "index",
		type = "prefix"
	},
	["4.4-Prefix Expressions-Call"] = {
		call = {
			args = {
				{
					type = "string",
					value = "a"
				}
			},
			callee = {
				left = {
					inner = "table",
					subtype = "identifier",
					type = "prefix"
				},
				sub = "insert",
				subtype = "dot",
				type = "prefix"
			},
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["4.5-Prefix Expressions-Method Call"] = {
		call = {
			args = {
				{
					type = "string",
					value = "a"
				}
			},
			callee = {
				inner = "self",
				subtype = "identifier",
				type = "prefix"
			},
			method = "info",
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["4.6-Prefix Expressions-Access-Method Call"] = {
		call = {
			args = {
				{
					type = "string",
					value = "a"
				}
			},
			callee = {
				left = {
					inner = "self",
					subtype = "identifier",
					type = "prefix"
				},
				sub = "helpGenerator",
				subtype = "dot",
				type = "prefix"
			},
			method = "info",
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["4.7-Prefix Expressions-Group"] = {
		inner = {
			left = {
				type = "number",
				value = 1
			},
			operator = "+",
			right = {
				type = "number",
				value = 1
			},
			type = "binary"
		},
		subtype = "group",
		type = "prefix"
	},
	["4.8-Prefix Expressions-IIFE"] = {
		call = {
			args = {},
			callee = {
				inner = {
					impl = {
						body = {
							statements = {
								{
									args = {
										{
											type = "string",
											value = "hi"
										}
									},
									callee = {
										inner = "print",
										subtype = "identifier",
										type = "prefix"
									},
									type = "call"
								}
							},
							type = "block"
						},
						parameters = {},
						rest = false
					},
					type = "funcDef"
				},
				subtype = "group",
				type = "prefix"
			},
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["4.9-Prefix Expressions-Group Call"] = {
		call = {
			args = {
				{
					type = "string",
					value = "Hi"
				}
			},
			callee = {
				inner = {
					inner = "print",
					subtype = "identifier",
					type = "prefix"
				},
				subtype = "group",
				type = "prefix"
			},
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["6.1-Binary Expressions-Equality"] = {
		left = {
			inner = "input",
			subtype = "identifier",
			type = "prefix"
		},
		operator = "==",
		right = {
			type = "string",
			value = "test"
		},
		type = "binary"
	},
	["6.10-Binary Expressions-Boolean OR"] = {
		left = {
			left = {
				left = {
					inner = "a",
					subtype = "identifier",
					type = "prefix"
				},
				operator = "<",
				right = {
					inner = "b",
					subtype = "identifier",
					type = "prefix"
				},
				type = "binary"
			},
			operator = "and",
			right = {
				left = {
					inner = "b",
					subtype = "identifier",
					type = "prefix"
				},
				operator = "<",
				right = {
					inner = "c",
					subtype = "identifier",
					type = "prefix"
				},
				type = "binary"
			},
			type = "binary"
		},
		operator = "or",
		right = {
			inner = "override",
			subtype = "identifier",
			type = "prefix"
		},
		type = "binary"
	},
	["6.11-Binary Expressions-Concatenation"] = {
		left = {
			type = "string",
			value = "Lorem"
		},
		operator = "..",
		right = {
			type = "string",
			value = "Ipsum"
		},
		type = "binary"
	},
	["6.2-Binary Expressions-Inquality"] = {
		left = {
			inner = "input",
			subtype = "identifier",
			type = "prefix"
		},
		operator = "~=",
		right = {
			type = "string",
			value = "test"
		},
		type = "binary"
	},
	["6.3-Binary Expressions-Less"] = {
		left = {
			operator = "#",
			right = {
				inner = "tbl",
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = "<",
		right = {
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.4-Binary Expressions-Less-Equal"] = {
		left = {
			operator = "#",
			right = {
				inner = "tbl",
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = "<=",
		right = {
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.5-Binary Expressions-Greater"] = {
		left = {
			operator = "#",
			right = {
				inner = "tbl",
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = ">",
		right = {
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.6-Binary Expressions-Greater-Equal"] = {
		left = {
			operator = "#",
			right = {
				inner = "tbl",
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = ">=",
		right = {
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.7-Binary Expressions-Term"] = {
		left = {
			left = {
				type = "number",
				value = 1
			},
			operator = "+",
			right = {
				type = "number",
				value = 2
			},
			type = "binary"
		},
		operator = "-",
		right = {
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.8-Binary Expressions-Factor"] = {
		left = {
			left = {
				left = {
					left = {
						type = "number",
						value = 3
					},
					operator = "*",
					right = {
						type = "number",
						value = 2
					},
					type = "binary"
				},
				operator = "/",
				right = {
					type = "number",
					value = 3
				},
				type = "binary"
			},
			operator = "%",
			right = {
				type = "number",
				value = 4
			},
			type = "binary"
		},
		operator = "//",
		right = {
			type = "number",
			value = 2
		},
		type = "binary"
	},
	["6.9-Binary Expressions-Boolean AND"] = {
		left = {
			left = {
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "<",
			right = {
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		operator = "and",
		right = {
			left = {
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "<",
			right = {
				inner = "c",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		type = "binary"
	},
	["7.1-Control flow-Simple If"] = {
		body = {
			statements = {
				{
					args = {},
					callee = {
						inner = "swap",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		condition = {
			left = {
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "<",
			right = {
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elseifs = {},
		type = "if"
	},
	["7.10-Control flow-Goto"] = {
		body = {
			statements = {
				{
					body = {
						statements = {
							{
								destination = "continue",
								type = "goto"
							}
						},
						type = "block"
					},
					condition = {
						left = {
							left = {
								inner = "i",
								subtype = "identifier",
								type = "prefix"
							},
							operator = "%",
							right = {
								type = "number",
								value = 2
							},
							type = "binary"
						},
						operator = "==",
						right = {
							type = "number",
							value = 0
						},
						type = "binary"
					},
					elseifs = {},
					type = "if"
				},
				{
					args = {
						{
							inner = "v",
							subtype = "identifier",
							type = "prefix"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				},
				{
					name = "continue",
					type = "label"
				}
			},
			type = "block"
		},
		iterVar = "i",
		max = {
			type = "number",
			value = 10
		},
		min = {
			type = "number",
			value = 1
		},
		type = "forRange"
	},
	["7.11-Control flow-Do"] = {
		body = {
			statements = {
				{
					args = {
						{
							type = "string",
							value = "Hello, World!"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		type = "do"
	},
	["7.2-Control flow-If-Else"] = {
		body = {
			statements = {
				{
					args = {},
					callee = {
						inner = "swap",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		condition = {
			left = {
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "<",
			right = {
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elseBody = {
			statements = {
				{
					args = {
						{
							type = "string",
							value = "Not swapped"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		elseifs = {},
		type = "if"
	},
	["7.3-Control flow-If-Elseif"] = {
		body = {
			statements = {
				{
					args = {},
					callee = {
						inner = "swap",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		condition = {
			left = {
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "<",
			right = {
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elseifs = {
			{
				body = {
					statements = {
						{
							args = {
								{
									type = "string",
									value = "Greater"
								}
							},
							callee = {
								inner = "print",
								subtype = "identifier",
								type = "prefix"
							},
							type = "call"
						}
					},
					type = "block"
				},
				condition = {
					left = {
						inner = "a",
						subtype = "identifier",
						type = "prefix"
					},
					operator = ">",
					right = {
						inner = "b",
						subtype = "identifier",
						type = "prefix"
					},
					type = "binary"
				}
			}
		},
		type = "if"
	},
	["7.4-Control flow-If-Elseif-Else"] = {
		body = {
			statements = {
				{
					args = {},
					callee = {
						inner = "swap",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		condition = {
			left = {
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "<",
			right = {
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elseBody = {
			statements = {
				{
					args = {
						{
							type = "string",
							value = "Equal"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		elseifs = {
			{
				body = {
					statements = {
						{
							args = {
								{
									type = "string",
									value = "Greater"
								}
							},
							callee = {
								inner = "print",
								subtype = "identifier",
								type = "prefix"
							},
							type = "call"
						}
					},
					type = "block"
				},
				condition = {
					left = {
						inner = "a",
						subtype = "identifier",
						type = "prefix"
					},
					operator = ">",
					right = {
						inner = "b",
						subtype = "identifier",
						type = "prefix"
					},
					type = "binary"
				}
			}
		},
		type = "if"
	},
	["7.5-Control flow-While"] = {
		body = {
			statements = {
				{
					args = {
						{
							inner = "val",
							subtype = "identifier",
							type = "prefix"
						},
						{
							operator = "#",
							right = {
								inner = "val",
								subtype = "identifier",
								type = "prefix"
							},
							type = "unary"
						}
					},
					callee = {
						left = {
							inner = "table",
							subtype = "identifier",
							type = "prefix"
						},
						sub = "insert",
						subtype = "dot",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		condition = {
			left = {
				operator = "#",
				right = {
					inner = "val",
					subtype = "identifier",
					type = "prefix"
				},
				type = "unary"
			},
			operator = "<",
			right = {
				inner = "target",
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		type = "while"
	},
	["7.6-Control flow-Repeat Until"] = {
		body = {
			statements = {
				{
					assign = "=",
					isLocal = true,
					type = "assignment",
					values = {
						{
							call = {
								args = {
									{
										left = {
											inner = "math",
											subtype = "identifier",
											type = "prefix"
										},
										sub = "huge",
										subtype = "dot",
										type = "prefix"
									}
								},
								callee = {
									inner = "file",
									subtype = "identifier",
									type = "prefix"
								},
								method = "read",
								type = "call"
							},
							subtype = "call",
							type = "prefix"
						}
					},
					variables = {
						{
							inner = "block",
							subtype = "identifier",
							type = "prefix"
						}
					}
				}
			},
			type = "block"
		},
		condition = {
			left = {
				inner = "block",
				subtype = "identifier",
				type = "prefix"
			},
			operator = "==",
			right = {
				type = "nil"
			},
			type = "binary"
		},
		type = "repeatUntil"
	},
	["7.7-Control flow-Numeric For"] = {
		body = {
			statements = {
				{
					args = {
						{
							inner = "i",
							subtype = "identifier",
							type = "prefix"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		iterVar = "i",
		max = {
			type = "number",
			value = 10
		},
		min = {
			type = "number",
			value = 1
		},
		type = "forRange"
	},
	["7.8-Control flow-Numeric For with Step"] = {
		body = {
			statements = {
				{
					args = {
						{
							inner = "i",
							subtype = "identifier",
							type = "prefix"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		iterVar = "i",
		max = {
			type = "number",
			value = 1
		},
		min = {
			type = "number",
			value = 0
		},
		step = {
			type = "number",
			value = 0.1
		},
		type = "forRange"
	},
	["7.9-Control flow-Iterative For"] = {
		body = {
			statements = {
				{
					args = {
						{
							inner = "v",
							subtype = "identifier",
							type = "prefix"
						}
					},
					callee = {
						inner = "print",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				}
			},
			type = "block"
		},
		expressions = {
			{
				call = {
					args = {
						{
							inner = "args",
							subtype = "identifier",
							type = "prefix"
						}
					},
					callee = {
						inner = "ipairs",
						subtype = "identifier",
						type = "prefix"
					},
					type = "call"
				},
				subtype = "call",
				type = "prefix"
			}
		},
		type = "forIn",
		variables = {
			"i",
			"v"
		}
	},
	["8.1-Statements-Assignment"] = {
		assign = "=",
		isLocal = false,
		type = "assignment",
		values = {
			{
				type = "number",
				value = 1
			},
			{
				type = "number",
				value = 2
			},
			{
				type = "number",
				value = 3
			}
		},
		variables = {
			{
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			{
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			{
				inner = "c",
				subtype = "identifier",
				type = "prefix"
			}
		}
	},
	["8.2-Statements-Local Assignment"] = {
		assign = "=",
		isLocal = true,
		type = "assignment",
		values = {
			{
				type = "number",
				value = 1
			},
			{
				type = "number",
				value = 2
			},
			{
				type = "number",
				value = 3
			}
		},
		variables = {
			{
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			{
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			{
				inner = "c",
				subtype = "identifier",
				type = "prefix"
			}
		}
	},
	["8.3-Statements-Local Declaration"] = {
		assign = "=",
		isLocal = true,
		type = "assignment",
		values = {},
		variables = {
			{
				inner = "a",
				subtype = "identifier",
				type = "prefix"
			},
			{
				inner = "b",
				subtype = "identifier",
				type = "prefix"
			},
			{
				inner = "c",
				subtype = "identifier",
				type = "prefix"
			}
		}
	},
	["8.4-Statements-Function definition"] = {
		impl = {
			body = {
				statements = {
					{
						args = {
							{
								type = "string",
								value = "hi"
							}
						},
						callee = {
							inner = "print",
							subtype = "identifier",
							type = "prefix"
						},
						type = "call"
					}
				},
				type = "block"
			},
			parameters = {},
			rest = false
		},
		name = {
			accesses = {},
			base = {
				inner = "test",
				subtype = "identifier",
				type = "prefix"
			}
		},
		type = "funcDef"
	},
	["8.5-Statements-Function definition on a table"] = {
		statements = {
			{
				assign = "=",
				isLocal = true,
				type = "assignment",
				values = {
					{
						type = "table",
						value = {}
					}
				},
				variables = {
					{
						inner = "lib",
						subtype = "identifier",
						type = "prefix"
					}
				}
			},
			{
				impl = {
					body = {
						statements = {
							{
								args = {
									{
										type = "string",
										value = "hi"
									}
								},
								callee = {
									inner = "print",
									subtype = "identifier",
									type = "prefix"
								},
								type = "call"
							}
						},
						type = "block"
					},
					parameters = {},
					rest = false
				},
				name = {
					accesses = {
						"test"
					},
					base = {
						inner = "lib",
						subtype = "identifier",
						type = "prefix"
					}
				},
				type = "funcDef"
			}
		},
		type = "block"
	},
	["8.6-Statements-Method definition on a table"] = {
		statements = {
			{
				assign = "=",
				isLocal = true,
				type = "assignment",
				values = {
					{
						type = "table",
						value = {}
					}
				},
				variables = {
					{
						inner = "lib",
						subtype = "identifier",
						type = "prefix"
					}
				}
			},
			{
				impl = {
					body = {
						statements = {
							{
								args = {
									{
										inner = "self",
										subtype = "identifier",
										type = "prefix"
									}
								},
								callee = {
									inner = "print",
									subtype = "identifier",
									type = "prefix"
								},
								type = "call"
							}
						},
						type = "block"
					},
					parameters = {},
					rest = false
				},
				name = {
					accesses = {},
					base = {
						inner = "lib",
						subtype = "identifier",
						type = "prefix"
					},
					method = "test"
				},
				type = "funcDef"
			}
		},
		type = "block"
	},
	["8.7-Statements-Local function definition"] = {
		impl = {
			body = {
				statements = {
					{
						args = {
							{
								type = "string",
								value = "hi"
							}
						},
						callee = {
							inner = "print",
							subtype = "identifier",
							type = "prefix"
						},
						type = "call"
					}
				},
				type = "block"
			},
			parameters = {},
			rest = false
		},
		name = "test",
		type = "localFuncDef"
	},
	["8.8-Statements-Return"] = {
		type = "return",
		values = {
			{
				type = "string",
				value = "test"
			},
			{
				type = "bool",
				value = false
			}
		}
	}
}