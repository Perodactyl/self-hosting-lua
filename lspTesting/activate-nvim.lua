---@diagnostic disable: undefined-global

vim.lsp.config["my_lua_ls"] = {
	cmd = { "sh", "-c", "tee lsp-stdin.log | lua src/lsp.lua | tee lsp-stdout.log" },
	cmd_cwd = "../",
	fileTypes = { "lua" },
	settings = {},
}

vim.lsp.enable("my_lua_ls")
