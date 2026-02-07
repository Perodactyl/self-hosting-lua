local Visitor = require("ASTVisitor")
-- local util = require("util")

---@class TokenAnnotation
---@field type "token"
---@field inner Token

---@class BlockStartAnnotation
---@field type "blockStart"
---@field depth integer

---@class BlockEndAnnotation
---@field type "blockEnd"
---@field depth integer

---@class StatementStartAnnotation
---@field type "statementStart"

---@class StatementEndAnnotation
---@field type "statementEnd"

---@alias Annotation TokenAnnotation | BlockStartAnnotation | BlockEndAnnotation | StatementStartAnnotation | StatementEndAnnotation

---@param chunk Chunk
---@return Annotation[]
return function(chunk)
	---@type Annotation[]
	local output = {}

	---@type Visitor
	local proto = {}
	local depth = 0

	function proto:visitKeyword(kw)
		table.insert(output, {type="token",inner={type="keyword",value=kw}})
	end
	function proto:visitIdentifier(ident)
		table.insert(output, {type="token",inner={type="identifier",value=ident}})
		print("Outputted token " .. ident)
	end
	function proto:visitAssign(assign)
		table.insert(output, {type="token",inner={type="assign",value=assign}})
	end
	function proto:visitSymbol(symbol)
		table.insert(output, {type="token",inner={type="symbol",value=symbol}})
	end
	function proto:visitNilLiteral(_)
		table.insert(output, {type="token",inner={type="nil"}})
	end
	function proto:visitBoolLiteral(literal)
		table.insert(output, {type="token",inner={type="bool",value=literal.value}})
	end
	function proto:visitNumLiteral(literal)
		table.insert(output, {type="token",inner={type="number",value=literal.value}})
	end
	function proto:visitStringLiteral(literal)
		table.insert(output, {type="token",inner={type="string",value=literal.value}})
	end
	function proto:visitAccess(access)
		if access.subtype == "identifier" and access.binding ~= nil then
			self:visitIdentifier(access.binding.name)
		else
			Visitor.visitAccess(self, access)
		end
	end
	function proto:visitBlock(block)
		table.insert(output, {type="blockStart", depth=depth})
		depth = depth + 1
		Visitor.visitBlock(self, block)
		depth = depth - 1
		table.insert(output, {type="blockEnd", depth=depth})
	end
	function proto:visitStatement(statement)
		table.insert(output, {type="statementStart"})
		Visitor.visitStatement(self, statement)
		table.insert(output, {type="statementEnd"})
	end

	local visitor = Visitor.create(proto)
	visitor:visitChunk(chunk)

	return output
end
