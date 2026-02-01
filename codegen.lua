local Visitor = require("ASTVisitor")
local util = require("util")
local codegen = {}

---@param chunk Chunk
---@param color boolean
function codegen.generate(chunk, color)
	---@type Token[]
	local outputTokens = {}
	---@type Visitor
	local visitorPrototype = {}

	function visitorPrototype:visitKeyword(kw)
		table.insert(outputTokens, {type="keyword",value=kw})
	end
	function visitorPrototype:visitIdentifier(ident)
		table.insert(outputTokens, {type="identifier",value=ident})
	end
	function visitorPrototype:visitAssign(assign)
		table.insert(outputTokens, {type="assign",value=assign})
	end
	function visitorPrototype:visitSymbol(symbol)
		table.insert(outputTokens, {type="symbol",value=symbol})
	end
	function visitorPrototype:visitNilLiteral(_)
		table.insert(outputTokens, {type="nil"})
	end
	function visitorPrototype:visitBoolLiteral(literal)
		table.insert(outputTokens, {type="bool",value=literal.value})
	end
	function visitorPrototype:visitNumLiteral(literal)
		table.insert(outputTokens, {type="number",value=literal.value})
	end

	local visitor = Visitor.create(visitorPrototype)
	visitor:visitChunk(chunk)

	local output = ""
	for _,token in ipairs(outputTokens) do
		local str, needsSpace = "", false
		if token.type == "keyword" then
			str = util.formatKeyword(token.value, color)
			needsSpace = true
		elseif token.type == "identifier" then
			str = util.formatIdentifier(token.value, color)
			needsSpace = true
		elseif token.type == "assign" then
			str = token.value
		elseif token.type == "symbol" then
			str = token.value
		elseif token.type == "nil" then
			str = util.formatLiteral("nil", color)
			needsSpace = true
		elseif token.type == "bool" then
			str = util.formatLiteral(token.value, color)
			needsSpace = true
		elseif token.type == "number" then
			str = util.formatLiteral(token.value, color)
			needsSpace = true
		end

		if needsSpace and output:sub(-1,-1):match("[a-zA-Z0-9]") and #output > 0 then
			output = output .. " "
		end
		output = output .. str
	end

	return output
end

return codegen
