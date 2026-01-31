local util = require("util")

local autotest = {}
local mappings = {}

function autotest.save()
	local file = io.open("autotest-maps.lua", "w")
	if file then
		file:write("--[[ File is auto generated " .. os.date("%D %T %Z UTC%z") .. " ]]\nreturn " .. util.dump(mappings, false, true))
		file:close()
	end
end

function autotest.load()
	local success, result = pcall(require, "autotest-maps")
	if not success then
		print(result)
	elseif type(result) == "boolean" then
		print("Autotest: map file is malformed or empty")
	else
		mappings = result
	end
end

function autotest.get(key)
	return mappings[key]
end

function autotest.set(key, value)
	mappings[key] = value
end

function autotest.reset()
	mappings = {}
end

return autotest
