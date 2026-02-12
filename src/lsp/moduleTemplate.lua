---@diagnostic disable: unused-local (remove outside of this template)
local util = require("util")

---@class LSPExampleServerModule: LSPServerModule
local Example = {}

Example.capabilities = {

}

---@param doc LSPServerOpenDocument
function Example:update(doc)

end

---@param request LSPRequestMessage
---@param server LSPServer
---@return boolean|"continue" handled
function Example:handleRequest(request, server)
	return false
end

---@param response LSPResponseMessage
---@param server LSPServer
---@return boolean|"continue" handled
function Example:handleResponse(response, server)
	return false
end

---@param notification LSPNotificationMessage
---@param server LSPServer
---@return boolean|"continue" handled
function Example:handleNotification(notification, server)
	return false
end

return Example
