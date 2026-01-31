--[[ File is auto generated 01/31/26 12:40:12 EST UTC-0500 ]]
return {
	["2.13"] = {
		type = "table",
		value = {
			{
				key = {
					type = "string",
					value = "key"
				},
				value = {
					inner = "value",
					subtype = "identifier",
					type = "prefix"
				}
			}
		}
	},
	["3.1"] = {
		inner = "testIdentifier",
		subtype = "identifier",
		type = "prefix"
	},
	["3.2"] = {
		left = {
			inner = "table",
			subtype = "identifier",
			type = "prefix"
		},
		sub = "insert",
		subtype = "dot",
		type = "prefix"
	},
	["3.3"] = {
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
	["3.4"] = {
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
	["3.5"] = {
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
	["3.6"] = {
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
	["5.1"] = {
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
	["5.2"] = {
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
	["5.3"] = {
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
	["5.4"] = {
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
	["5.5"] = {
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
	["5.6"] = {
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
	["5.7"] = {
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
	["6.1"] = {
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
	["6.10"] = {
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
	["6.11"] = {
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
	["6.2"] = {
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
	["6.3"] = {
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
	["6.4"] = {
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
	["6.5"] = {
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
	["6.6"] = {
		body = {
			statements = {
				{
					type = "localAssignment",
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
								method = {
									index = 7,
									supertype = "token",
									type = "identifier",
									value = "read"
								},
								type = "callMethod"
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
	["6.7"] = {
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
	["6.8"] = {
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
	["6.9"] = {
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
	["7.1"] = {
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
	["7.2"] = {
		type = "localAssignment",
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
	["7.3"] = {
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
			base = "test"
		},
		type = "funcDef"
	},
	["7.4"] = {
		statements = {
			{
				type = "localAssignment",
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
					base = "lib"
				},
				type = "funcDef"
			}
		},
		type = "block"
	},
	["7.5"] = {
		statements = {
			{
				type = "localAssignment",
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
					base = "lib",
					method = "test"
				},
				type = "funcDef"
			}
		},
		type = "block"
	},
	["7.6"] = {
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
	}
}