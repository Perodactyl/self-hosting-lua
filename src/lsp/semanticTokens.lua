local util = require("util")
local lspTypes = require("types.lsp")
local Source = require("source")
local Parser = require("parser")

local semanticTokens = {}

semanticTokens.typeLegend = util.tableUtils.newEnum({
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
}, "{k=v}")

semanticTokens.modifierLegend = util.tableUtils.newEnum({
	"declaration",
	"definition"
}, "{k=v}")

return semanticTokens
