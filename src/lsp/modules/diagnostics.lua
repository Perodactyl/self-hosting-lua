local util = require("util")

---@class LSPDiagnosticsServerModule: LSPServerModule
local Diagnostics = { diagnostics = {} }

Diagnostics.capabilities = {
	diagnosticProvider = {
		interFileDependencies = false,
		workspaceDiagnostics = false,
	},
}

---@param doc LSPServerOpenDocument
function Diagnostics:update(doc)
	local diagnostics = util.List()

	if doc.currentParseResult.isError then
		local cause = doc.currentParseResult:findCause()
		diagnostics:push({
			message = cause:stringify(false),
			range = cause.span:toRange()
		})
	end

	self.diagnostics[doc] = diagnostics
	log("Updated diagnostics", "debug")
end

---@param request LSPRequestMessage
---@param server LSPServer
---@return boolean|"continue" handled
function Diagnostics:handleRequest(request, server)
	if request.method == "textDocument/diagnostic" then
		local doc = server:getDocument(request.params.textDocument)
		server:sendMessage({
			id = request.id,
			result = {
				kind = "full",
				items = self.diagnostics[doc]
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
function Diagnostics:handleResponse(response, server)
	return false
end

---@param notification LSPNotificationMessage
---@param server LSPServer
---@return boolean|"continue" handled
function Diagnostics:handleNotification(notification, server)
	return false
end

return Diagnostics
