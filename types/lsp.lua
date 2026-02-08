---@meta
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/


---@alias LSPInteger integer
---@alias LSPUInteger integer
---@alias LSPDecimal number
---@alias LSPNull JSONNull
---@alias LSPAny LSPObject | LSPArray | string | LSPInteger | LSPUInteger | LSPDecimal | boolean | LSPNull
---@alias LSPObject table<string, LSPAny>
---@alias LSPArray List<LSPAny>

---@class LSPMessage: table<string, LSPAny>
---@field jsonrpc "2.0"

---@class LSPRequestMessage: LSPMessage
---@field id LSPInteger | string
---@field method string
---@field params LSPObject | LSPArray | nil

---Must be sent for any LSPRequestMessage; result can be null.
---@class LSPResponseMessage: LSPMessage
---Corresponds to the request ID.
---@field id LSPInteger | string | LSPNull
---MUST exist on success. MUST NOT exist on error.
---@field result LSPAny | nil
---@field error LSPResponseError | nil

---@class LSPResponseError
---@field code integer | LSPResponseCode
---@field message string
---@field data LSPAny | nil

---@enum LSPResponseCode
local ResponseCode = {
	PARSE_ERROR = -32700,
	INVALID_REQUEST = -32600,
	METHOD_NOT_FOUND = -32601,
	INVALID_PARAMS = -32602,
	INTERNAL_ERROR = -32603,

	_SERVER_RESERVED_START = -32099,
	SERVER_NOT_INITIALIZED = -32002,
	UNKNOWN_ERROR_CODE = -32001,
	_SERVER_RESERVED_END = -32000,

	_LSP_RESERVED_START = -32899,
	REQUEST_FAILED = -32803,
	SERVER_CANCELLED = -32802,
	CONTENT_MODIFIED = -32801,
	REQUEST_CANCELLED = -32800,
	_LSP_RESERVED_END = -32800,
}

---@class LSPNotificationMessage: LSPMessage
---@field method string
---@field params LSPArray | LSPObject | nil

---@class LSPCancelNotification: LSPNotificationMessage
---@field method "$/cancelRequest"
---@field params { id: LSPInteger | string }

---@class LSPProgressNotification: LSPNotificationMessage
---@field method "$/progress"
---@field params { token: unknown, value: LSPAny }

---@alias LSPDocumentUri string
---@alias LSPUri string

---@class LSPRegularExpressionsClientCapabilities
--don't care enough to write about this

---@class LSPPosition
---@field line LSPUInteger Zero-based
---@field character LSPUInteger Zero-based

---@alias LSPPositionEncodingKind "utf-8" | "utf-16" | "utf-32"

---@class LSPRange
---@field start LSPPosition
---@field end LSPPosition

---@class LSPTextDocumentItem
---@field uri LSPDocumentUri
---@field languageId string | "lua"
---@field version LSPInteger increases after each change
---@field text string

---@class LSPTextDocumentIdentifier
---@field uri LSPDocumentUri

---@class LSPVersionedTextDocumentIdentifier: LSPTextDocumentIdentifier
---@field version LSPInteger increases after each change

---@class LSPOptionalVersionedTextDocumentIdentifier: LSPTextDocumentIdentifier
---@field version LSPInteger | LSPNull

---@class LSPTextDocumentPositionParams
---@field textDocument LSPTextDocumentIdentifier
---@field position LSPPosition

---@class LSPDocumentFilter
---@field language string | nil
---@field scheme string | "file" | "untitled" | nil
---@field pattern string glob pattern | nil

---@alias LSPDocumentSelector LSPDocumentFilter[]

---@class LSPTextEdit
---@field range LSPRange
---@field newText string

---@class LSPLocation
---@field uri LSPDocumentUri
---@field range LSPRange

---@class LSPDiagnostic
---@field range LSPRange
---@field severity LSPDiagnosticSeverity | nil
---@field code LSPInteger | string | nil
---@field codeDescription string | nil
---@field source string | nil
---@field message string
---@field tags LSPDiagnosticTag[] | nil
---@field relatedInformation LSPDiagnosticRelatedInformation[] | nil
---@field data LSPAny | nil preserved between textDocument/publishDiagnostics and textDocument/codeAction

---@alias LSPTextDocumentContentChangeEvent { range: LSPRange, text: string } | { text: string }

---@enum LSPDiagnosticSeverity
local DiagnosticSeverity = {
	ERROR = 1,
	WARNING = 2,
	INFORMATION = 3,
	HINT = 4,
}

---@enum LSPDiagnosticTag
local DiagnosticTag = {
	UNNECESSARY = 1,
	DEPRECATED = 2,
}

---@class LSPDiagnosticRelatedInformation
---@field location LSPLocation
---@field message string

---@class LSPCodeDescription
---@field href LSPUri URI with more info about an error

return {
	ResponseCode = ResponseCode,
	DiagnosticSeverity = DiagnosticSeverity,
	DiagnosticTag = DiagnosticTag,
}
