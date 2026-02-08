nvim --clean --cmd "luafile activate-nvim.lua" -c "e test-file.lua" -c "lua vim.treesitter.stop()" -c "syntax off"
