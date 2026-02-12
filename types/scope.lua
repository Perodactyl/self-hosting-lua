---@meta

---@class ScopeVariable
---@field type "variable"
---@field name string
---@field external boolean If true, cannot be renamed
---@field isFunction boolean For semanticTokens (will be expanded upon later)
---@field isStdLib boolean

---@alias ScopeMember ScopeVariable
---@alias ScopeMemberType "variable"

---@class Scope
---@field parent? Scope
---@field members ScopeMember[]

