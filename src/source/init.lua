local Lexer = require("source.lexer")
local LazyStream = require("lazyStream")

---@class Source
local Source = {}

---@param name Chunkname
---@param sourceText string
---@return Source
function Source.new(name, sourceText)
	local chunkDisplayName

	if #name > 0 and name:sub(1,1) == "=" then
		chunkDisplayName = name:sub(2)
	elseif #name > 0 and name:sub(1,1) == "=" then
		chunkDisplayName = name:sub(2)
	elseif #name > 0 then
		chunkDisplayName = ""
	else
		chunkDisplayName = "chunk"
	end

	local output = setmetatable({
		name=name,
		sourceText=sourceText,
		chunkDisplayName=chunkDisplayName,
	}, {
		__index=Source,
		__tostring=function()
			return chunkDisplayName
		end,
		__name = chunkDisplayName
	})

	local lexer = Lexer.new(output)
	output.sourceTokens = LazyStream.new(lexer:createTokenGenerator(), output, "token")

	return output
end

function Source:displayName()
	return self.chunkDisplayName
end

function Source:lookup(start, stop)
	return self.sourceText:sub(start, stop)
end

return Source
