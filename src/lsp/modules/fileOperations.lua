---@diagnostic disable: unused-local (remove outside of this template)
local util = require("util")

---@class LSPFileOperationsServerModule: LSPServerModule
local FileOperations = {}

FileOperations.capabilities = {

}

---@param doc LSPServerOpenDocument
function FileOperations:update(doc)

end

---@param request LSPRequestMessage
---@param server LSPServer
---@return boolean|"continue" handled
function FileOperations:handleRequest(request, server)
	return false
end

---@param response LSPResponseMessage
---@param server LSPServer
---@return boolean|"continue" handled
function FileOperations:handleResponse(response, server)
	return false
end

---@param notification LSPNotificationMessage
---@param server LSPServer
---@return boolean|"continue" handled
function FileOperations:handleNotification(notification, server)
	if notification.method == "textDocument/didSave" then
		log("Saved " .. notification.params.textDocument.uri)
		return true
	end
	return false
end

return FileOperations
