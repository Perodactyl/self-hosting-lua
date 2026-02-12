local util = require("util")

local jsonrpc = {}

---@return JSONObject | nil
function jsonrpc.receive()
	local headerPart = ""
	local headerEnd

	while true do
		local char = io.stdin:read("L")
		if char == nil then
			return nil
		end
		headerPart = headerPart .. char
		-- log(util.prettyOutput.dump(block))

		headerEnd = headerPart:find("\r\n\r\n")
		if headerEnd ~= nil then
			break
		else
			-- log(util.prettyOutput.dump(headerPart))
		end
	end

	local headers = {}
	local i = 1
	while true do
		local lineEnd,nextLine = headerPart:find("\r\n", i)
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
	headerPart = ""
	return result
end

---@param message JSONObject
function jsonrpc.send(message)
	message.jsonrpc = "2.0"
	local text = util.json.stringify(message, false)
	local headers = {
		["Content-Length"] = #text,
		["Content-Type"] = "vscode-jsonrpc; charset=utf-8",
	}

	local resultMessage = ""
	for k,v in pairs(headers) do
		resultMessage = resultMessage .. k .. ": " .. tostring(v) .. "\r\n"
	end
	resultMessage = resultMessage .. "\r\n" .. text

	io.stdout:write(resultMessage)
	-- io.stdout:write("\r\n")
	io.stdout:flush()
end

return jsonrpc
