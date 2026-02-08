-- Alternative entry point
package.path = "src/?.lua;src/?/init.lua;" .. package.path

local util = require("util")
local lspTypes = require("types.lsp")
local Source = require("source")
local Parser = require("parser")
local jsonrpc = require("lsp.jsonrpc")

local semanticTokens = require("lsp.semanticTokens")

local logFile = io.open("lsp-debug.log", "a")
local log
if logFile ~= nil then
	log = function(message)
		logFile:write("[" .. os.date("%T") .. "] " .. message .. "\n")
		logFile:flush()
		-- io.stderr:write(message .. "\n")
		-- io.stderr:flush()
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
---@field diagnostics LSPDiagnostic[]
---@field semanticTokens integer[]

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
					semanticTokensProvider = {
						legend = {
							tokenTypes = semanticTokens.typeLegend,
							tokenModifiers = semanticTokens.modifierLegend,
						},
						range = false,
						full = true,
					},
					-- documentSymbolProvider = true,
				}
			}
		})
		self.initialized = 1
	elseif request.method == "textDocument/diagnostic" then
		self:publishDiagnostics(request.params.textDocument.uri, request.id)
	elseif request.method == "textDocument/semanticTokens/full" then
		self:publishSemanticTokens(request.params.textDocument.uri, request.id)
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

		table.insert(self.documents, {
			doc = doc,
			diagnostics = util.List(),
		})
		self:update(doc.uri)
	elseif notification.method == "textDocument/didChange" then
		local doc = notification.params.textDocument --[[@as LSPVersionedTextDocumentIdentifier]]
		local target = self.documents:find(function(d) return d.doc.uri == doc.uri end)
		if target == nil then return end
		target.doc.version = doc.version
		local changes = notification.params.contentChanges --[[@as List<LSPTextDocumentContentChangeEvent>]]

		for _,change in ipairs(changes) do
			target.doc.text = change.text
		end

		self:update(doc.uri)
	end
end

---@param message JSONObject
function LSPServer:sendMessage(message)
	log("Sending: " .. util.prettyOutput.dump(message))
	jsonrpc.send(message)
end

function LSPServer:update(uri)
	local doc = self.documents:find(function(d) return d.doc.uri == uri end)
	if doc == nil then return end
	log("Updating " .. doc.doc.uri)

	local diagnostics = util.List()

	local source = Source.new(doc.doc.uri, doc.doc.text)
	local result = Parser.new(source):parseChunk()
	if result.isError then
		diagnostics:push({
			message = result:stringify(false),
			range = result.span:toRange()
		})
	end

	doc.diagnostics = diagnostics

	local tokens = util.List()

	local lastLine, lastStartChar = 0, 0
	for _,token in ipairs(source.sourceTokens.buffer) do
		local span, type = token.span, token.type
		local range = span:toRange()

		local semanticTokenType = type --[[@as string]]
		if type == "nilLiteral" then semanticTokenType = "constant" end
		if type == "boolLiteral" then semanticTokenType = "constant" end
		if type == "string" then semanticTokenType = "string" end
		if type == "number" then semanticTokenType = "number" end
		if type == "keyword" then semanticTokenType = "keyword" end
		if type == "operator" then semanticTokenType = "operator" end
		if type == "symbol" then semanticTokenType = "operator" end
		if type == "assign" then semanticTokenType = "operator" end
		if type == "identifier" then semanticTokenType = "variable" end

		local line, startChar = range.start.line, range.start.character
		log("Line: " .. line .. " startChar: " .. startChar)
		local deltaLine, deltaStartChar = line - lastLine, startChar - lastStartChar
		if deltaLine > 0 then deltaStartChar = startChar end
		lastLine, lastStartChar = line, startChar
		local length = span.stop - span.start + 1

		local tokenType = (semanticTokens.typeLegend[semanticTokenType] or 0) - 1
		local tokenModifiers = 0

		tokens:push(deltaLine, deltaStartChar, length, tokenType, tokenModifiers)
		-- break
	end

	doc.semanticTokens = tokens
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

function LSPServer:publishSemanticTokens(uri, requestID)
	local doc = self.documents:find(function(d) return d.doc.uri == uri end)
	if doc == nil then return end
	self:sendMessage({
		id = requestID,
		-- method = not requestID and "textDocument/publishDiagnostics" or nil,
		result = {
			data = doc.semanticTokens
		}
	})
end

local function launch()
	local server = LSPServer.new()

	while true do
		local message = jsonrpc.receive()
		server:handleMessage(message)
	end
end

local success, errorMessage = pcall(launch)

if not success then
	log(errorMessage)
	error(errorMessage, 0)
end
