local util = require("util")
local Visitor = require("ASTVisitor")

---@class LSPSemanticTokensServerModule: LSPServerModule
---@field semanticTokens table<LSPDocumentUri, integer[]>
local SemanticTokens = { semanticTokens = {} }

SemanticTokens.typeLegend = util.tableUtils.newEnum({
	"parameter",
	"variable",
	"property",
	"function",
	"method",
	"keyword",
	"comment",
	"string",
	"number",
	"operator",
	"constant",
}, "{k=v}")

SemanticTokens.modifierLegend = util.tableUtils.newEnum({
	"declaration",
	"definition",
	"defaultLibrary",
	"deprecated",
}, "{k=v}")

SemanticTokens.capabilities = {
	semanticTokensProvider = {
		legend = {
			tokenTypes = SemanticTokens.typeLegend,
			tokenModifiers = SemanticTokens.modifierLegend,
		},
		range = false,
		full = true,
	}
}

SemanticTokens.assumedGlobalFunctionNames = util.List({
	"print", "pairs", "ipairs",
	"assert", "collectgarbage",
	"dofile", "error", "load",
	"getmetatable", "setmetatable",
	"loadfile", "next", "pcall",
	"xpcall", "rawequal",
	"rawget", "rawlen", "rawset",
	"select", "type", "warn",
	"tonumber", "tostring",
})

local function locationOf(span)
	local range = span:toRange()
	return range.start.line, range.start.character, span.stop - span.start + 1
end

---@param doc LSPServerOpenDocument
function SemanticTokens:update(doc)
	local tokens = util.List()

	if doc.currentParseResult.isError then
		log("Using input token list because syntax tree is not generated", "info")
		local docTokens = doc.currentSource.sourceTokens.buffer
		for i,token in ipairs(docTokens) do
			local span, type = token.span, token.type

			local semanticTokenType = type --[[@as string]]
			local modifiers = util.List()
			if type == "nil" then semanticTokenType = "constant" end
			if type == "boolean" then semanticTokenType = "constant" end
			if type == "string" then semanticTokenType = "string" end
			if type == "number" then semanticTokenType = "number" end
			if type == "keyword" then semanticTokenType = "keyword" end
			if type == "operator" then
				if token.value == "and" or token.value == "or" or token.value == "not" then
					semanticTokenType = "keyword"
				else
					semanticTokenType = "operator"
				end
			end
			if type == "symbol" then semanticTokenType = "operator" end
			if type == "assign" then semanticTokenType = "operator" end
			if type == "identifier" then
				semanticTokenType = "variable"
				if self.assumedGlobalFunctionNames:includes(token.value) then
					semanticTokenType = "function"
					modifiers:push("defaultLibrary")
				end
				if i > 1 and util.tableUtils.deepEq(docTokens[i-1], {type="keyword",value="function"}, "a") then
					semanticTokenType = "function"
				elseif i < #docTokens and util.tableUtils.deepEq(docTokens[i+1], {type="symbol",value="("}, "a") then
					semanticTokenType = "function"
				end
			end

			tokens:push({span=span,type=semanticTokenType,modifiers=modifiers})
		end
	else
		---@type Visitor
		local proto = {}
		function proto:visitKeyword(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="keyword",modifiers={}})
		end
		function proto:visitOperator(token)
			if type(token) == "string" then return end
			if token.value == "and" or token.value == "or" or token.value == "not" then
				tokens:push({span=token.span,type="keyword",modifiers={}})
			else
				tokens:push({span=token.span,type="operator",modifiers={}})
			end
		end
		function proto:visitSymbol(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="operator",modifiers={}})
		end
		function proto:visitAssign(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="operator",modifiers={}})
		end
		function proto:visitStringLiteral(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="string",modifiers={}})
		end
		function proto:visitNumLiteral(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="number",modifiers={}})
		end
		function proto:visitBoolLiteral(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="constant",modifiers={}})
		end
		function proto:visitIdentifier(token)
			if type(token) == "string" then return end
			tokens:push({span=token.span,type="variable",modifiers={}})
		end
		function proto:visitAccess(access)
			if access.subtype == "identifier" and access.binding then
				if access.binding.isFunction then
					local modifiers = {}
					if access.binding.isStdLib then
						table.insert(modifiers, "defaultLibrary")
					end
					tokens:push({span=access.inner.span,type="function",modifiers=modifiers})
					return
				end
			end
			Visitor.visitAccess(self, access)
		end
		function proto:visitDefinition(define, isLocal, isFunction)
			Visitor.visitDefinition(self, define, isLocal, isFunction)
		end
		function proto:visitPrefix(prefix)
			if prefix.subtype == "call" then
				-- if access.binding.isFunction then
				-- 	local modifiers = {}
				-- 	if access.binding.isStdLib then
				-- 		table.insert(modifiers, "defaultLibrary")
				-- 	end
				-- 	tokens:push({span=access.inner.span,type="method",modifiers=modifiers})
				-- end
			end
			Visitor.visitPrefix(self, prefix)
		end

		Visitor.create(proto):visitChunk(doc.currentParseResult)
	end

	for _,comment in ipairs(doc.currentSource.sourceTokenizer.comments) do
		tokens:push({span=comment,type="comment",modifiers={}})
	end

	table.sort(tokens, function(a,b)
		if a.span.start < b.span.start then return true end
		-- if a.startChar < b.startChar then return true end
		return false
	end)

	local tokenData = util.List()
	local lastLine, lastStartChar = 0, 0
	for _,token in ipairs(tokens) do
		local line, startChar, length = locationOf(token.span)

		local deltaLine, deltaStartChar = line - lastLine, startChar - lastStartChar
		if deltaLine > 0 then deltaStartChar = startChar end
		lastLine, lastStartChar = line, startChar

		local tokenType = (SemanticTokens.typeLegend[token.type] or 0) - 1
		if tokenType == -1 then
			log("type " .. token.type .. " does not exist")
		end
		local tokenModifiers = 0
		for _,modifier in ipairs(token.modifiers) do
			local index = (SemanticTokens.modifierLegend[modifier] or 0) - 1
			tokenModifiers = tokenModifiers | (1 << index)
		end

		tokenData:push(deltaLine, deltaStartChar, length, tokenType, tokenModifiers)
	end

	self.semanticTokens[doc] = tokenData
	log("Updated semantic tokens", "debug")
end

---@param request LSPRequestMessage
---@param server LSPServer
---@return boolean|"continue" handled
function SemanticTokens:handleRequest(request, server)
	if request.method == "textDocument/semanticTokens/full" then
		local doc = server:getDocument(request.params.textDocument)
		server:sendMessage({
			id = request.id,
			result = {
				data = self.semanticTokens[doc]
			}
		})
		log("Responded for " .. doc:stringify(), "debug")
		return true
	end
	return false
end

---@param response LSPResponseMessage
---@param server LSPServer
---@return boolean|"continue" handled
function SemanticTokens:handleResponse(response, server)
	return false
end

---@param notification LSPNotificationMessage
---@param server LSPServer
---@return boolean|"continue" handled
function SemanticTokens:handleNotification(notification, server)
	return false
end

return SemanticTokens
