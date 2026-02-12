---@diagnostic disable: unused-local
local util = require("util")

---All default methods just visit all children
---@class Visitor
local Visitor = {}

---@param overrides Visitor
function Visitor.create(overrides)
	return setmetatable(overrides, {
		__index = Visitor
	})
end

---@param chunk Chunk
function Visitor:visitChunk(chunk)
	return self:visitBlock(chunk)
end

---@param block Block
function Visitor:visitBlock(block)
	if block.scope ~= nil then self:visitScope(block.scope) end
	for _,statement in ipairs(block.statements) do
		self:visitStatement(statement)
	end
	if block.returnStatement then
		self:visitReturnStatement(block.returnStatement)
	end
end

---@param statement Statement
function Visitor:visitStatement(statement)
	if statement.type == "delimiter" then
		self:visitDelimiter(statement)
	elseif statement.type == "assignment" then
		self:visitAssignment(statement)
	elseif statement.type == "call" then
		self:visitFunctionCall(statement, true)
	elseif statement.type == "label" then
		self:visitLabel(statement)
	elseif statement.type == "break" then
		self:visitBreak(statement)
	elseif statement.type == "goto" then
		self:visitGoto(statement)
	elseif statement.type == "do" then
		self:visitDo(statement)
	elseif statement.type == "while" then
		self:visitWhile(statement)
	elseif statement.type == "repeatUntil" then
		self:visitRepeatUntil(statement)
	elseif statement.type == "if" then
		self:visitIf(statement)
	elseif statement.type == "forRange" then
		self:visitForRange(statement)
	elseif statement.type == "forIn" then
		self:visitForIn(statement)
	elseif statement.type == "funcDef" then
		self:visitFuncDef(statement)
	elseif statement.type == "label" then
		self:visitLabel(statement)
	end
end

---@param delimiter Delimiter
function Visitor:visitDelimiter(delimiter)
	self:visitSymbol(delimiter.token)
end

---@param assignment Assignment
function Visitor:visitAssignment(assignment)
	if assignment.localToken then self:visitKeyword(assignment.localToken) end
	for i,var in ipairs(assignment.variables.values) do
		if assignment.localToken then
			self:visitDefinition(var --[[@as PrefixIdentifierAccessExpression]], true, false)
		else
			self:visitAccess(var)
		end
		if assignment.variables.separators[i] ~= nil then
			self:visitSymbol(assignment.variables.separators[i])
		end
	end
	if assignment.right then
		self:visitAssign(assignment.right.assign)
		for i,val in ipairs(assignment.right.values.values) do
			self:visitExpression(val)
			if assignment.right.values.separators[i] ~= nil then
				self:visitSymbol(assignment.right.values.separators[i])
			end
		end
	end
end

---@param call FunctionCall
---@param isStatement boolean
function Visitor:visitFunctionCall(call, isStatement)
	self:visitPrefix(call.callee)
	if call.method ~= nil then
		self:visitSymbol(call.method.token)
		self:visitIdentifier(call.method.name)
	end
	if call.args.type == "parenthesis" then
		self:visitSymbol(call.args.openParen)
		for i,arg in ipairs(call.args.arguments.values) do
			self:visitExpression(arg)
			if call.args.arguments.separators[i] ~= nil then
				self:visitSymbol(call.args.arguments.separators[i])
			end
		end
		self:visitSymbol(call.args.closeParen)
	elseif call.args.type == "string" then
		self:visitStringLiteral(call.args)
	elseif call.args.type == "table" then
		self:visitTableLiteral(call.args)
	end
end

---@param label Label
function Visitor:visitLabel(label)
	self:visitSymbol("::")
	self:visitIdentifier(label.name)
	self:visitSymbol("::")
end

---@param breakStatement Break
function Visitor:visitBreak(breakStatement)
	self:visitKeyword("break")
end

---@param gotoStatement Goto
function Visitor:visitGoto(gotoStatement)
	self:visitKeyword("goto")
	self:visitIdentifier(gotoStatement.destination)
end

---@param doStatement Do
function Visitor:visitDo(doStatement)
	self:visitKeyword("do")
	self:visitBlock(doStatement.body)
	self:visitKeyword("end")
end

---@param whileStatement While
function Visitor:visitWhile(whileStatement)
	self:visitKeyword("while")
	self:visitExpression(whileStatement.condition)
	self:visitKeyword("do")
	self:visitBlock(whileStatement.body)
	self:visitKeyword("end")
end

---@param repeatUntil RepeatUntil
function Visitor:visitRepeatUntil(repeatUntil)
	self:visitKeyword("repeat")
	self:visitBlock(repeatUntil.body)
	self:visitKeyword("until")
	self:visitExpression(repeatUntil.condition)
end

---@param ifStatement If
function Visitor:visitIf(ifStatement)
	self:visitKeyword(ifStatement.ifToken)
	self:visitExpression(ifStatement.condition)
	self:visitKeyword(ifStatement.thenToken)
	self:visitBlock(ifStatement.body)
	for _,elseifBranch in ipairs(ifStatement.elseifs) do
		self:visitKeyword(elseifBranch.elseifToken)
		self:visitExpression(elseifBranch.condition)
		self:visitKeyword(elseifBranch.thenToken)
		self:visitBlock(elseifBranch.body)
	end
	if ifStatement.elsePart then
		self:visitKeyword(ifStatement.elsePart.token)
		self:visitBlock(ifStatement.elsePart.body)
	end
	self:visitKeyword(ifStatement.endToken)
end

---@param forRange ForRange
function Visitor:visitForRange(forRange)
	self:visitKeyword("for")
	self:visitIdentifier(forRange.iterVar)
	self:visitAssign("=")
	self:visitExpression(forRange.min)
	self:visitSymbol(",")
	self:visitExpression(forRange.max)
	if forRange.step then
		self:visitSymbol(",")
		self:visitExpression(forRange.step)
	end
	self:visitKeyword("do")
	self:visitBlock(forRange.body)
	self:visitKeyword("end")
end

---@param forIn ForIn
function Visitor:visitForIn(forIn)
	self:visitKeyword("for")
	for i,var in ipairs(forIn.variables) do
		self:visitIdentifier(var)
		if i ~= #forIn.variables then
			self:visitSymbol(",")
		end
	end
	self:visitKeyword("in")
	for i,expr in ipairs(forIn.expressions) do
		self:visitExpression(expr)
		if i ~= #forIn.expressions then
			self:visitSymbol(",")
		end
	end
	self:visitKeyword("do")
	self:visitBlock(forIn.body)
	self:visitKeyword("end")
end

---@param funcDef FuncDef
function Visitor:visitFuncDef(funcDef)
	if funcDef.localToken then self:visitKeyword(funcDef.localToken) end
	self:visitKeyword(funcDef.functionToken)
	self:visitDefinition(funcDef.name.base, funcDef.localToken ~= nil, true)
	for _,access in ipairs(funcDef.name.accesses) do
		self:visitSymbol(".")
		self:visitIdentifier(access)
	end
	if funcDef.name.method then
		self:visitSymbol(":")
		self:visitIdentifier(funcDef.name.method)
	end
	self:visitFuncImpl(funcDef.impl)
end

---@param impl FuncImpl
function Visitor:visitFuncImpl(impl)
	self:visitSymbol(impl.openParen)
	for i,param in ipairs(impl.parameters.values) do
		self:visitAccess(param)
		if impl.parameters.separators[i] ~= nil then
			self:visitSymbol(impl.parameters.separators[i])
		end
	end
	if impl.rest then
		self:visitVarArg(impl.rest)
	end
	self:visitSymbol(impl.closeParen)

	self:visitBlock(impl.body)
	self:visitKeyword(impl.endToken)
end

---@param returnStatement ReturnStatement
function Visitor:visitReturnStatement(returnStatement)
	self:visitKeyword(returnStatement.returnToken)
	for _,expr in ipairs(returnStatement) do
		self:visitExpression(expr)
	end
end

---@param expr Expression
function Visitor:visitExpression(expr)
	if expr.type == "nil"         then self:visitNilLiteral(expr)
	elseif expr.type == "boolean" then self:visitBoolLiteral(expr)
	elseif expr.type == "number"  then self:visitNumLiteral(expr)
	elseif expr.type == "string"  then self:visitStringLiteral(expr)
	elseif expr.type == "table"   then self:visitTableLiteral(expr)
	elseif expr.type == "vararg"  then self:visitVarArg(expr)
	elseif expr.type == "funcDef" then self:visitFuncDefExpr(expr)
	elseif expr.type == "prefix"  then self:visitPrefix(expr --[[@as PrefixExpression]])
	elseif expr.type == "binary"  then self:visitBinary(expr)
	elseif expr.type == "unary"   then self:visitUnary(expr)
	end
end

---@param keyword KeywordToken
function Visitor:visitKeyword(keyword)

end

---@param ident IdentifierToken
function Visitor:visitIdentifier(ident)

end

---@param symbol SymbolToken
function Visitor:visitSymbol(symbol)

end

---@param assign AssignToken
function Visitor:visitAssign(assign)

end

---@param operator OperatorToken
function Visitor:visitOperator(operator)

end

---@param literal NilLiteralExpression
function Visitor:visitNilLiteral(literal)

end

---@param literal BoolLiteralExpression
function Visitor:visitBoolLiteral(literal)

end

---@param literal NumLiteralExpression
function Visitor:visitNumLiteral(literal)

end

---@param literal StringLiteralExpression
function Visitor:visitStringLiteral(literal)

end

---@param literal TableLiteralExpression
function Visitor:visitTableLiteral(literal)
	self:visitSymbol(literal.openBrace)
	for i,field in ipairs(literal.fields.values) do
		if field.tokens.type == "identifier" then
			if field.key.type ~= "identifier" then
				error("Field is of type identifier, but its key is not of type identifier")
			end
			self:visitIdentifier(field.key.inner --[[@as IdentifierToken]])
			self:visitAssign(field.tokens.assign)
		elseif field.tokens.type == "expression" then
			self:visitSymbol(field.tokens.openBracket)
			self:visitExpression(field.key)
			self:visitSymbol(field.tokens.closeBracket)
			self:visitAssign(field.tokens.assign)
		end

		self:visitExpression(field.value)
		if literal.fields.separators[i] ~= nil then
			self:visitSymbol(literal.fields.separators[i])
		end
	end
	self:visitSymbol(literal.closeBrace)
end

---@param vararg? VarArgExpression If nil, this is a rest parameter in a func def
function Visitor:visitVarArg(vararg)
	self:visitSymbol("...")
end

---@param scope Scope
function Visitor:visitScope(scope)

end

---@param binding ScopeMember
function Visitor:visitBinding(binding)

end

---@param funcDef FunctionExpression
function Visitor:visitFuncDefExpr(funcDef)
	self:visitKeyword(funcDef.functionToken)
	self:visitFuncImpl(funcDef.impl)
end

---@param prefix PrefixExpression
function Visitor:visitPrefix(prefix)
	if prefix.subtype == "identifier" then self:visitAccess(prefix)
	elseif prefix.subtype == "index" then self:visitAccess(prefix)
	elseif prefix.subtype == "dot" then self:visitAccess(prefix)
	elseif prefix.subtype == "call" then
		self:visitFunctionCall(prefix.call, false)
	elseif prefix.subtype == "group" then
		self:visitSymbol(prefix.openParen)
		self:visitExpression(prefix.inner)
		self:visitSymbol(prefix.closeParen)
	end
end

---@param access PrefixAccessExpression
function Visitor:visitAccess(access)
	if access.subtype == "identifier" then
		if access.binding ~= nil then
			self:visitBinding(access.binding)
		end
		-- util.eprint("\x1b[33mIdentifier is not bound to a scope: " .. access.inner .. "\x1b[39m")
		self:visitIdentifier(access.inner)
	elseif access.subtype == "dot" then
		self:visitPrefix(access.left)
		self:visitSymbol(".")
		self:visitIdentifier(access.sub)
	elseif access.subtype == "index" then
		self:visitPrefix(access.left)
		self:visitSymbol("[")
		self:visitExpression(access.sub)
		self:visitSymbol("]")
	end
end

---@param define PrefixIdentifierAccessExpression
---@param isLocal boolean
---@param isFunction boolean
function Visitor:visitDefinition(define, isLocal, isFunction)
	if define.binding ~= nil then
		self:visitBinding(define.binding)
	end
	self:visitIdentifier(define.inner)
end

---@param expr BinaryExpression
function Visitor:visitBinary(expr)
	self:visitExpression(expr.left)
	self:visitOperator(expr.operator)
	self:visitExpression(expr.right)
end

---@param expr UnaryExpression
function Visitor:visitUnary(expr)
	self:visitOperator(expr.operator)
	self:visitExpression(expr.right)
end

return Visitor
