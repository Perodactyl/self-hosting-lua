local Error = require("source.error")
local prettyOutput = require("util.prettyOutput")
local try = Error.try

---@param parser Parser
return function(parser)

---@class Parser
local Parser = parser

---@param lastToken Token | nil never ends if nil
---@param ... Token alternative valid last tokens
---@return Block | Error, Span
function Parser:parseBlock(lastToken, ...)
	local statements = {}
	local returnStatement = nil
	local span = self.tokenStream:atNext()

	while not self.tokenStream:isDone() and not self.tokenStream:eq(lastToken, ...) do
		local statement, statementSpan = self:parseStatement()
		if statement.isError then
			return statement:extend("In statement " .. #statements + 1):ofType("quantifier"), statementSpan
		end

		span = span + statementSpan
		if statement.type == "return" then
			returnStatement = statement.values
		elseif returnStatement ~= nil then
			error("Return before end of block")
		else
			table.insert(statements, statement)
		end
	end

	return {
		type = "block",
		statements = statements,
		returnStatement = returnStatement,
	}, span
end

---@return (Statement | ReturnStatement | Error), Span
function Parser:parseStatement()
	local a,b = self.tokenStream:scope("statement", {
		{"Assignment", function() -- assignment
			local localKw = self.tokenStream:nextIfEq({type="keyword",value="local"})
			-- self.tokenStream:expect({type="identifier"},true) -- not valid here because we don't want to consume it
			if not self.tokenStream:eq({type = "identifier"}) then
				return self.tokenStream:errorNext(true, "No identifiers to begin assignment"):ofType("entry")
			end

			local variables, varSpan = Error.try(self:parseSequence(self.parseAccess, {type="symbol",value=","}, "varlist"))

			if #variables.values == 0 then
				return self.tokenStream:errorHere(true, "No variables"):ofType("entry")
			end

			-- log(prettyOutput.dump(variables))

			---@type ({assign:"=",values:Expression[]}|Error), Span
			local right, span = self.tokenStream:scope("assignment operator and values", {
				{"Values present", function()
					local assign = self.tokenStream:expect({type="assign"}, true, nil, "entry")
					if localKw and assign.value ~= "=" then
						return self.tokenStream:errorHere(false, "Local definitions only allow assignment with =")
					end

					local assignValues =
						self:parseSequence(self.parseExpression, {type="symbol",value=","})
					if assignValues.isError then
						return assignValues
					end

					return {assign=assign, values=assignValues}
				end},
				{"Local without values", function()
					if not localKw then
						return self.tokenStream:errorHere(true, "Not a local; must have values"):ofType("entry")
					end
					local assign = self.tokenStream:peek()
					if assign ~= nil and assign.type == "assign" then
						return self.tokenStream:errorNext(true, "Assignment operator found"):ofType("entry")
					end
					return -1
				end},
			})

			if right ~= -1 and right.isError then return right, span end

			return {
				type="assignment",
				localToken=localKw,
				variables=variables,
				right = right == -1 and nil or right,
			}
		end},

		{"Call", function() --call
			local callee, calleeSpan = self:parsePrefixExpression()
			if callee.isError then
				return callee, calleeSpan
			end

			if callee.subtype == "call" then
				return callee.call
			end
			return calleeSpan:error(true, "Prefix was not of type call"):ofType("entry")
		end},

		{"Do..end", function() -- do block
			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then
				return self.tokenStream:errorNext(true, "No do kw"):ofType("entry")
			end

			local body = try(self:parseBlock({type="keyword",value="end"}))

			self.tokenStream:next() -- end
			return {
				type = "do",
				body = body,
			}
		end},

		{"If..then", function() --if
			local ifKw = self.tokenStream:expect({type="keyword",value="if"}, true, nil, "entry")
			local condition = Error.try(self:parseExpression())
			local thenKw = self.tokenStream:expect({type="keyword",value="then"}, false)

			local body = self:parseBlock(
				{type="keyword",value="end"},
				{type="keyword",value="elseif"},
				{type="keyword",value="else"}
			)
			if body.isError then return body end

			local elseifs = {}
			local elsePart

			local endKw

			while true do
				local lastSymbol = self.tokenStream:expect({type="keyword"}, false)
				-- if lastSymbol == nil then break end

				if lastSymbol.value == "elseif" then
					local elseifCondition = self:parseExpression()
					local elseifThenKw = self.tokenStream:expect({type="keyword",value="then"}, true)

					local elseifBody = self:parseBlock(
						{type="keyword",value="end"},
						{type="keyword",value="elseif"},
						{type="keyword",value="else"}
					)

					if elseifBody.isError then return elseifBody end

					table.insert(elseifs, {
						elseifToken = lastSymbol,
						condition=elseifCondition,
						thenToken=elseifThenKw,
						body=elseifBody
					})
				elseif lastSymbol.value == "else" then
					elsePart = {
						token = lastSymbol,
						body = Error.try(self:parseBlock({type="keyword",value="end"}))
					}
				elseif lastSymbol.value == "end" then
					endKw = lastSymbol
					break
				end
			end

			return {
				type = "if",
				ifToken = ifKw,
				condition = condition,
				thenToken = thenKw,
				body = body,
				elseifs = elseifs,
				elsePart = elsePart,
				endToken = endKw,
			}
		end},

		{"For..=", function() -- numeric for loop
			local forKw = self.tokenStream:expect({type="keyword",value="for"}, true, nil, "entry")

			local name = self.tokenStream:next()
			if name == nil then
				return self.tokenStream:errorHere(true, "Missing variable name")
			end
			if name.type ~= "identifier" then
				return self.tokenStream:errorHere(true, "Variable name is not an identifier")
			end

			if not self.tokenStream:nextIfEq({type="assign",value="="}) then
				return self.tokenStream:errorHere(true, "Missing = in for")
			end

			local min = self:parseExpression()
			if min.isError then return min:unrecoverable() end

			if not self.tokenStream:nextIfEq({type="symbol",value=","}) then
				return self.tokenStream:errorHere(false, "Missing max in for")
			end
			local max = self:parseExpression()
			if max.isError then return max:unrecoverable() end

			local step
			if self.tokenStream:nextIfEq({type="symbol",value=","}) then
				step = self:parseExpression()
			end

			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then
				return self.tokenStream:errorHere(false, "No do kw")
			end

			local body = self:parseBlock({type="keyword",value="end"})
			if body.isError then return body end

			self.tokenStream:next()

			return {
				type = "forRange",
				iterVar = name.value,
				min = min,
				max = max,
				step = step,
				body = body,
			}
		end},

		{"For..in", function()
			local forKw = self.tokenStream:expect({type="keyword",value="for"}, true, nil, "entry")
			local variables, variablesReason = self:parseSequence(function()
				local name = self.tokenStream:next()
				if name == nil then return nil, "Missing variable name" end
				if name.type ~= "identifier" then return nil, "Variable name is not an identifier" end
				return name.value
			end, {type="symbol",value=","})

			if not variables then return nil, variablesReason end

			if not self.tokenStream:nextIfEq({type="keyword",value="in"}) then return nil, "No in kw" end

			local iterator, iteratorReason = self:parseExpression()
			if not iterator then return nil, "Faield to parse iterator: " .. (iteratorReason or "") end


			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then return nil, "No do kw" end
			local body, bodyReason = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil, "Failed to parse for body: " .. (bodyReason or "") end
			self.tokenStream:next()

			return {
				type = "forIn",
				variables = variables,
				expressions = {iterator},
				body = body,
			}
		end},

		{"While loop", function()
			local whileKw = self.tokenStream:expect({type="keyword",value="while"}, true, nil, "entry")
			local condition = self:parseExpression()

			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then
				return self.tokenStream:errorHere(true, "No do kw")
			end
			local body, bodyReason = self:parseBlock({type="keyword",value="end"})
			if body == nil then return nil, "Failed to parse while body: " .. (bodyReason or "") end
			self.tokenStream:next()

			return {
				type = "while",
				condition = condition,
				body = body,
			}
		end},

		{"Repeat..until", function()
			local repeatKw = self.tokenStream:expect({type="keyword",value="repeat"},true, nil, "entry")

			local body = try(self:parseBlock({type="keyword",value="until"}))
			self.tokenStream:next()

			local condition = try(self:parseExpression())

			return {
				type = "repeatUntil",
				body = body,
				condition = condition,
			}
		end},

		---@return FuncDef | nil, string?
		{"Function definition", function() -- function definition
			local localKw = self.tokenStream:nextIfEq({type="keyword",value="local"})
			local functionKw = self.tokenStream:expect({type="keyword",value="function"},true, nil, "entry")

			local name
			if not localKw then
				name = {
					base = {type="prefix",subtype="identifier",inner=self.tokenStream:next()}, --todo handle eof and stuff
					accesses = {},
					method = nil,
				}
				while not self.tokenStream:isDone() do
					if self.tokenStream:nextIfEq({type="symbol",value="."}) then
						table.insert(name.accesses, self.tokenStream:next().value)
					elseif self.tokenStream:nextIfEq({type="symbol",value=":"}) then
						name.method = self.tokenStream:next().value
						break
					elseif self.tokenStream:eq({type="symbol",value="("}) then
						break
					end
				end
			else
				local ident = self.tokenStream:next()
				if ident == nil then return
					self.tokenStream:errorHere(true, "EOF before local fn name")
				end
				if ident.type ~= "identifier" then
					return self.tokenStream:errorHere(true, "Local fn name not an identifier")
				end
				name = {
					base = {type="prefix",subtype="identifier",inner=ident},
					accesses = {},
					method = nil,
				}
			end

			local impl = self:parseFunctionDefinition()
			if impl.isError then return impl end

			return {
				type = "funcDef",
				name = name,
				impl = impl,
				localToken = localKw,
				functionToken = functionKw,
			}
		end},
		{"Return", function() --return
			local returnKw = self.tokenStream:expect({type="keyword",value="return"}, true, nil, "entry")

			local values =
				self:parseSequence(self.parseExpression, {type="symbol",value=","}, "return values")

			if values.isError then
				if values.programInfo ~= nil and values.programInfo.length == 0 then
					values = {}
				else
					return values
				end
			end
			return {
				type = "return",
				values = values,
			}
		end},
		{"Label", function()
			local startDColon = self.tokenStream:expect({type="symbol",value="::"}, true, nil, "entry")
			local name = self.tokenStream:next()
			if name == nil then return nil, "No label name" end
			if name.type ~= "identifier" then return nil, "Label name is not an identifier" end
			local endDColon = self.tokenStream:expect({type="symbol",value="::"}, false)

			return {
				type = "label",
				name = name.value,
			}
		end},
		---@return Goto | Error
		{"Goto", function()
			local gotoKw = self.tokenStream:expect({type="keyword",value="goto"}, true, nil, "entry")

			local name = self.tokenStream:expect({type="identifier"}, false)

			return {
				type = "goto",
				token = gotoKw,
				destination = name,
			}
		end},
		---@return Delimiter | Error
		{"Semicolon", function()
			local token = self.tokenStream:expect({type="symbol",value=";"}, true, nil, "entry")
			return {
				type = "delimiter",
				token = token,
			}
		end},
	})
	return a,b --Prevents TCO, making traceback more informative
end

return Parser

end
