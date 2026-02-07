---@meta

---@class ScopeVariable
---@field type "variable"
---@field name string
---@field external boolean If true, cannot be renamed

---@alias ScopeMember ScopeVariable
---@alias ScopeMemberType "variable"

---@class Scope
---@field parent? Scope
---@field members ScopeMember[]

