local LazyStream = require("lazyStream")

---@class Parser
---@field tokenStream LazyStream<Token>
local Parser = {}

function Parser.new(tokenGenerator)
	local parser = { tokenStream = LazyStream.new(tokenGenerator) }
	return setmetatable(parser, {
		__index = Parser,
		__name = "Parser",
	})
end

require("parser.expression")(Parser)
require("parser.statement")(Parser)

function Parser:parseChunk()
	return self:parseBlock()
end

return Parser
