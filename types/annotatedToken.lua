---@meta

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
