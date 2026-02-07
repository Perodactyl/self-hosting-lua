local Parser = require("parser")
-- local codegen = require("codegen")
local autotest = require("autotest")
local util = require("util")
local tests = require("tests")
-- local errorCtl = require("error")
local Source = require("source")
local Transformer = require("transformer")
local Visitor = require("ASTVisitor")

local function eprint(...) io.stderr:write(..., "\n") end

local src = Source.new("=transformer-test.lua", [[
local a = "global"
do
	function showA()
		print(a)
	end
	
	showA()
	local a = "block"
	showA()
end
]])

local parser = Parser.new(src)

local ast = parser:parseChunk()
if ast.isError then
	eprint(ast:stringify())
	os.exit(1)
end ---@cast ast -Error

Transformer.bind(ast)

print(util.dumpJSON(ast, false))
eprint(util.dump(ast, true, true))

eprint("\nRenaming all bindings")
do
	---@type Visitor
	local proto = {visitedBindings={}}

	local i = 1
	function proto:visitBinding(binding)
		if util.hasV(self.visitedBindings, binding) then
			return
		end
		if binding.external then
			return
		end
		local oldName = binding.name
		binding.name = "binding_" .. i
		print("naming " .. oldName .. " " .. binding.name)
		i = i + 1
		table.insert(self.visitedBindings, binding)
	end

	Visitor.create(proto):visitChunk(ast)
end

eprint("\nFlattening AST")
local tokens = Transformer.retokenize(ast)
eprint("Serializing Token Stream")
local output = Transformer.serializeTokens(tokens, true)

eprint(output)
