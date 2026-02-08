-- Alternative entry point
package.path = "src/?.lua;src/?/init.lua;" .. package.path

local util = require("util")
local lspTypes = require("types.lsp")
local Source = require("source")

local logFile = io.open("lsp-debug.log", "a")
local log
if logFile ~= nil then
	log = function(message)
		logFile:write("[" .. os.date("%T") .. "] " .. message .. "\n")
		logFile:flush()
		io.stderr:write(message .. "\n")
		io.stderr:flush()
	end
else
	log = function(message)
		io.stderr:write(message .. "\n")
		io.stderr:flush()
	end
	log("Failed to open log file")
end

log("Hello, World!")

---@class LSPServerOpenDocument
---@field doc LSPTextDocumentItem
---@field source Source
---@field tree? Chunk
---@field diagnostics LSPDiagnostic[]

---@class LSPServer
---@field initialized 0 | 1 | 2
---@field nextMessageId integer
---@field clientCapabilities JSONObject | nil
---@field documents List<LSPServerOpenDocument>
local LSPServer = {}

---@return LSPServer
function LSPServer.new()
	return setmetatable({
		initialized = 0,
		nextMessageId = 0,
		documents = util.List(),
	}, {__index=LSPServer})
end

function LSPServer:messageId()
	self.nextMessageId = self.nextMessageId + 1
	return self.nextMessageId - 1
end

---@param message JSONObject
function LSPServer:handleMessage(message)
	-- log("Receiving: " .. util.prettyOutput.dump(message))
	-- print(util.prettyOutput.dump(message))
	if message.id ~= nil and message.params ~= nil then
		self:handleRequest(message)
	elseif message.id == nil then
		self:handleNotification(message)
	elseif message.id ~= nil and (message.result ~= nil or message.error ~= nil) then
		self:handleResponse(message)
	end
end

---@param request LSPRequestMessage
function LSPServer:handleRequest(request)
	log("Receiving request " .. request.id .. ": " .. request.method)
	if request.method == "initialize" then
		if self.initialized ~= 0 then error("Additional initialize request") end
		self.clientCapabilities = request.params.capabilities --[[@as JSONObject]]
		self:sendMessage({
			id = request.id,
			result = {
				capabilities = {
					positionEncoding = "utf-8",
					textDocumentSync = 1,
					diagnosticProvider = {
						interFileDependencies = false,
						workspaceDiagnostics = false,
					},
				}
			}
		})
		self.initialized = 1
	elseif request.method == "textDocument/diagnostic" then
		self:publishDiagnostics(request.params.textDocument.uri, request.id)
	else
		log("Responding with MethodNotFound")
		self:sendMessage({
			id = request.id,
			error = {
				code = lspTypes.ResponseCode.METHOD_NOT_FOUND,
				message = "Unimplemented",
			},
		})
	end
end

---@param response LSPResponseMessage
function LSPServer:handleResponse(response)
	log("Receiving response: " .. response.id)
end

---@param notification LSPNotificationMessage
function LSPServer:handleNotification(notification)
	log("Receiving notification: " .. notification.method)
	if notification.method == "initialized" then
		if self.initialized ~= 1 then error("Bad initialization") end
		self.initialized = 2
		log("Initialization complete")
	elseif notification.method == "textDocument/didOpen" then
		local doc = notification.params.textDocument --[[@as LSPTextDocumentItem]]
		local source = Source.new(doc.uri, doc.text)

		table.insert(self.documents, {
			doc = doc,
			source = source,
			tree = nil,
			diagnostics = util.List({
				{
					range = {
						start = { line = 0, character = 0 },
						["end"] = { line = 0, character = 4 },
					},
					message = "It works!",
				},
			}),
		})
	end
end

---@param message JSONObject
function LSPServer:sendMessage(message)
	log("Sending: " .. util.prettyOutput.dump(message))
	message.jsonrpc = "2.0"
	local text = util.json.stringify(message, false)
	local headers = {["Content-Length"]=#text}
	local resultMessage = ""
	for k,v in pairs(headers) do
		resultMessage = resultMessage .. k .. ": " .. tostring(v) .. "\r\n"
	end
	resultMessage = resultMessage .. "\r\n" .. text

	io.stdout:write(resultMessage)
	io.stdout:write("\r\n")
	io.stdout:flush()
end

function LSPServer:publishDiagnostics(uri, requestID)
	local doc = self.documents:find(function(d) return d.doc.uri == uri end)
	if doc == nil then return end
	self:sendMessage({
		id = requestID,
		method = not requestID and "textDocument/publishDiagnostics" or nil,
		result = {
			kind = "full",
			items = doc.diagnostics,
		}
	})
end

local function launch()
	local server = LSPServer.new()

	local headerPart = ""
	while true do
		local char = io.stdin:read("L")
		headerPart = headerPart .. char
		-- log(util.prettyOutput.dump(block))

		local headerEnd = headerPart:find("\r\n\r\n")
		if headerEnd ~= nil then
			local headers = {}
			local i = 1
			while true do
				local lineEnd,nextLine = headerPart:find("\r?\n", i)
				local line = headerPart:sub(i, lineEnd)
				i = nextLine + 1
				-- print(util.formatString(line, true, false, "lua5.2"))
				if line == "" or line == "\r" then
					break
				end
				local left, right = line:match("([-a-zA-Z]+): *([-0-9a-zA-Z]+)")
				if left == nil then
					error("Not a header: " .. util.format.string(line, true, false, "lua5.2"))
				else
					headers[left] = right
				end
			end

			if headers["Content-Length"] == nil then
				error("JsonRPC message missing Content-Length header", 2)
			end

			local data = io.stdin:read(tonumber(headers["Content-Length"]))
			local result = util.json.parse(data)

			if util.json.type(result) ~= "object" then
				error("Message must be an object")
			end
			---@cast result JSONObject
			if result.jsonrpc ~= "2.0" then
				error("Message is not valid JsonRPC: jsonrpc = " .. util.json.stringify(result.jsonrpc, true))
			end

			-- log("Streamed in: " .. util.prettyOutput.dump(result,true))
			server:handleMessage(result)
			headerPart = ""
		else
			-- log(util.prettyOutput.dump(headerPart))
		end
	end
end

local success, errorMessage = pcall(launch)

if not success then
	log(errorMessage)
	error(errorMessage, 0)
end
