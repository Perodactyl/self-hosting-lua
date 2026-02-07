local Visitor = require("ASTVisitor")

---@class Transformer
local Transformer = {}

Transformer.retokenize = require("transformer.retokenize")
Transformer.serializeTokens = require("transformer.serializeTokens")
Transformer.bind = require("transformer.bind")

return Transformer
