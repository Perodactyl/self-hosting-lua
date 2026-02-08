local Error = require("source.error")
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
			return statement:extend("In statement " .. #statements + 1), statementSpan
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
				return self.tokenStream:errorNext(true, "No identifiers to begin assignment")
			end

			local variables, varSpan = self:parseSequence(self.parseAccess, {type="symbol",value=","}, "varlist")
			if variables.isError then
				return variables, varSpan
			end

			if #variables == 0 then
				return self.tokenStream:errorHere(true, "No variables")
			end

			---@type ({assign:"=",values:Expression[]}|Error), Span
			local assignAndValues, span = self.tokenStream:scope("assignment operator and values", {
				{"Values present", function()
					local assign = self.tokenStream:next()

					if assign == nil then
						return self.tokenStream:errorHere(true, "No assignment operator")
					end
					if assign.type ~= "assign" then
						return self.tokenStream:errorHere(true, "Assignment operator was not of type assign")
					end
					if localKw and assign.value ~= "=" then
						return self.tokenStream:errorHere(false, "Local definitions only allow assignment with =")
					end

					local assignValues =
						self:parseSequence(self.parseExpression, {type="symbol",value=","})
					if assignValues.isError then
						return assignValues
					end

					return {assign=assign.value, values=assignValues}
				end},
				{"Local without values", function()
					if not localKw then
						return self.tokenStream:errorHere(true, "Not a local; must have values")
					end
					local assign = self.tokenStream:peek()
					if assign ~= nil and assign.type == "assign" then
						return self.tokenStream:errorNext(true, "Assignment operator found")
					end
					return {assign="=", values={}}
				end},
			})

			if assignAndValues.isError then return assignAndValues, span end

			return {
				type="assignment",isLocal=localKw,
				variables=variables,
				assign=assignAndValues.assign,
				values=assignAndValues.values
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
			return calleeSpan:error(true, "Prefix was not of type call")
		end},

		{"Do..end", function() -- do block
			if not self.tokenStream:nextIfEq({type="keyword",value="do"}) then
				return self.tokenStream:errorNext(true, "No do kw")
			end

			local body = try(self:parseBlock({type="keyword",value="end"}))

			self.tokenStream:next() -- end
			return {
				type = "do",
				body = body,
			}
		end},

		{"If..then", function() --if
			if not self.tokenStream:nextIfEq({type="keyword",value="if"}) then
				return self.tokenStream:errorNext(true, "No if kw")
			end
			local condition, conditionSpan = self:parseExpression()
			if condition.isError then
				return condition:unrecoverable():extend("while parsing if condition"), conditionSpan
			end
			if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then
				return self.tokenStream:errorNext(false, "No then kw")
			end

			local body = self:parseBlock(
				{type="keyword",value="end"},
				{type="keyword",value="elseif"},
				{type="keyword",value="else"}
			)
			if body.isError then return body end

			local elseifs = {}
			local elseBody

			while true do
				local lastSymbol = self.tokenStream:next()
				if lastSymbol == nil then break end

				if lastSymbol.value == "elseif" then
					local elseifCondition = self:parseExpression()
					if not self.tokenStream:nextIfEq({type="keyword",value="then"}) then
						return self.tokenStream:errorHere(false, "Elseif clause missing then kw")
					end

					local elseifBody = self:parseBlock(
						{type="keyword",value="end"},
						{type="keyword",value="elseif"},
						{type="keyword",value="else"}
					)

					if elseifBody.isError then return elseifBody end

					table.insert(elseifs, {condition=elseifCondition,body=elseifBody})
				elseif lastSymbol.value == "else" then
					elseBody = self:parseBlock({type="keyword",value="end"})
					if elseBody.isError then return elseBody end
					self.tokenStream:next() -- skip end kw
					break
				elseif lastSymbol.value == "end" then
					break
				end
			end

			return {
				type = "if",
				condition = condition,
				body = body,
				elseifs = elseifs,
				elseBody = elseBody,
			}
		end},

		{"For..=", function() -- numeric for loop
			if not self.tokenStream:nextIfEq({type="keyword",value="for"}) then
				return self.tokenStream:errorNext(true, "No for kw")
			end

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
			if not self.tokenStream:nextIfEq({type="keyword",value="for"}) then
				return self.tokenStream:errorNext(true, "No for kw")
			end
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
			if not self.tokenStream:nextIfEq({type="keyword",value="while"}) then
				return self.tokenStream:errorNext(true, "No while kw")
			end
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
			self.tokenStream:expect({type="keyword",value="repeat"},true)

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
			if not self.tokenStream:nextIfEq({type="keyword",value="function"}) then
				return self.tokenStream:errorNext(true, "No function kw")
			end

			local name
			if not localKw then
				name = {
					base = {type="prefix",subtype="identifier",inner=self.tokenStream:next().value}, --todo handle eof and stuff
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
				name = ident.value
			end

			local impl = self:parseFunctionDefinition()
			if impl.isError then return impl end

			return {
				type = localKw and "localFuncDef" or "funcDef",
				name = name,
				impl = impl,
			}
		end},
		{"Return", function() --return
			self.tokenStream:expect({type="keyword",value="return"}, true)

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
			if not self.tokenStream:nextIfEq({type="symbol",value="::"}) then
				return self.tokenStream:errorNext(true, "No start double colon")
			end
			local name = self.tokenStream:next()
			if name == nil then return nil, "No label name" end
			if name.type ~= "identifier" then return nil, "Label name is not an identifier" end
			if not self.tokenStream:nextIfEq({type="symbol",value="::"}) then return nil, "No end double colon" end

			return {
				type = "label",
				name = name.value,
			}
		end},
		{"Goto", function()
			if not self.tokenStream:nextIfEq({type="keyword",value="goto"}) then
				return self.tokenStream:errorNext(true, "No goto kw")
			end

			local name = self.tokenStream:next()
			if name == nil then return nil, "No label name" end
			if name.type ~= "identifier" then return nil, "Label name is not an identifier" end

			return {
				type = "goto",
				destination = name.value,
			}
		end},
		{"Semicolon", function()
			self.tokenStream:expect({type="symbol",value=";"}, true)
			return {
				type = "delimiter"
			}
		end},
	})
	return a,b --Prevents TCO, making traceback more informative
end

return Parser

end
