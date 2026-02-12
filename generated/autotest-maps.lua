--[[ File is auto generated 02/12/26 18:03:37 EST UTC-0500 ]]
return {
	["1.1-Table literals-Empty"] = {
		closeBrace = {
			index = 2,
			span = {
				start = 2,
				stop = 2,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {},
			values = {}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.2-Table literals-Ident keys"] = {
		closeBrace = {
			index = 9,
			span = {
				start = 16,
				stop = 16,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 5,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					key = {
						type = "string",
						value = "a"
					},
					tokens = {
						assign = {
							index = 3,
							span = {
								start = 3,
								stop = 3,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						type = "identifier"
					},
					value = {
						index = 4,
						span = {
							start = 4,
							stop = 7,
							unit = "char"
						},
						supertype = "token",
						type = "boolean",
						value = true
					}
				},
				{
					key = {
						type = "string",
						value = "b"
					},
					tokens = {
						assign = {
							index = 7,
							span = {
								start = 10,
								stop = 10,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						type = "identifier"
					},
					value = {
						index = 8,
						span = {
							start = 11,
							stop = 15,
							unit = "char"
						},
						supertype = "token",
						type = "boolean",
						value = false
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.3-Table literals-Expr keys"] = {
		closeBrace = {
			index = 19,
			span = {
				start = 33,
				stop = 33,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 7,
					span = {
						start = 12,
						stop = 12,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 13,
					span = {
						start = 22,
						stop = 22,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					key = {
						index = 3,
						span = {
							start = 3,
							stop = 5,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "a"
					},
					tokens = {
						assign = {
							index = 5,
							span = {
								start = 7,
								stop = 7,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						closeBracket = {
							index = 4,
							span = {
								start = 6,
								stop = 6,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "]"
						},
						openBracket = {
							index = 2,
							span = {
								start = 2,
								stop = 2,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "["
						},
						type = "expression"
					},
					value = {
						index = 6,
						span = {
							start = 8,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "boolean",
						value = true
					}
				},
				{
					key = {
						index = 9,
						span = {
							start = 14,
							stop = 14,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 5
					},
					tokens = {
						assign = {
							index = 11,
							span = {
								start = 16,
								stop = 16,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						closeBracket = {
							index = 10,
							span = {
								start = 15,
								stop = 15,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "]"
						},
						openBracket = {
							index = 8,
							span = {
								start = 13,
								stop = 13,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "["
						},
						type = "expression"
					},
					value = {
						index = 12,
						span = {
							start = 17,
							stop = 21,
							unit = "char"
						},
						supertype = "token",
						type = "boolean",
						value = false
					}
				},
				{
					key = {
						index = 15,
						span = {
							start = 24,
							stop = 27,
							unit = "char"
						},
						supertype = "token",
						type = "boolean",
						value = true
					},
					tokens = {
						assign = {
							index = 17,
							span = {
								start = 29,
								stop = 29,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						closeBracket = {
							index = 16,
							span = {
								start = 28,
								stop = 28,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "]"
						},
						openBracket = {
							index = 14,
							span = {
								start = 23,
								stop = 23,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "["
						},
						type = "expression"
					},
					value = {
						index = 18,
						span = {
							start = 30,
							stop = 32,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "a"
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.4-Table literals-Auto keys"] = {
		closeBrace = {
			index = 7,
			span = {
				start = 7,
				stop = 7,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 3,
					span = {
						start = 3,
						stop = 3,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 5,
					span = {
						start = 5,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					key = {
						type = "number",
						value = 1
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 2,
						span = {
							start = 2,
							stop = 2,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 1
					}
				},
				{
					key = {
						type = "number",
						value = 2
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 4,
						span = {
							start = 4,
							stop = 4,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 2
					}
				},
				{
					key = {
						type = "number",
						value = 3
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 6,
						span = {
							start = 6,
							stop = 6,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 3
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.5-Table literals-Semicolons"] = {
		closeBrace = {
			index = 9,
			span = {
				start = 9,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 5,
					span = {
						start = 5,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ";"
				}
			},
			values = {
				{
					key = {
						type = "string",
						value = "x"
					},
					tokens = {
						assign = {
							index = 3,
							span = {
								start = 3,
								stop = 3,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						type = "identifier"
					},
					value = {
						index = 4,
						span = {
							start = 4,
							stop = 4,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 1
					}
				},
				{
					key = {
						type = "string",
						value = "y"
					},
					tokens = {
						assign = {
							index = 7,
							span = {
								start = 7,
								stop = 7,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						type = "identifier"
					},
					value = {
						index = 8,
						span = {
							start = 8,
							stop = 8,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 1
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.6-Table literals-Trailing Separator"] = {
		closeBrace = {
			index = 8,
			span = {
				start = 8,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 3,
					span = {
						start = 3,
						stop = 3,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 5,
					span = {
						start = 5,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 7,
					span = {
						start = 7,
						stop = 7,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					key = {
						type = "number",
						value = 1
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 2,
						span = {
							start = 2,
							stop = 2,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 1
					}
				},
				{
					key = {
						type = "number",
						value = 2
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 4,
						span = {
							start = 4,
							stop = 4,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 2
					}
				},
				{
					key = {
						type = "number",
						value = 3
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 6,
						span = {
							start = 6,
							stop = 6,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 3
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.7-Table literals-Mixed keys"] = {
		closeBrace = {
			index = 17,
			span = {
				start = 63,
				stop = 63,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 3,
					span = {
						start = 5,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 5,
					span = {
						start = 9,
						stop = 9,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 7,
					span = {
						start = 13,
						stop = 13,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 11,
					span = {
						start = 35,
						stop = 35,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					key = {
						type = "number",
						value = 1
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 2,
						span = {
							start = 2,
							stop = 4,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "a"
					}
				},
				{
					key = {
						type = "number",
						value = 2
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 4,
						span = {
							start = 6,
							stop = 8,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "b"
					}
				},
				{
					key = {
						type = "number",
						value = 3
					},
					tokens = {
						type = "auto"
					},
					value = {
						index = 6,
						span = {
							start = 10,
							stop = 12,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "c"
					}
				},
				{
					key = {
						type = "string",
						value = "__name"
					},
					tokens = {
						assign = {
							index = 9,
							span = {
								start = 20,
								stop = 20,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						type = "identifier"
					},
					value = {
						index = 10,
						span = {
							start = 21,
							stop = 34,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "example list"
					}
				},
				{
					key = {
						index = 13,
						span = {
							start = 37,
							stop = 38,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = -1
					},
					tokens = {
						assign = {
							index = 15,
							span = {
								start = 40,
								stop = 40,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						closeBracket = {
							index = 14,
							span = {
								start = 39,
								stop = 39,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "]"
						},
						openBracket = {
							index = 12,
							span = {
								start = 36,
								stop = 36,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "["
						},
						type = "expression"
					},
					value = {
						index = 16,
						span = {
							start = 41,
							stop = 62,
							unit = "char"
						},
						supertype = "token",
						type = "string",
						value = "How did we get here?"
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["1.8-Table literals-Nesting"] = {
		closeBrace = {
			index = 15,
			span = {
				start = 44,
				stop = 44,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "}"
		},
		fields = {
			separators = {
				{
					index = 12,
					span = {
						start = 41,
						stop = 41,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					key = {
						type = "number",
						value = 1
					},
					tokens = {
						type = "auto"
					},
					value = {
						closeBrace = {
							index = 11,
							span = {
								start = 40,
								stop = 40,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "}"
						},
						fields = {
							separators = {
								{
									index = 6,
									span = {
										start = 29,
										stop = 29,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = ","
								}
							},
							values = {
								{
									key = {
										type = "string",
										value = "groupName"
									},
									tokens = {
										assign = {
											index = 4,
											span = {
												start = 12,
												stop = 12,
												unit = "char"
											},
											supertype = "token",
											type = "assign",
											value = "="
										},
										type = "identifier"
									},
									value = {
										index = 5,
										span = {
											start = 13,
											stop = 28,
											unit = "char"
										},
										supertype = "token",
										type = "string",
										value = "Table Literals"
									}
								},
								{
									key = {
										type = "string",
										value = "members"
									},
									tokens = {
										assign = {
											index = 8,
											span = {
												start = 37,
												stop = 37,
												unit = "char"
											},
											supertype = "token",
											type = "assign",
											value = "="
										},
										type = "identifier"
									},
									value = {
										closeBrace = {
											index = 10,
											span = {
												start = 39,
												stop = 39,
												unit = "char"
											},
											supertype = "token",
											type = "symbol",
											value = "}"
										},
										fields = {
											separators = {},
											values = {}
										},
										openBrace = {
											index = 9,
											span = {
												start = 38,
												stop = 38,
												unit = "char"
											},
											supertype = "token",
											type = "symbol",
											value = "{"
										}
									}
								}
							}
						},
						openBrace = {
							index = 2,
							span = {
								start = 2,
								stop = 2,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "{"
						}
					}
				},
				{
					key = {
						type = "number",
						value = 2
					},
					tokens = {
						type = "auto"
					},
					value = {
						closeBrace = {
							index = 14,
							span = {
								start = 43,
								stop = 43,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "}"
						},
						fields = {
							separators = {},
							values = {}
						},
						openBrace = {
							index = 13,
							span = {
								start = 42,
								stop = 42,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "{"
						}
					}
				}
			}
		},
		openBrace = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "{"
		}
	},
	["2.1-String Literals-Base"] = {
		index = 1,
		span = {
			start = 1,
			stop = 15,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "Hello, World!"
	},
	["2.10-String Literals-Long Literals Assimilate Newlines"] = {
		index = 1,
		span = {
			start = 1,
			stop = 9,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "abc\n"
	},
	["2.2-String Literals-Long Literal"] = {
		index = 1,
		span = {
			start = 2,
			stop = 22,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "Hello, \"World!\""
	},
	["2.3-String Literals-Escapes"] = {
		index = 1,
		span = {
			start = 1,
			stop = 22,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "\a\b\f\n\r\t\v\\\"'"
	},
	["2.4-String Literals-Whitespace-skipping Escape"] = {
		index = 1,
		span = {
			start = 1,
			stop = 11,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "abc"
	},
	["2.5-String Literals-Decimal Escape"] = {
		index = 1,
		span = {
			start = 1,
			stop = 9,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "\x1b[31m"
	},
	["2.6-String Literals-Hexadecimal Escape"] = {
		index = 1,
		span = {
			start = 1,
			stop = 10,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "\x1b[31m"
	},
	["2.7-String Literals-Unicode Escape"] = {
		index = 1,
		span = {
			start = 1,
			stop = 11,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "\xf0\x9f\x98\x80"
	},
	["2.8-String Literals-No Escapes in Long Literal"] = {
		index = 1,
		span = {
			start = 2,
			stop = 7,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "\\\""
	},
	["2.9-String Literals-Long Literals Skip First Newline"] = {
		index = 1,
		span = {
			start = 1,
			stop = 8,
			unit = "char"
		},
		supertype = "token",
		type = "string",
		value = "abc"
	},
	["3.1-Other Literals-Nil Literal"] = {
		index = 1,
		span = {
			start = 1,
			stop = 3,
			unit = "char"
		},
		supertype = "token",
		type = "nil"
	},
	["3.11-Other Literals-Line Comment"] = {
		index = 1,
		span = {
			start = 22,
			stop = 24,
			unit = "char"
		},
		supertype = "token",
		type = "nil"
	},
	["3.12-Other Literals-Block Comment"] = {
		index = 1,
		span = {
			start = 28,
			stop = 30,
			unit = "char"
		},
		supertype = "token",
		type = "nil"
	},
	["3.2-Other Literals-Bool Literal"] = {
		index = 1,
		span = {
			start = 1,
			stop = 4,
			unit = "char"
		},
		supertype = "token",
		type = "boolean",
		value = true
	},
	["3.3-Other Literals-Integer Literal"] = {
		index = 1,
		span = {
			start = 1,
			stop = 3,
			unit = "char"
		},
		supertype = "token",
		type = "number",
		value = 321
	},
	["3.4-Other Literals-Float Literal"] = {
		index = 1,
		span = {
			start = 1,
			stop = 4,
			unit = "char"
		},
		supertype = "token",
		type = "number",
		value = 3.14
	},
	["3.5-Other Literals-Decimal Scientific Notation"] = {
		index = 1,
		span = {
			start = 1,
			stop = 4,
			unit = "char"
		},
		supertype = "token",
		type = "number",
		value = 0.001
	},
	["3.6-Other Literals-Hexadecimal Integer Literal"] = {
		index = 1,
		span = {
			start = 1,
			stop = 4,
			unit = "char"
		},
		supertype = "token",
		type = "number",
		value = 255
	},
	["3.7-Other Literals-Hexadecimal Float Literal"] = {
		index = 1,
		span = {
			start = 1,
			stop = 6,
			unit = "char"
		},
		supertype = "token",
		type = "number",
		value = 255.625
	},
	["3.8-Other Literals-Hexadecimal Scientific Notation"] = {
		index = 1,
		span = {
			start = 1,
			stop = 5,
			unit = "char"
		},
		supertype = "token",
		type = "number",
		value = 512.0
	},
	["4.1-Prefix Expressions-Identifier Access"] = {
		inner = {
			index = 1,
			span = {
				start = 1,
				stop = 14,
				unit = "char"
			},
			supertype = "token",
			type = "identifier",
			value = "testIdentifier"
		},
		subtype = "identifier",
		type = "prefix"
	},
	["4.2-Prefix Expressions-Dot Access"] = {
		left = {
			inner = {
				index = 1,
				span = {
					start = 1,
					stop = 5,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "table"
			},
			subtype = "identifier",
			type = "prefix"
		},
		sub = "insert",
		subtype = "dot",
		type = "prefix"
	},
	["4.3-Prefix Expressions-Index Access"] = {
		left = {
			inner = {
				index = 1,
				span = {
					start = 1,
					stop = 8,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "elements"
			},
			subtype = "identifier",
			type = "prefix"
		},
		sub = {
			inner = {
				index = 3,
				span = {
					start = 10,
					stop = 10,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "i"
			},
			subtype = "identifier",
			type = "prefix"
		},
		subtype = "index",
		type = "prefix"
	},
	["4.4-Prefix Expressions-Call"] = {
		call = {
			args = {
				arguments = {
					separators = {},
					values = {
						{
							index = 5,
							span = {
								start = 14,
								stop = 16,
								unit = "char"
							},
							supertype = "token",
							type = "string",
							value = "a"
						}
					}
				},
				closeParen = {
					index = 6,
					span = {
						start = 17,
						stop = 17,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				openParen = {
					index = 4,
					span = {
						start = 13,
						stop = 13,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
				},
				type = "parenthesis"
			},
			callee = {
				left = {
					inner = {
						index = 1,
						span = {
							start = 1,
							stop = 5,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "table"
					},
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
				arguments = {
					separators = {},
					values = {
						{
							index = 5,
							span = {
								start = 11,
								stop = 13,
								unit = "char"
							},
							supertype = "token",
							type = "string",
							value = "a"
						}
					}
				},
				closeParen = {
					index = 6,
					span = {
						start = 14,
						stop = 14,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				openParen = {
					index = 4,
					span = {
						start = 10,
						stop = 10,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
				},
				type = "parenthesis"
			},
			callee = {
				inner = {
					index = 1,
					span = {
						start = 1,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "self"
				},
				subtype = "identifier",
				type = "prefix"
			},
			method = {
				name = {
					index = 3,
					span = {
						start = 6,
						stop = 9,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "info"
				},
				token = {
					index = 2,
					span = {
						start = 5,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ":"
				}
			},
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["4.6-Prefix Expressions-Access-Method Call"] = {
		call = {
			args = {
				arguments = {
					separators = {},
					values = {
						{
							index = 7,
							span = {
								start = 25,
								stop = 27,
								unit = "char"
							},
							supertype = "token",
							type = "string",
							value = "a"
						}
					}
				},
				closeParen = {
					index = 8,
					span = {
						start = 28,
						stop = 28,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				openParen = {
					index = 6,
					span = {
						start = 24,
						stop = 24,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
				},
				type = "parenthesis"
			},
			callee = {
				left = {
					inner = {
						index = 1,
						span = {
							start = 1,
							stop = 4,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "self"
					},
					subtype = "identifier",
					type = "prefix"
				},
				sub = "helpGenerator",
				subtype = "dot",
				type = "prefix"
			},
			method = {
				name = {
					index = 5,
					span = {
						start = 20,
						stop = 23,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "info"
				},
				token = {
					index = 4,
					span = {
						start = 19,
						stop = 19,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ":"
				}
			},
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["4.7-Prefix Expressions-Group"] = {
		closeParen = {
			index = 5,
			span = {
				start = 5,
				stop = 5,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = ")"
		},
		inner = {
			left = {
				index = 2,
				span = {
					start = 2,
					stop = 2,
					unit = "char"
				},
				supertype = "token",
				type = "number",
				value = 1
			},
			operator = {
				index = 3,
				span = {
					start = 3,
					stop = 3,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "+"
			},
			right = {
				index = 4,
				span = {
					start = 4,
					stop = 4,
					unit = "char"
				},
				supertype = "token",
				type = "number",
				value = 1
			},
			type = "binary"
		},
		openParen = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "symbol",
			value = "("
		},
		subtype = "group",
		type = "prefix"
	},
	["4.8-Prefix Expressions-IIFE"] = {
		call = {
			args = {
				arguments = {
					separators = {},
					values = {}
				},
				closeParen = {
					index = 12,
					span = {
						start = 30,
						stop = 30,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				openParen = {
					index = 11,
					span = {
						start = 29,
						stop = 29,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
				},
				type = "parenthesis"
			},
			callee = {
				closeParen = {
					index = 10,
					span = {
						start = 28,
						stop = 28,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				inner = {
					impl = {
						body = {
							statements = {
								{
									args = {
										arguments = {
											separators = {},
											values = {
												{
													index = 7,
													span = {
														start = 19,
														stop = 22,
														unit = "char"
													},
													supertype = "token",
													type = "string",
													value = "hi"
												}
											}
										},
										closeParen = {
											index = 8,
											span = {
												start = 23,
												stop = 23,
												unit = "char"
											},
											supertype = "token",
											type = "symbol",
											value = ")"
										},
										openParen = {
											index = 6,
											span = {
												start = 18,
												stop = 18,
												unit = "char"
											},
											supertype = "token",
											type = "symbol",
											value = "("
										},
										type = "parenthesis"
									},
									callee = {
										inner = {
											index = 5,
											span = {
												start = 13,
												stop = 17,
												unit = "char"
											},
											supertype = "token",
											type = "identifier",
											value = "print"
										},
										subtype = "identifier",
										type = "prefix"
									},
									type = "call"
								}
							},
							type = "block"
						},
						closeParen = {
							index = 4,
							span = {
								start = 11,
								stop = 11,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						endToken = {
							index = 9,
							span = {
								start = 25,
								stop = 27,
								unit = "char"
							},
							supertype = "token",
							type = "keyword",
							value = "end"
						},
						openParen = {
							index = 3,
							span = {
								start = 10,
								stop = 10,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						parameters = {
							separators = {},
							values = {}
						}
					},
					type = "funcDef"
				},
				openParen = {
					index = 1,
					span = {
						start = 1,
						stop = 1,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
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
				arguments = {
					separators = {},
					values = {
						{
							index = 5,
							span = {
								start = 9,
								stop = 12,
								unit = "char"
							},
							supertype = "token",
							type = "string",
							value = "Hi"
						}
					}
				},
				closeParen = {
					index = 6,
					span = {
						start = 13,
						stop = 13,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				openParen = {
					index = 4,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
				},
				type = "parenthesis"
			},
			callee = {
				closeParen = {
					index = 3,
					span = {
						start = 7,
						stop = 7,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ")"
				},
				inner = {
					inner = {
						index = 2,
						span = {
							start = 2,
							stop = 6,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "print"
					},
					subtype = "identifier",
					type = "prefix"
				},
				openParen = {
					index = 1,
					span = {
						start = 1,
						stop = 1,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = "("
				},
				subtype = "group",
				type = "prefix"
			},
			type = "call"
		},
		subtype = "call",
		type = "prefix"
	},
	["5.1-Unary Expressions-Negation"] = {
		operator = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "-"
		},
		right = {
			index = 2,
			span = {
				start = 3,
				stop = 3,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 3
		},
		type = "unary"
	},
	["5.2-Unary Expressions-Boolean Not"] = {
		operator = {
			index = 1,
			span = {
				start = 1,
				stop = 3,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "not"
		},
		right = {
			index = 2,
			span = {
				start = 5,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "boolean",
			value = true
		},
		type = "unary"
	},
	["5.3-Unary Expressions-Length"] = {
		operator = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "#"
		},
		right = {
			inner = {
				index = 2,
				span = {
					start = 2,
					stop = 7,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "string"
			},
			subtype = "identifier",
			type = "prefix"
		},
		type = "unary"
	},
	["5.4-Unary Expressions-Bitwise NOT"] = {
		operator = {
			index = 1,
			span = {
				start = 1,
				stop = 1,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "~"
		},
		right = {
			index = 2,
			span = {
				start = 2,
				stop = 2,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 3
		},
		type = "unary"
	},
	["6.1-Binary Expressions-Equality"] = {
		left = {
			inner = {
				index = 1,
				span = {
					start = 1,
					stop = 5,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "input"
			},
			subtype = "identifier",
			type = "prefix"
		},
		operator = {
			index = 2,
			span = {
				start = 7,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "=="
		},
		right = {
			index = 3,
			span = {
				start = 10,
				stop = 15,
				unit = "char"
			},
			supertype = "token",
			type = "string",
			value = "test"
		},
		type = "binary"
	},
	["6.10-Binary Expressions-Boolean OR"] = {
		left = {
			left = {
				left = {
					inner = {
						index = 1,
						span = {
							start = 1,
							stop = 1,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "a"
					},
					subtype = "identifier",
					type = "prefix"
				},
				operator = {
					index = 2,
					span = {
						start = 3,
						stop = 3,
						unit = "char"
					},
					supertype = "token",
					type = "operator",
					value = "<"
				},
				right = {
					inner = {
						index = 3,
						span = {
							start = 5,
							stop = 5,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "b"
					},
					subtype = "identifier",
					type = "prefix"
				},
				type = "binary"
			},
			operator = {
				index = 4,
				span = {
					start = 7,
					stop = 9,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "and"
			},
			right = {
				left = {
					inner = {
						index = 5,
						span = {
							start = 11,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "b"
					},
					subtype = "identifier",
					type = "prefix"
				},
				operator = {
					index = 6,
					span = {
						start = 13,
						stop = 13,
						unit = "char"
					},
					supertype = "token",
					type = "operator",
					value = "<"
				},
				right = {
					inner = {
						index = 7,
						span = {
							start = 15,
							stop = 15,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "c"
					},
					subtype = "identifier",
					type = "prefix"
				},
				type = "binary"
			},
			type = "binary"
		},
		operator = {
			index = 8,
			span = {
				start = 17,
				stop = 18,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "or"
		},
		right = {
			inner = {
				index = 9,
				span = {
					start = 20,
					stop = 27,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "override"
			},
			subtype = "identifier",
			type = "prefix"
		},
		type = "binary"
	},
	["6.11-Binary Expressions-Concatenation"] = {
		left = {
			index = 1,
			span = {
				start = 1,
				stop = 7,
				unit = "char"
			},
			supertype = "token",
			type = "string",
			value = "Lorem"
		},
		operator = {
			index = 2,
			span = {
				start = 9,
				stop = 10,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = ".."
		},
		right = {
			index = 3,
			span = {
				start = 12,
				stop = 18,
				unit = "char"
			},
			supertype = "token",
			type = "string",
			value = "Ipsum"
		},
		type = "binary"
	},
	["6.2-Binary Expressions-Inquality"] = {
		left = {
			inner = {
				index = 1,
				span = {
					start = 1,
					stop = 5,
					unit = "char"
				},
				supertype = "token",
				type = "identifier",
				value = "input"
			},
			subtype = "identifier",
			type = "prefix"
		},
		operator = {
			index = 2,
			span = {
				start = 7,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "~="
		},
		right = {
			index = 3,
			span = {
				start = 10,
				stop = 15,
				unit = "char"
			},
			supertype = "token",
			type = "string",
			value = "test"
		},
		type = "binary"
	},
	["6.3-Binary Expressions-Less"] = {
		left = {
			operator = {
				index = 1,
				span = {
					start = 1,
					stop = 1,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "#"
			},
			right = {
				inner = {
					index = 2,
					span = {
						start = 2,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "tbl"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = {
			index = 3,
			span = {
				start = 6,
				stop = 6,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "<"
		},
		right = {
			index = 4,
			span = {
				start = 8,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.4-Binary Expressions-Less-Equal"] = {
		left = {
			operator = {
				index = 1,
				span = {
					start = 1,
					stop = 1,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "#"
			},
			right = {
				inner = {
					index = 2,
					span = {
						start = 2,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "tbl"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = {
			index = 3,
			span = {
				start = 6,
				stop = 7,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "<="
		},
		right = {
			index = 4,
			span = {
				start = 9,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.5-Binary Expressions-Greater"] = {
		left = {
			operator = {
				index = 1,
				span = {
					start = 1,
					stop = 1,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "#"
			},
			right = {
				inner = {
					index = 2,
					span = {
						start = 2,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "tbl"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = {
			index = 3,
			span = {
				start = 6,
				stop = 6,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = ">"
		},
		right = {
			index = 4,
			span = {
				start = 8,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.6-Binary Expressions-Greater-Equal"] = {
		left = {
			operator = {
				index = 1,
				span = {
					start = 1,
					stop = 1,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "#"
			},
			right = {
				inner = {
					index = 2,
					span = {
						start = 2,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "tbl"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "unary"
		},
		operator = {
			index = 3,
			span = {
				start = 6,
				stop = 7,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = ">="
		},
		right = {
			index = 4,
			span = {
				start = 9,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 3
		},
		type = "binary"
	},
	["6.7-Binary Expressions-Term"] = {
		left = {
			left = {
				index = 1,
				span = {
					start = 1,
					stop = 1,
					unit = "char"
				},
				supertype = "token",
				type = "number",
				value = 1
			},
			operator = {
				index = 2,
				span = {
					start = 3,
					stop = 3,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "+"
			},
			right = {
				index = 3,
				span = {
					start = 5,
					stop = 5,
					unit = "char"
				},
				supertype = "token",
				type = "number",
				value = 2
			},
			type = "binary"
		},
		operator = {
			index = 4,
			span = {
				start = 7,
				stop = 7,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "-"
		},
		right = {
			index = 5,
			span = {
				start = 9,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
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
						index = 1,
						span = {
							start = 1,
							stop = 1,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 3
					},
					operator = {
						index = 2,
						span = {
							start = 3,
							stop = 3,
							unit = "char"
						},
						supertype = "token",
						type = "operator",
						value = "*"
					},
					right = {
						index = 3,
						span = {
							start = 5,
							stop = 5,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 2
					},
					type = "binary"
				},
				operator = {
					index = 4,
					span = {
						start = 7,
						stop = 7,
						unit = "char"
					},
					supertype = "token",
					type = "operator",
					value = "/"
				},
				right = {
					index = 5,
					span = {
						start = 9,
						stop = 9,
						unit = "char"
					},
					supertype = "token",
					type = "number",
					value = 3
				},
				type = "binary"
			},
			operator = {
				index = 6,
				span = {
					start = 11,
					stop = 11,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "%"
			},
			right = {
				index = 7,
				span = {
					start = 13,
					stop = 13,
					unit = "char"
				},
				supertype = "token",
				type = "number",
				value = 4
			},
			type = "binary"
		},
		operator = {
			index = 8,
			span = {
				start = 15,
				stop = 16,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "//"
		},
		right = {
			index = 9,
			span = {
				start = 18,
				stop = 18,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 2
		},
		type = "binary"
	},
	["6.9-Binary Expressions-Boolean AND"] = {
		left = {
			left = {
				inner = {
					index = 1,
					span = {
						start = 1,
						stop = 1,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "a"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 2,
				span = {
					start = 3,
					stop = 3,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 3,
					span = {
						start = 5,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "b"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		operator = {
			index = 4,
			span = {
				start = 7,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
			type = "operator",
			value = "and"
		},
		right = {
			left = {
				inner = {
					index = 5,
					span = {
						start = 11,
						stop = 11,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "b"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 6,
				span = {
					start = 13,
					stop = 13,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 7,
					span = {
						start = 15,
						stop = 15,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "c"
				},
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
					args = {
						arguments = {
							separators = {},
							values = {}
						},
						closeParen = {
							index = 8,
							span = {
								start = 20,
								stop = 20,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 7,
							span = {
								start = 19,
								stop = 19,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 6,
							span = {
								start = 15,
								stop = 18,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "swap"
						},
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
				inner = {
					index = 2,
					span = {
						start = 4,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "a"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 3,
				span = {
					start = 6,
					stop = 6,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 4,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "b"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elseifs = {},
		endToken = {
			index = 9,
			span = {
				start = 22,
				stop = 24,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "end"
		},
		ifToken = {
			index = 1,
			span = {
				start = 1,
				stop = 2,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "if"
		},
		thenToken = {
			index = 5,
			span = {
				start = 10,
				stop = 13,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "then"
		},
		type = "if"
	},
	["7.10-Control flow-Goto"] = {
		body = {
			statements = {
				{
					body = {
						statements = {
							{
								destination = {
									index = 16,
									span = {
										start = 50,
										stop = 57,
										unit = "char"
									},
									supertype = "token",
									type = "identifier",
									value = "continue"
								},
								token = {
									index = 15,
									span = {
										start = 45,
										stop = 48,
										unit = "char"
									},
									supertype = "token",
									type = "keyword",
									value = "goto"
								},
								type = "goto"
							}
						},
						type = "block"
					},
					condition = {
						left = {
							left = {
								inner = {
									index = 9,
									span = {
										start = 29,
										stop = 29,
										unit = "char"
									},
									supertype = "token",
									type = "identifier",
									value = "i"
								},
								subtype = "identifier",
								type = "prefix"
							},
							operator = {
								index = 10,
								span = {
									start = 31,
									stop = 31,
									unit = "char"
								},
								supertype = "token",
								type = "operator",
								value = "%"
							},
							right = {
								index = 11,
								span = {
									start = 33,
									stop = 33,
									unit = "char"
								},
								supertype = "token",
								type = "number",
								value = 2
							},
							type = "binary"
						},
						operator = {
							index = 12,
							span = {
								start = 35,
								stop = 36,
								unit = "char"
							},
							supertype = "token",
							type = "operator",
							value = "=="
						},
						right = {
							index = 13,
							span = {
								start = 38,
								stop = 38,
								unit = "char"
							},
							supertype = "token",
							type = "number",
							value = 0
						},
						type = "binary"
					},
					elseifs = {},
					endToken = {
						index = 17,
						span = {
							start = 59,
							stop = 61,
							unit = "char"
						},
						supertype = "token",
						type = "keyword",
						value = "end"
					},
					ifToken = {
						index = 8,
						span = {
							start = 26,
							stop = 27,
							unit = "char"
						},
						supertype = "token",
						type = "keyword",
						value = "if"
					},
					thenToken = {
						index = 14,
						span = {
							start = 40,
							stop = 43,
							unit = "char"
						},
						supertype = "token",
						type = "keyword",
						value = "then"
					},
					type = "if"
				},
				{
					args = {
						arguments = {
							separators = {},
							values = {
								{
									inner = {
										index = 20,
										span = {
											start = 74,
											stop = 74,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "v"
									},
									subtype = "identifier",
									type = "prefix"
								}
							}
						},
						closeParen = {
							index = 21,
							span = {
								start = 75,
								stop = 75,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 19,
							span = {
								start = 73,
								stop = 73,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 18,
							span = {
								start = 68,
								stop = 72,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "print"
						},
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
			index = 6,
			span = {
				start = 15,
				stop = 16,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 10
		},
		min = {
			index = 4,
			span = {
				start = 13,
				stop = 13,
				unit = "char"
			},
			supertype = "token",
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
						arguments = {
							separators = {},
							values = {
								{
									index = 4,
									span = {
										start = 10,
										stop = 24,
										unit = "char"
									},
									supertype = "token",
									type = "string",
									value = "Hello, World!"
								}
							}
						},
						closeParen = {
							index = 5,
							span = {
								start = 25,
								stop = 25,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 3,
							span = {
								start = 9,
								stop = 9,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 2,
							span = {
								start = 4,
								stop = 8,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "print"
						},
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
					args = {
						arguments = {
							separators = {},
							values = {}
						},
						closeParen = {
							index = 8,
							span = {
								start = 20,
								stop = 20,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 7,
							span = {
								start = 19,
								stop = 19,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 6,
							span = {
								start = 15,
								stop = 18,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "swap"
						},
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
				inner = {
					index = 2,
					span = {
						start = 4,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "a"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 3,
				span = {
					start = 6,
					stop = 6,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 4,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "b"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elsePart = {
			body = {
				statements = {
					{
						args = {
							arguments = {
								separators = {},
								values = {
									{
										index = 12,
										span = {
											start = 33,
											stop = 45,
											unit = "char"
										},
										supertype = "token",
										type = "string",
										value = "Not swapped"
									}
								}
							},
							closeParen = {
								index = 13,
								span = {
									start = 46,
									stop = 46,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = ")"
							},
							openParen = {
								index = 11,
								span = {
									start = 32,
									stop = 32,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = "("
							},
							type = "parenthesis"
						},
						callee = {
							inner = {
								index = 10,
								span = {
									start = 27,
									stop = 31,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "print"
							},
							subtype = "identifier",
							type = "prefix"
						},
						type = "call"
					}
				},
				type = "block"
			},
			token = {
				index = 9,
				span = {
					start = 22,
					stop = 25,
					unit = "char"
				},
				supertype = "token",
				type = "keyword",
				value = "else"
			}
		},
		elseifs = {},
		endToken = {
			index = 14,
			span = {
				start = 48,
				stop = 50,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "end"
		},
		ifToken = {
			index = 1,
			span = {
				start = 1,
				stop = 2,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "if"
		},
		thenToken = {
			index = 5,
			span = {
				start = 10,
				stop = 13,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "then"
		},
		type = "if"
	},
	["7.3-Control flow-If-Elseif"] = {
		body = {
			statements = {
				{
					args = {
						arguments = {
							separators = {},
							values = {}
						},
						closeParen = {
							index = 8,
							span = {
								start = 20,
								stop = 20,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 7,
							span = {
								start = 19,
								stop = 19,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 6,
							span = {
								start = 15,
								stop = 18,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "swap"
						},
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
				inner = {
					index = 2,
					span = {
						start = 4,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "a"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 3,
				span = {
					start = 6,
					stop = 6,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 4,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "b"
				},
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
								arguments = {
									separators = {},
									values = {
										{
											index = 16,
											span = {
												start = 46,
												stop = 54,
												unit = "char"
											},
											supertype = "token",
											type = "string",
											value = "Greater"
										}
									}
								},
								closeParen = {
									index = 17,
									span = {
										start = 55,
										stop = 55,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = ")"
								},
								openParen = {
									index = 15,
									span = {
										start = 45,
										stop = 45,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = "("
								},
								type = "parenthesis"
							},
							callee = {
								inner = {
									index = 14,
									span = {
										start = 40,
										stop = 44,
										unit = "char"
									},
									supertype = "token",
									type = "identifier",
									value = "print"
								},
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
						inner = {
							index = 10,
							span = {
								start = 29,
								stop = 29,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "a"
						},
						subtype = "identifier",
						type = "prefix"
					},
					operator = {
						index = 11,
						span = {
							start = 31,
							stop = 31,
							unit = "char"
						},
						supertype = "token",
						type = "operator",
						value = ">"
					},
					right = {
						inner = {
							index = 12,
							span = {
								start = 33,
								stop = 33,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "b"
						},
						subtype = "identifier",
						type = "prefix"
					},
					type = "binary"
				},
				elseifToken = {
					index = 9,
					span = {
						start = 22,
						stop = 27,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "elseif"
				},
				thenToken = {
					index = 13,
					span = {
						start = 35,
						stop = 38,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "then"
				}
			}
		},
		endToken = {
			index = 18,
			span = {
				start = 57,
				stop = 59,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "end"
		},
		ifToken = {
			index = 1,
			span = {
				start = 1,
				stop = 2,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "if"
		},
		thenToken = {
			index = 5,
			span = {
				start = 10,
				stop = 13,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "then"
		},
		type = "if"
	},
	["7.4-Control flow-If-Elseif-Else"] = {
		body = {
			statements = {
				{
					args = {
						arguments = {
							separators = {},
							values = {}
						},
						closeParen = {
							index = 8,
							span = {
								start = 20,
								stop = 20,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 7,
							span = {
								start = 19,
								stop = 19,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 6,
							span = {
								start = 15,
								stop = 18,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "swap"
						},
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
				inner = {
					index = 2,
					span = {
						start = 4,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "a"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 3,
				span = {
					start = 6,
					stop = 6,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 4,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "b"
				},
				subtype = "identifier",
				type = "prefix"
			},
			type = "binary"
		},
		elsePart = {
			body = {
				statements = {
					{
						args = {
							arguments = {
								separators = {},
								values = {
									{
										index = 21,
										span = {
											start = 68,
											stop = 74,
											unit = "char"
										},
										supertype = "token",
										type = "string",
										value = "Equal"
									}
								}
							},
							closeParen = {
								index = 22,
								span = {
									start = 75,
									stop = 75,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = ")"
							},
							openParen = {
								index = 20,
								span = {
									start = 67,
									stop = 67,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = "("
							},
							type = "parenthesis"
						},
						callee = {
							inner = {
								index = 19,
								span = {
									start = 62,
									stop = 66,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "print"
							},
							subtype = "identifier",
							type = "prefix"
						},
						type = "call"
					}
				},
				type = "block"
			},
			token = {
				index = 18,
				span = {
					start = 57,
					stop = 60,
					unit = "char"
				},
				supertype = "token",
				type = "keyword",
				value = "else"
			}
		},
		elseifs = {
			{
				body = {
					statements = {
						{
							args = {
								arguments = {
									separators = {},
									values = {
										{
											index = 16,
											span = {
												start = 46,
												stop = 54,
												unit = "char"
											},
											supertype = "token",
											type = "string",
											value = "Greater"
										}
									}
								},
								closeParen = {
									index = 17,
									span = {
										start = 55,
										stop = 55,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = ")"
								},
								openParen = {
									index = 15,
									span = {
										start = 45,
										stop = 45,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = "("
								},
								type = "parenthesis"
							},
							callee = {
								inner = {
									index = 14,
									span = {
										start = 40,
										stop = 44,
										unit = "char"
									},
									supertype = "token",
									type = "identifier",
									value = "print"
								},
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
						inner = {
							index = 10,
							span = {
								start = 29,
								stop = 29,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "a"
						},
						subtype = "identifier",
						type = "prefix"
					},
					operator = {
						index = 11,
						span = {
							start = 31,
							stop = 31,
							unit = "char"
						},
						supertype = "token",
						type = "operator",
						value = ">"
					},
					right = {
						inner = {
							index = 12,
							span = {
								start = 33,
								stop = 33,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "b"
						},
						subtype = "identifier",
						type = "prefix"
					},
					type = "binary"
				},
				elseifToken = {
					index = 9,
					span = {
						start = 22,
						stop = 27,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "elseif"
				},
				thenToken = {
					index = 13,
					span = {
						start = 35,
						stop = 38,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "then"
				}
			}
		},
		endToken = {
			index = 23,
			span = {
				start = 77,
				stop = 79,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "end"
		},
		ifToken = {
			index = 1,
			span = {
				start = 1,
				stop = 2,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "if"
		},
		thenToken = {
			index = 5,
			span = {
				start = 10,
				stop = 13,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "then"
		},
		type = "if"
	},
	["7.5-Control flow-While"] = {
		body = {
			statements = {
				{
					args = {
						arguments = {
							separators = {
								{
									index = 12,
									span = {
										start = 40,
										stop = 40,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = ","
								}
							},
							values = {
								{
									inner = {
										index = 11,
										span = {
											start = 37,
											stop = 39,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "val"
									},
									subtype = "identifier",
									type = "prefix"
								},
								{
									operator = {
										index = 13,
										span = {
											start = 41,
											stop = 41,
											unit = "char"
										},
										supertype = "token",
										type = "operator",
										value = "#"
									},
									right = {
										inner = {
											index = 14,
											span = {
												start = 42,
												stop = 44,
												unit = "char"
											},
											supertype = "token",
											type = "identifier",
											value = "val"
										},
										subtype = "identifier",
										type = "prefix"
									},
									type = "unary"
								}
							}
						},
						closeParen = {
							index = 15,
							span = {
								start = 45,
								stop = 45,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 10,
							span = {
								start = 36,
								stop = 36,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						left = {
							inner = {
								index = 7,
								span = {
									start = 24,
									stop = 28,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "table"
							},
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
				operator = {
					index = 2,
					span = {
						start = 7,
						stop = 7,
						unit = "char"
					},
					supertype = "token",
					type = "operator",
					value = "#"
				},
				right = {
					inner = {
						index = 3,
						span = {
							start = 8,
							stop = 10,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "val"
					},
					subtype = "identifier",
					type = "prefix"
				},
				type = "unary"
			},
			operator = {
				index = 4,
				span = {
					start = 12,
					stop = 12,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "<"
			},
			right = {
				inner = {
					index = 5,
					span = {
						start = 14,
						stop = 19,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "target"
				},
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
					localToken = {
						index = 2,
						span = {
							start = 8,
							stop = 12,
							unit = "char"
						},
						supertype = "token",
						type = "keyword",
						value = "local"
					},
					right = {
						assign = {
							index = 4,
							span = {
								start = 20,
								stop = 20,
								unit = "char"
							},
							supertype = "token",
							type = "assign",
							value = "="
						},
						values = {
							separators = {},
							values = {
								{
									call = {
										args = {
											arguments = {
												separators = {},
												values = {
													{
														left = {
															inner = {
																index = 9,
																span = {
																	start = 32,
																	stop = 35,
																	unit = "char"
																},
																supertype = "token",
																type = "identifier",
																value = "math"
															},
															subtype = "identifier",
															type = "prefix"
														},
														sub = "huge",
														subtype = "dot",
														type = "prefix"
													}
												}
											},
											closeParen = {
												index = 12,
												span = {
													start = 41,
													stop = 41,
													unit = "char"
												},
												supertype = "token",
												type = "symbol",
												value = ")"
											},
											openParen = {
												index = 8,
												span = {
													start = 31,
													stop = 31,
													unit = "char"
												},
												supertype = "token",
												type = "symbol",
												value = "("
											},
											type = "parenthesis"
										},
										callee = {
											inner = {
												index = 5,
												span = {
													start = 22,
													stop = 25,
													unit = "char"
												},
												supertype = "token",
												type = "identifier",
												value = "file"
											},
											subtype = "identifier",
											type = "prefix"
										},
										method = {
											name = {
												index = 7,
												span = {
													start = 27,
													stop = 30,
													unit = "char"
												},
												supertype = "token",
												type = "identifier",
												value = "read"
											},
											token = {
												index = 6,
												span = {
													start = 26,
													stop = 26,
													unit = "char"
												},
												supertype = "token",
												type = "symbol",
												value = ":"
											}
										},
										type = "call"
									},
									subtype = "call",
									type = "prefix"
								}
							}
						}
					},
					type = "assignment",
					variables = {
						separators = {},
						values = {
							{
								inner = {
									index = 3,
									span = {
										start = 14,
										stop = 18,
										unit = "char"
									},
									supertype = "token",
									type = "identifier",
									value = "block"
								},
								subtype = "identifier",
								type = "prefix"
							}
						}
					}
				}
			},
			type = "block"
		},
		condition = {
			left = {
				inner = {
					index = 14,
					span = {
						start = 49,
						stop = 53,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "block"
				},
				subtype = "identifier",
				type = "prefix"
			},
			operator = {
				index = 15,
				span = {
					start = 55,
					stop = 56,
					unit = "char"
				},
				supertype = "token",
				type = "operator",
				value = "=="
			},
			right = {
				index = 16,
				span = {
					start = 58,
					stop = 60,
					unit = "char"
				},
				supertype = "token",
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
						arguments = {
							separators = {},
							values = {
								{
									inner = {
										index = 10,
										span = {
											start = 23,
											stop = 23,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "i"
									},
									subtype = "identifier",
									type = "prefix"
								}
							}
						},
						closeParen = {
							index = 11,
							span = {
								start = 24,
								stop = 24,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 9,
							span = {
								start = 22,
								stop = 22,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 8,
							span = {
								start = 17,
								stop = 21,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "print"
						},
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
			index = 6,
			span = {
				start = 11,
				stop = 12,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 10
		},
		min = {
			index = 4,
			span = {
				start = 9,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
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
						arguments = {
							separators = {},
							values = {
								{
									inner = {
										index = 12,
										span = {
											start = 26,
											stop = 26,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "i"
									},
									subtype = "identifier",
									type = "prefix"
								}
							}
						},
						closeParen = {
							index = 13,
							span = {
								start = 27,
								stop = 27,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 11,
							span = {
								start = 25,
								stop = 25,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 10,
							span = {
								start = 20,
								stop = 24,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "print"
						},
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
			index = 6,
			span = {
				start = 11,
				stop = 11,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 1
		},
		min = {
			index = 4,
			span = {
				start = 9,
				stop = 9,
				unit = "char"
			},
			supertype = "token",
			type = "number",
			value = 0
		},
		step = {
			index = 8,
			span = {
				start = 13,
				stop = 15,
				unit = "char"
			},
			supertype = "token",
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
						arguments = {
							separators = {},
							values = {
								{
									inner = {
										index = 13,
										span = {
											start = 34,
											stop = 34,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "v"
									},
									subtype = "identifier",
									type = "prefix"
								}
							}
						},
						closeParen = {
							index = 14,
							span = {
								start = 35,
								stop = 35,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 12,
							span = {
								start = 33,
								stop = 33,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 11,
							span = {
								start = 28,
								stop = 32,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "print"
						},
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
						arguments = {
							separators = {},
							values = {
								{
									inner = {
										index = 8,
										span = {
											start = 19,
											stop = 22,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "args"
									},
									subtype = "identifier",
									type = "prefix"
								}
							}
						},
						closeParen = {
							index = 9,
							span = {
								start = 23,
								stop = 23,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = ")"
						},
						openParen = {
							index = 7,
							span = {
								start = 18,
								stop = 18,
								unit = "char"
							},
							supertype = "token",
							type = "symbol",
							value = "("
						},
						type = "parenthesis"
					},
					callee = {
						inner = {
							index = 6,
							span = {
								start = 12,
								stop = 17,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "ipairs"
						},
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
			separators = {
				{
					index = 3,
					span = {
						start = 6,
						stop = 6,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				"i",
				"v"
			}
		}
	},
	["8.1-Statements-Assignment"] = {
		right = {
			assign = {
				index = 6,
				span = {
					start = 7,
					stop = 7,
					unit = "char"
				},
				supertype = "token",
				type = "assign",
				value = "="
			},
			values = {
				separators = {
					{
						index = 8,
						span = {
							start = 10,
							stop = 10,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = ","
					},
					{
						index = 10,
						span = {
							start = 12,
							stop = 12,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = ","
					}
				},
				values = {
					{
						index = 7,
						span = {
							start = 9,
							stop = 9,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 1
					},
					{
						index = 9,
						span = {
							start = 11,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 2
					},
					{
						index = 11,
						span = {
							start = 13,
							stop = 13,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 3
					}
				}
			}
		},
		type = "assignment",
		variables = {
			separators = {
				{
					index = 2,
					span = {
						start = 2,
						stop = 2,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 4,
					span = {
						start = 4,
						stop = 4,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					inner = {
						index = 1,
						span = {
							start = 1,
							stop = 1,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "a"
					},
					subtype = "identifier",
					type = "prefix"
				},
				{
					inner = {
						index = 3,
						span = {
							start = 3,
							stop = 3,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "b"
					},
					subtype = "identifier",
					type = "prefix"
				},
				{
					inner = {
						index = 5,
						span = {
							start = 5,
							stop = 5,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "c"
					},
					subtype = "identifier",
					type = "prefix"
				}
			}
		}
	},
	["8.2-Statements-Local Assignment"] = {
		localToken = {
			index = 1,
			span = {
				start = 1,
				stop = 5,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "local"
		},
		right = {
			assign = {
				index = 7,
				span = {
					start = 13,
					stop = 13,
					unit = "char"
				},
				supertype = "token",
				type = "assign",
				value = "="
			},
			values = {
				separators = {
					{
						index = 9,
						span = {
							start = 16,
							stop = 16,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = ","
					},
					{
						index = 11,
						span = {
							start = 18,
							stop = 18,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = ","
					}
				},
				values = {
					{
						index = 8,
						span = {
							start = 15,
							stop = 15,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 1
					},
					{
						index = 10,
						span = {
							start = 17,
							stop = 17,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 2
					},
					{
						index = 12,
						span = {
							start = 19,
							stop = 19,
							unit = "char"
						},
						supertype = "token",
						type = "number",
						value = 3
					}
				}
			}
		},
		type = "assignment",
		variables = {
			separators = {
				{
					index = 3,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 5,
					span = {
						start = 10,
						stop = 10,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					inner = {
						index = 2,
						span = {
							start = 7,
							stop = 7,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "a"
					},
					subtype = "identifier",
					type = "prefix"
				},
				{
					inner = {
						index = 4,
						span = {
							start = 9,
							stop = 9,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "b"
					},
					subtype = "identifier",
					type = "prefix"
				},
				{
					inner = {
						index = 6,
						span = {
							start = 11,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "c"
					},
					subtype = "identifier",
					type = "prefix"
				}
			}
		}
	},
	["8.3-Statements-Local Declaration"] = {
		localToken = {
			index = 1,
			span = {
				start = 1,
				stop = 5,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "local"
		},
		type = "assignment",
		variables = {
			separators = {
				{
					index = 3,
					span = {
						start = 8,
						stop = 8,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				},
				{
					index = 5,
					span = {
						start = 10,
						stop = 10,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					inner = {
						index = 2,
						span = {
							start = 7,
							stop = 7,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "a"
					},
					subtype = "identifier",
					type = "prefix"
				},
				{
					inner = {
						index = 4,
						span = {
							start = 9,
							stop = 9,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "b"
					},
					subtype = "identifier",
					type = "prefix"
				},
				{
					inner = {
						index = 6,
						span = {
							start = 11,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "identifier",
						value = "c"
					},
					subtype = "identifier",
					type = "prefix"
				}
			}
		}
	},
	["8.4-Statements-Function definition"] = {
		functionToken = {
			index = 1,
			span = {
				start = 1,
				stop = 8,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "function"
		},
		impl = {
			body = {
				statements = {
					{
						args = {
							arguments = {
								separators = {},
								values = {
									{
										index = 7,
										span = {
											start = 23,
											stop = 26,
											unit = "char"
										},
										supertype = "token",
										type = "string",
										value = "hi"
									}
								}
							},
							closeParen = {
								index = 8,
								span = {
									start = 27,
									stop = 27,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = ")"
							},
							openParen = {
								index = 6,
								span = {
									start = 22,
									stop = 22,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = "("
							},
							type = "parenthesis"
						},
						callee = {
							inner = {
								index = 5,
								span = {
									start = 17,
									stop = 21,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "print"
							},
							subtype = "identifier",
							type = "prefix"
						},
						type = "call"
					}
				},
				type = "block"
			},
			closeParen = {
				index = 4,
				span = {
					start = 15,
					stop = 15,
					unit = "char"
				},
				supertype = "token",
				type = "symbol",
				value = ")"
			},
			endToken = {
				index = 9,
				span = {
					start = 29,
					stop = 31,
					unit = "char"
				},
				supertype = "token",
				type = "keyword",
				value = "end"
			},
			openParen = {
				index = 3,
				span = {
					start = 14,
					stop = 14,
					unit = "char"
				},
				supertype = "token",
				type = "symbol",
				value = "("
			},
			parameters = {
				separators = {},
				values = {}
			}
		},
		name = {
			accesses = {},
			base = {
				inner = {
					index = 2,
					span = {
						start = 10,
						stop = 13,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "test"
				},
				subtype = "identifier",
				type = "prefix"
			}
		},
		type = "funcDef"
	},
	["8.5-Statements-Function definition on a table"] = {
		statements = {
			{
				localToken = {
					index = 1,
					span = {
						start = 1,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "local"
				},
				right = {
					assign = {
						index = 3,
						span = {
							start = 11,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "assign",
						value = "="
					},
					values = {
						separators = {},
						values = {
							{
								closeBrace = {
									index = 5,
									span = {
										start = 14,
										stop = 14,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = "}"
								},
								fields = {
									separators = {},
									values = {}
								},
								openBrace = {
									index = 4,
									span = {
										start = 13,
										stop = 13,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = "{"
								}
							}
						}
					}
				},
				type = "assignment",
				variables = {
					separators = {},
					values = {
						{
							inner = {
								index = 2,
								span = {
									start = 7,
									stop = 9,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "lib"
							},
							subtype = "identifier",
							type = "prefix"
						}
					}
				}
			},
			{
				functionToken = {
					index = 6,
					span = {
						start = 16,
						stop = 23,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "function"
				},
				impl = {
					body = {
						statements = {
							{
								args = {
									arguments = {
										separators = {},
										values = {
											{
												index = 14,
												span = {
													start = 42,
													stop = 45,
													unit = "char"
												},
												supertype = "token",
												type = "string",
												value = "hi"
											}
										}
									},
									closeParen = {
										index = 15,
										span = {
											start = 46,
											stop = 46,
											unit = "char"
										},
										supertype = "token",
										type = "symbol",
										value = ")"
									},
									openParen = {
										index = 13,
										span = {
											start = 41,
											stop = 41,
											unit = "char"
										},
										supertype = "token",
										type = "symbol",
										value = "("
									},
									type = "parenthesis"
								},
								callee = {
									inner = {
										index = 12,
										span = {
											start = 36,
											stop = 40,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "print"
									},
									subtype = "identifier",
									type = "prefix"
								},
								type = "call"
							}
						},
						type = "block"
					},
					closeParen = {
						index = 11,
						span = {
							start = 34,
							stop = 34,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = ")"
					},
					endToken = {
						index = 16,
						span = {
							start = 48,
							stop = 50,
							unit = "char"
						},
						supertype = "token",
						type = "keyword",
						value = "end"
					},
					openParen = {
						index = 10,
						span = {
							start = 33,
							stop = 33,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = "("
					},
					parameters = {
						separators = {},
						values = {}
					}
				},
				name = {
					accesses = {
						"test"
					},
					base = {
						inner = {
							index = 7,
							span = {
								start = 25,
								stop = 27,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "lib"
						},
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
				localToken = {
					index = 1,
					span = {
						start = 1,
						stop = 5,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "local"
				},
				right = {
					assign = {
						index = 3,
						span = {
							start = 11,
							stop = 11,
							unit = "char"
						},
						supertype = "token",
						type = "assign",
						value = "="
					},
					values = {
						separators = {},
						values = {
							{
								closeBrace = {
									index = 5,
									span = {
										start = 14,
										stop = 14,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = "}"
								},
								fields = {
									separators = {},
									values = {}
								},
								openBrace = {
									index = 4,
									span = {
										start = 13,
										stop = 13,
										unit = "char"
									},
									supertype = "token",
									type = "symbol",
									value = "{"
								}
							}
						}
					}
				},
				type = "assignment",
				variables = {
					separators = {},
					values = {
						{
							inner = {
								index = 2,
								span = {
									start = 7,
									stop = 9,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "lib"
							},
							subtype = "identifier",
							type = "prefix"
						}
					}
				}
			},
			{
				functionToken = {
					index = 6,
					span = {
						start = 16,
						stop = 23,
						unit = "char"
					},
					supertype = "token",
					type = "keyword",
					value = "function"
				},
				impl = {
					body = {
						statements = {
							{
								args = {
									arguments = {
										separators = {},
										values = {
											{
												inner = {
													index = 14,
													span = {
														start = 42,
														stop = 45,
														unit = "char"
													},
													supertype = "token",
													type = "identifier",
													value = "self"
												},
												subtype = "identifier",
												type = "prefix"
											}
										}
									},
									closeParen = {
										index = 15,
										span = {
											start = 46,
											stop = 46,
											unit = "char"
										},
										supertype = "token",
										type = "symbol",
										value = ")"
									},
									openParen = {
										index = 13,
										span = {
											start = 41,
											stop = 41,
											unit = "char"
										},
										supertype = "token",
										type = "symbol",
										value = "("
									},
									type = "parenthesis"
								},
								callee = {
									inner = {
										index = 12,
										span = {
											start = 36,
											stop = 40,
											unit = "char"
										},
										supertype = "token",
										type = "identifier",
										value = "print"
									},
									subtype = "identifier",
									type = "prefix"
								},
								type = "call"
							}
						},
						type = "block"
					},
					closeParen = {
						index = 11,
						span = {
							start = 34,
							stop = 34,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = ")"
					},
					endToken = {
						index = 16,
						span = {
							start = 48,
							stop = 50,
							unit = "char"
						},
						supertype = "token",
						type = "keyword",
						value = "end"
					},
					openParen = {
						index = 10,
						span = {
							start = 33,
							stop = 33,
							unit = "char"
						},
						supertype = "token",
						type = "symbol",
						value = "("
					},
					parameters = {
						separators = {},
						values = {}
					}
				},
				name = {
					accesses = {},
					base = {
						inner = {
							index = 7,
							span = {
								start = 25,
								stop = 27,
								unit = "char"
							},
							supertype = "token",
							type = "identifier",
							value = "lib"
						},
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
		functionToken = {
			index = 2,
			span = {
				start = 7,
				stop = 14,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "function"
		},
		impl = {
			body = {
				statements = {
					{
						args = {
							arguments = {
								separators = {},
								values = {
									{
										index = 8,
										span = {
											start = 29,
											stop = 32,
											unit = "char"
										},
										supertype = "token",
										type = "string",
										value = "hi"
									}
								}
							},
							closeParen = {
								index = 9,
								span = {
									start = 33,
									stop = 33,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = ")"
							},
							openParen = {
								index = 7,
								span = {
									start = 28,
									stop = 28,
									unit = "char"
								},
								supertype = "token",
								type = "symbol",
								value = "("
							},
							type = "parenthesis"
						},
						callee = {
							inner = {
								index = 6,
								span = {
									start = 23,
									stop = 27,
									unit = "char"
								},
								supertype = "token",
								type = "identifier",
								value = "print"
							},
							subtype = "identifier",
							type = "prefix"
						},
						type = "call"
					}
				},
				type = "block"
			},
			closeParen = {
				index = 5,
				span = {
					start = 21,
					stop = 21,
					unit = "char"
				},
				supertype = "token",
				type = "symbol",
				value = ")"
			},
			endToken = {
				index = 10,
				span = {
					start = 35,
					stop = 37,
					unit = "char"
				},
				supertype = "token",
				type = "keyword",
				value = "end"
			},
			openParen = {
				index = 4,
				span = {
					start = 20,
					stop = 20,
					unit = "char"
				},
				supertype = "token",
				type = "symbol",
				value = "("
			},
			parameters = {
				separators = {},
				values = {}
			}
		},
		localToken = {
			index = 1,
			span = {
				start = 1,
				stop = 5,
				unit = "char"
			},
			supertype = "token",
			type = "keyword",
			value = "local"
		},
		name = {
			accesses = {},
			base = {
				inner = {
					index = 3,
					span = {
						start = 16,
						stop = 19,
						unit = "char"
					},
					supertype = "token",
					type = "identifier",
					value = "test"
				},
				subtype = "identifier",
				type = "prefix"
			}
		},
		type = "funcDef"
	},
	["8.8-Statements-Return"] = {
		type = "return",
		values = {
			separators = {
				{
					index = 3,
					span = {
						start = 14,
						stop = 14,
						unit = "char"
					},
					supertype = "token",
					type = "symbol",
					value = ","
				}
			},
			values = {
				{
					index = 2,
					span = {
						start = 8,
						stop = 13,
						unit = "char"
					},
					supertype = "token",
					type = "string",
					value = "test"
				},
				{
					index = 4,
					span = {
						start = 16,
						stop = 20,
						unit = "char"
					},
					supertype = "token",
					type = "boolean",
					value = false
				}
			}
		}
	}
}