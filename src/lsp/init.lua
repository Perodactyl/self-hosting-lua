-- Alternative entry point
package.path = "src/?.lua;src/?/init.lua;" .. package.path

local util = require("util")
local lspTypes = require("types.lsp")
local Source = require("source")
local Parser = require("parser")
local jsonrpc = require("lsp.jsonrpc")
local transformer = require("transformer")

local logFile = io.open("lsp-debug.log", "a")
local logImpl
local logLevelMap = {
	err = 1,
	warn = 2,
	normal = 3,
	info = 4,
	debug = 5,
}
local targetLogLevel = 5

if logFile ~= nil then
	logFile:write("\x1b[3J\x1b[H")
	logFile:flush()
	---@param message string
	---@param logLevel? "err" | "warn" | "info" | "debug" | "normal"
	logImpl = function(message, logLevel)
		if logLevelMap[logLevel or "normal"] > targetLogLevel then
			return
		end
		logFile:write("\x1b[33m[" .. os.date("%T") .. "]\x1b[39m " .. message .. "\n")
		logFile:flush()
		-- io.stderr:write(message .. "\n")
		-- io.stderr:flush()
	end
else
	---@param message string
	---@param logLevel? "err" | "warn" | "info" | "debug" | "normal"
	logImpl = function(message, logLevel)
		if logLevelMap[logLevel or "normal"] > targetLogLevel then
			return
		end
		io.stderr:write(message .. "\n")
		io.stderr:flush()
	end
	logImpl("Failed to open log file")
end

local function loggerFor(scope)
	return function(message, logLevel)
		local scopePart = "\x1b[32m[" .. scope .. "]\x1b[39m " .. (" "):rep(16 - #scope - 2)
		local levelPart = ""
		if logLevel == nil then logLevel = "normal" end
		if logLevel == "err"    then levelPart = "   \x1b[91m[ERR]\x1b[39m " end
		if logLevel == "warn"   then levelPart = "  \x1b[93m[WARN]\x1b[39m " end
		if logLevel == "normal" then levelPart = "   \x1b[36m[log]\x1b[39m " end
		if logLevel == "info"   then levelPart = "  \x1b[34;2m[\x1b[3minfo\x1b[23m]\x1b[39;22m " end
		if logLevel == "debug"  then levelPart = " \x1b[90m[\x1b[3mdebug\x1b[23m]\x1b[39m " end
		logImpl(scopePart .. levelPart .. message, logLevel or "normal")
	end
end

_G.log = loggerFor("globalScope")
local log = loggerFor("main")

local function loadModule(name)
	local logger = loggerFor(name)

	local exe, loadError = loadfile("src/lsp/modules/" .. name .. ".lua", "t", setmetatable({
		log = logger
	}, {
		__index = _G
	}))

	if exe == nil then
		loggerFor("moduleLoader")("Failed to load " .. name .. ": " .. loadError, "err")
		error("Error while loading " .. name, 0)
	end

	local success, result = pcall(exe)

	if not success then
		loggerFor("moduleLoader")(result)
		error("Error while loading " .. name, 0)
	end

	return result
end

---@class LSPServerModule
---@field client JSONObject
---@field update fun(self, doc: LSPServerOpenDocument)
---@field handleRequest fun(self, request: LSPRequestMessage, server: LSPServer): boolean|"continue"
---@field handleNotification fun(self, notification: LSPNotificationMessage, server: LSPServer): boolean|"continue"
---@field handleResponse fun(self, response: LSPResponseMessage, server: LSPServer): boolean|"continue"

---@class LSPServerOpenDocument
---@field uri LSPDocumentUri
---@field version integer
---@field currentText string
---@field currentSource Source
---@field currentParseResult Chunk | Error
---@field server {s:LSPServer}
local LSPServerOpenDocument = {}
function LSPServerOpenDocument:name()
	local root = self.server.s.client.rootUri
	if root ~= nil and self.uri:sub(1,#root) == root then
		return self.uri:sub(#root+1)
	end
	if true then
		local pathTrunk = self.uri:gsub("/[^/]+$", "/")
		for uri,_ in pairs(self.server.s.documents) do
			for i = 1, #pathTrunk do
				if uri:sub(i,i) ~= pathTrunk:sub(i,i) then
					pathTrunk = uri:sub(1,i)
					break
				end
			end
		end
		return self.uri:sub(#pathTrunk+1)
	end
	return self.uri:gsub("^file://", "", 1)
end

function LSPServerOpenDocument:stringify()
	return "\x1b[95;3m" .. self:name() .. "\x1b[39;23m"
end

---@param position LSPPosition
---@return integer
function LSPServerOpenDocument:lookupCharPos(position)
	local pattern = "^" .. (".-\n"):rep(position.line) .. ("."):rep(position.character)
	local _, matchEnd = self.currentText:find(pattern)
	return matchEnd + 1
end

---@class LSPServer
---@field initialized 0 | 1 | 2
---@field nextMessageId integer
---@field clientCapabilities JSONObject | nil
---@field modules List<LSPServerModule>
---@field documents table<LSPDocumentUri, LSPServerOpenDocument>
local LSPServer = {}

---@return LSPServer
function LSPServer.new()
	return setmetatable({
		initialized = 0,
		nextMessageId = 0,
		documents = util.List(),
		modules = util.List({
			loadModule("semanticTokens"),
			loadModule("diagnostics"),
			-- loadModule("fileOperations"),
		}),
	}, {__index=LSPServer})
end

function LSPServer:messageId()
	self.nextMessageId = self.nextMessageId + 1
	return self.nextMessageId - 1
end

---@param identifier LSPTextDocumentIdentifier | LSPDocumentUri
---@return LSPServerOpenDocument
function LSPServer:getDocument(identifier)
	return self.documents[identifier.uri or identifier]
end

function LSPServer:update(uri)
	local doc = self:getDocument(uri)
	log("Updating " .. doc:stringify(), "info")

	local source = Source.new(doc.uri, doc.currentText)
	local result = Parser.new(source):parseChunk()

	doc.currentSource = source
	doc.currentParseResult = result
	if not result.isError then
		---@cast result -Error
		transformer.bind(result)
	end

	for _,module in ipairs(self.modules) do
		module:update(doc)
	end
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
	-- log("Receiving request " .. request.id .. ": " .. request.method)
	if request.method == "initialize" then
		if self.initialized ~= 0 then error("Additional initialize request") end
		self.client = request.params --[[@as JSONObject]]
		do
			local connectMessage = "Client "
			if self.client.clientInfo ~= nil then
				connectMessage = connectMessage .. "\x1b[33m" .. self.client.clientInfo.name .. "\x1b[39m "
				if self.client.clientInfo.version ~= nil then
					connectMessage = connectMessage .. "\x1b[32m" .. self.client.clientInfo.version .. "\x1b[39m "
				end
			end
			connectMessage = connectMessage .. " connecting"
			log(connectMessage)
		end
		self:sendMessage({
			id = request.id,
			result = {
				capabilities = util.tableUtils.merge(
					{
						positionEncoding = "utf-8",
						textDocumentSync = {
							openClose = true,
							change = 2,
						},
					},
					table.unpack(self.modules:getEach("capabilities"))
				),
				serverInfo = {
					name = "MyLua",
					version = "beta",
				},
			},
		})
		self.initialized = 1
		return
	end

	local handled
	for _,module in ipairs(self.modules) do
		handled = module:handleRequest(request, self)
		if handled and handled ~= "continue" then break end
	end

	if not handled then
		log("Request " .. request.id .. " (" .. request.method .. ") unhandled; respond with MethodNotFound", "warn")
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
	local handled
	for _,module in ipairs(self.modules) do
		handled = module:handleResponse(response, self)
		if handled and handled ~= "continue" then break end
	end

	if not handled then
		log("Received unhandled response: " .. response.id, "warn")
	end
end

---@param notification LSPNotificationMessage
function LSPServer:handleNotification(notification)
	-- log("Receiving notification: " .. notification.method)
	if notification.method == "initialized" then
		if self.initialized ~= 1 then error("Bad initialization") end
		self.initialized = 2
		log("Connection initialized successfully")
		return
	elseif notification.method == "textDocument/didOpen" then
		local doc = notification.params.textDocument --[[@as LSPTextDocumentItem]]

		self.documents[doc.uri] = setmetatable({
			uri = doc.uri,
			version = doc.version,
			currentText = doc.text,
			server = setmetatable({s=self}, {__mode="v"})
		}, {__index=LSPServerOpenDocument})

		log("Added document " .. self.documents[doc.uri]:stringify())

		self:update(doc.uri)
		return
	elseif notification.method == "textDocument/didChange" then
		local doc = notification.params.textDocument --[[@as LSPVersionedTextDocumentIdentifier]]
		local target = self:getDocument(doc)
		target.version = doc.version
		local changes = notification.params.contentChanges --[[@as List<LSPTextDocumentContentChangeEvent>]]

		for _,change in ipairs(changes) do
			if change.range == nil then
				target.currentText = change.text
			else
				local startChar = target:lookupCharPos(change.range.start)
				local endChar = target:lookupCharPos(change.range["end"])
				local beforeContent = target.currentText:sub(1,startChar-1)
				local afterContent = target.currentText:sub(endChar)
				--[[ log(
					util.format.string(beforeContent, true, false, "lua5.2") .. " " ..
					util.format.string(change.text, true, false, "lua5.2") .. " " ..
					util.format.string(afterContent, true, false, "lua5.2")
				) ]]
				target.currentText = beforeContent .. change.text .. afterContent
			end
		end

		-- log("Text:\n" .. target.currentText, "normal")

		self:update(doc.uri)
		return
	end

	local handled
	for _,module in ipairs(self.modules) do
		handled = module:handleNotification(notification, self)
		if handled and handled ~= "continue" then break end
	end

	if not handled then
		log("Received unhandled notification: " .. notification.method, "info")
	end
end

---@param message JSONObject
function LSPServer:sendMessage(message)
	-- log("Sending: " .. util.prettyOutput.dump(message))
	jsonrpc.send(message)
end

function LSPServer:exit()
	log("Exiting")
end

local server = LSPServer.new()

local function loop()
	while true do
		local message = jsonrpc.receive()
		if message == nil then
			server:exit()
			break
		else
			server:handleMessage(message)
		end
	end
end

local success, errorMessage = xpcall(loop, debug.traceback)

if not success then
	log(errorMessage, "err")
	pcall(function()
		-- send error to LSP client
	end)
	os.exit(1)
end
