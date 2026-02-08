---@diagnostic disable: undefined-global

vim.g.disable_all_lsps = true

vim.o.runtimepath = "./runtimePath," .. vim.o.runtimepath
-- vim.o.runtimepath = vim.o.runtimepath .. ",./runtimePath"

vim.lsp.config["my_lua_ls"] = {
	cmd = { "sh", "-c", "tee lsp-stdin.log | lua src/lsp/init.lua | tee lsp-stdout.log" },
	-- cmd = { "sh", "-c", "tee lsp-stdin.log | lua-language-server | tee lsp-stdout.log" },
	cmd_cwd = "../",
	fileTypes = { "lua" },
	settings = {},
}

vim.lsp.enable("my_lua_ls")

vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		-- vim.cmd("au! Syntax *")
		vim.hl.priorities.syntax = 0
		vim.hl.priorities.treesitter = 0
		vim.defer_fn(function()
			vim.cmd("e test-file.lua")
			vim.treesitter.stop()
		end, 50)
	end
})

-- vim.api.nvim_create_autocmd("Syntax", {
-- 	callback = function(args)
-- 		for _,highlight in ipairs(vim.fn.getcompletion('', 'highlight')) do
-- 			if highlight:match("^lua.*") then
-- 				vim.cmd("highlight! clear " .. highlight)
-- 			end
-- 		end
-- 	end,
-- })
