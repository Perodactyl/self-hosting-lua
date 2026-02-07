local Visitor = require("ASTVisitor")
local util = require("util")

---@class ScopeVariable
---@field type "variable"
---@field name string
---@field external boolean If true, cannot be renamed

---@alias ScopeMember ScopeVariable
---@alias ScopeMemberType "variable"

---@class Scope
---@field parent? Scope
---@field members ScopeMember[]
local Scope = {}

---@param parent? Scope
---@return Scope
function Scope.new(parent)
	return setmetatable({parent=parent,members={}}, {__index=Scope})
end

---@param member ScopeMember
function Scope:bind(member)
	table.insert(self.members, member)
	print("created " .. util.dump(member))
	return member
end

---@param type ScopeMemberType
---@param name string
---@return ScopeMember | nil
function Scope:ref(type, name)
	for _,member in ipairs(self.members) do
		if member.type == type and member.name == name then
			print("referenced " .. util.dump(member))
			return member
		end
	end
	if self.parent then return self.parent:ref(type, name) end
	return nil
end

---@param chunk Chunk
return function(chunk)
	local GlobalScope = Scope.new(nil)
	GlobalScope:bind({type="variable",name="print",external=true})

	local scope = GlobalScope
	---@type Visitor
	local proto = {}

	function proto:visitBlock(block)
		local newScope = Scope.new(scope)
		scope = newScope

		Visitor.visitBlock(self, block)

		scope = scope.parent
		block.scope = newScope
	end

	function proto:visitDefinition(define, isLocal)
		Visitor.visitDefinition(self, define, isLocal)
		if isLocal then
			define.binding = scope:bind({type="variable", name=define.inner,external=false})
		else
			define.binding = scope:ref("variable", define.inner)
			if define.binding == nil then
				define.binding = GlobalScope:bind({type="variable", name=define.inner,external=false})
			end
		end
	end

	function proto:visitAccess(access)
		Visitor.visitAccess(self, access)
		if access.subtype == "identifier" then
			access.binding = scope:ref("variable", access.inner)
		end
	end

	-- require("debugger")()
	Visitor.create(proto):visitChunk(chunk)

	return chunk
end
