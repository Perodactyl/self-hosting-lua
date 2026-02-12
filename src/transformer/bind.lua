local Visitor = require("ASTVisitor")

---@class Scope
local Scope = {}

---@param parent? Scope
---@return Scope
function Scope.new(parent)
	return setmetatable({parent=parent,members={}}, {__index=Scope})
end

---@param member ScopeMember
function Scope:bind(member)
	table.insert(self.members, member)
	return member
end

---@param type ScopeMemberType
---@param name string
---@return ScopeMember | nil
function Scope:ref(type, name)
	for _,member in ipairs(self.members) do
		if member.type == type and member.name == name then
			return member
		end
	end
	if self.parent then return self.parent:ref(type, name) end
	return nil
end

---@param chunk Chunk
return function(chunk)
	local GlobalScope = Scope.new(nil)
	GlobalScope:bind({type="variable",name="print",external=true,isFunction=true,isStdLib=true})

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

	function proto:visitDefinition(define, isLocal, isFunction)
		Visitor.visitDefinition(self, define, isLocal, isFunction)
		if isLocal then
			define.binding = scope:bind({type="variable", name=define.inner.value,external=false,isFunction=isFunction,isStdLib=false})
		else
			define.binding = scope:ref("variable", define.inner.value)
			if define.binding == nil then
				define.binding = GlobalScope:bind({type="variable", name=define.inner.value,external=false,isFunction=isFunction,isStdLib=false})
			end
		end
	end

	function proto:visitAccess(access)
		Visitor.visitAccess(self, access)
		if access.subtype == "identifier" then
			access.binding = scope:ref("variable", access.inner.value)
		end
	end

	-- require("debugger")()
	Visitor.create(proto):visitChunk(chunk)

	return chunk
end
