local util = require("util")

---@param parts Annotation[]
---@param color boolean
---@return string
return function(parts, color)
	local output = ""
	local depth = 0

	for _,part in ipairs(parts) do
		if part.type == "token" then
			local token = part.inner

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
			elseif token.type == "string" then
				str = util.formatString(token.value, color, false, "lua5.1")
			end

			if needsSpace and output:sub(-1,-1):match("[a-zA-Z0-9]") and #output > 0 then
				output = output .. " "
			end
			output = output .. str
		elseif part.type == "blockStart" then
			depth = part.depth
		elseif part.type == "blockEnd" then
			depth = part.depth - 1
			output = output .. "\n" .. ("\t"):rep(depth)
		elseif part.type == "statementStart" and #output > 0 then
			output = output .. "\n" .. ("\t"):rep(depth)
		end
	end

	return output
end
