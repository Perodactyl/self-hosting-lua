local util = require("util")
local codegen = {}

---@param block Block
---@param indent boolean
---@return string
function codegen.block(block, indent)
	local outputLines = {}
	for _,statement in ipairs(block.statements) do
		local output = codegen.statement(statement)
		for line in output:gmatch("[^\n]+") do
			table.insert(outputLines, line)
		end
	end
	if block.returnStatement then
		local returns = {}
		for _,v in ipairs(block.returnStatement) do
			table.insert(returns, codegen.expression(v))
		end
		table.insert(outputLines, "return " .. table.concat(returns, ","))
	end
	return (indent and "\t" or "") .. table.concat(outputLines, indent and "\n\t" or "\n")
end

---@param statement Statement
---@return string
function codegen.statement(statement)
	if statement.type == "assignment" or statement.type == "localAssignment" then
		local kw = statement.type == "localAssignment" and "local " or ""
		local variables = {}
		for _,access in ipairs(statement.variables) do
			table.insert(variables, codegen.prefix(access))
		end
		local values = {}
		for _,expr in ipairs(statement.values) do
			table.insert(values, codegen.expression(expr))
		end
		return kw .. table.concat(variables,",") .. " = " .. table.concat(values,",")
	end
	if statement.type == "call" then return codegen.call(statement) end
	if statement.type == "funcDef" then return codegen.funcDef(statement, false) end
	if statement.type == "localFuncDef" then return codegen.funcDef(statement,true) end
	if statement.type == "forRange" then
		local output = "for " .. statement.iterVar .. " = "
		output = output .. codegen.expression(statement.min) .. "," .. codegen.expression(statement.max)
		if statement.step then output = output .. "," .. codegen.expression(statement.step) end
		output = output .. " do\n"
		output = output .. codegen.block(statement.body, true)
		output = output .. "\nend"
		return output
	end
	if statement.type == "if" then
		local output = "if " .. codegen.expression(statement.condition) .. " then\n"
		output = output .. codegen.block(statement.body, true)
		for _,part in ipairs(statement.elseifs) do
			output = output .. "\nelseif " .. codegen.expression(part.condition) .. " then\n"
			output = output .. codegen.block(part.body, true)
		end
		if statement.elseBody then
			output = output .. "\nelse\n"
			output = output .. codegen.block(statement.elseBody, true)
		end
		output = output .. "\nend"
		return output
	end
	error("TODO " .. statement.type)
end

---@param prefix PrefixExpression
---@return string
function codegen.prefix(prefix)
	if prefix.type ~= "prefix" then error("codegen.prefix called on " .. util.dump(prefix), 2) end
	if prefix.subtype == "identifier" then
		return prefix.inner
	elseif prefix.subtype == "dot" then
		return codegen.prefix(prefix.left) .. "." .. prefix.sub
	elseif prefix.subtype == "index" then
		return codegen.prefix(prefix.left) .. "[" .. codegen.expression(prefix.sub) .. "]"
	elseif prefix.subtype == "call" then
		return (codegen.call(prefix.call))
	elseif prefix.subtype == "group" then
		return (codegen.expression(prefix.inner))
	end
	error("Called codegen.prefix on " .. util.dump(prefix, true, true))
end

---@param call FunctionCall
---@return string
function codegen.call(call)
	local name = codegen.prefix(call.callee)
	if call.method ~= nil then
		name = name .. ":" .. call.method
	end

	local params = {}
	if call.args.type == "parenthesis" then
		for _,arg in ipairs(call.args.arguments) do
			table.insert(params, codegen.expression(arg))
		end
	else -- table or string
		table.insert(params, codegen.expression(call.args --[[@as Expression]]))
	end

	return name .. "(" .. table.concat(params, ",") .. ")"
end

---@param expr Expression
---@return string
function codegen.expression(expr)
	if expr.type == "prefix" then return codegen.prefix(expr --[[@as PrefixExpression]]) end
	if expr.type == "binary" then
		return codegen.expression(expr.left)
			.. " " .. expr.operator .. " "
			.. codegen.expression(expr.right)
	end
	if expr.type == "number" then return tostring(expr.value) end
	if expr.type == "nil" then return "nil" end
	if expr.type == "bool" then return tostring(expr.value) end
	if expr.type == "string" then return '"' .. tostring(expr.value) .. '"' end
	return expr.type
end

---@param def FunctionExpression | FuncDef | LocalFuncDef
---@param isLocal boolean
---@return string
function codegen.funcDef(def, isLocal)
	local output = "function"
	if isLocal then output = "local " .. output end
	if def.name then
		output = output .. " " .. def.name.base
		for _,access in ipairs(def.name.accesses) do
			output = output .. "." .. access
		end
		if def.name.method then
			output = output .. ":" .. def.name.method
		end
	end
	output = output .. "(" .. table.concat(def.parameters, ", ")
	if def.rest then output = output .. ", ..." end
	output = output .. ")\n"

	output = output .. codegen.block(def.body,true)
	output = output .. "\nend"

	return output
end

return codegen
