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
	self:visitSymbol(";")
end

---@param assignment Assignment
function Visitor:visitAssignment(assignment)
	if assignment.isLocal then self:visitKeyword("local") end
	for i,var in ipairs(assignment.variables) do
		if assignment.isLocal then
			self:visitDefinition(var --[[@as PrefixIdentifierAccessExpression]], true)
		else
			self:visitAccess(var)
		end
		if i ~= #assignment.variables then
			self:visitSymbol(",")
		end
	end
	self:visitAssign("=")
	for i,val in ipairs(assignment.values) do
		self:visitExpression(val)
		if i ~= #assignment.values then
			self:visitSymbol(",")
		end
	end
end

---@param call FunctionCall
---@param isStatement boolean
function Visitor:visitFunctionCall(call, isStatement)
	self:visitPrefix(call.callee)
	if call.method ~= nil then
		self:visitSymbol(":")
		self:visitIdentifier(call.method)
	end
	self:visitSymbol("(")
	for i,arg in ipairs(call.args) do
		self:visitExpression(arg)
		if i ~= #call.args then
			self:visitSymbol(",")
		end
	end
	self:visitSymbol(")")
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
	self:visitKeyword("if")
	self:visitExpression(ifStatement.condition)
	self:visitKeyword("then")
	self:visitBlock(ifStatement.body)
	for _,elseifBranch in ipairs(ifStatement.elseifs) do
		self:visitKeyword("elseif")
		self:visitExpression(elseifBranch.condition)
		self:visitKeyword("then")
		self:visitBlock(elseifBranch.body)
	end
	if ifStatement.elseBody then
		self:visitKeyword("else")
		self:visitBlock(ifStatement.elseBody)
	end
	self:visitKeyword("end")
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
	if funcDef.isLocal then self:visitKeyword("local") end
	self:visitKeyword("function")
	self:visitDefinition(funcDef.name.base, funcDef.isLocal)
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
	self:visitSymbol("(")
	for i,param in ipairs(impl.parameters) do
		self:visitIdentifier(param)
		if i ~= #impl.parameters then
			self:visitSymbol(",")
		end
	end
	if impl.rest then
		if impl.parameters ~= 0 then self:visitSymbol(",") end
		self:visitVarArg()
	end
	self:visitSymbol(")")

	self:visitBlock(impl.body)
	self:visitKeyword("end")
end

---@param returnStatement ReturnStatement
function Visitor:visitReturnStatement(returnStatement)
	self:visitKeyword("return")
	for _,expr in ipairs(returnStatement) do
		self:visitExpression(expr)
	end
end

---@param expr Expression
function Visitor:visitExpression(expr)
	if expr.type == "nil"         then self:visitNilLiteral(expr)
	elseif expr.type == "bool"    then self:visitBoolLiteral(expr)
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

---@param keyword Keyword
function Visitor:visitKeyword(keyword)

end

---@param ident string
function Visitor:visitIdentifier(ident)

end

---@param symbol Symbol
function Visitor:visitSymbol(symbol)

end

---@param assign Assign
function Visitor:visitAssign(assign)

end

---@param operator Operator
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
	self:visitSymbol("{")
	for i,field in ipairs(literal.value) do
		if field.key.type ~= "number" or field.key.value == i then
			self:visitSymbol("[")
			self:visitExpression(field.key)
			self:visitSymbol("]")
			self:visitAssign("=")
		end

		self:visitExpression(field.value)
		self:visitSymbol(",")
	end
	self:visitSymbol("}")
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
	self:visitKeyword("function")
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
		self:visitSymbol("(")
		self:visitExpression(prefix.inner)
		self:visitSymbol(")")
	end
end

---@param access PrefixAccessExpression
function Visitor:visitAccess(access)
	if access.subtype == "identifier" then
		if access.binding ~= nil then
			self:visitBinding(access.binding)
			self:visitIdentifier(access.binding.name)
		else
			-- util.eprint("\x1b[33mIdentifier is not bound to a scope: " .. access.inner .. "\x1b[39m")
			self:visitIdentifier(access.inner)
		end
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
function Visitor:visitDefinition(define, isLocal)
	if define.binding ~= nil then
		self:visitBinding(define.binding)
		self:visitIdentifier(define.binding.name)
	else
		self:visitIdentifier(define.inner)
	end
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
