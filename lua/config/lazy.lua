-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Import plugins from lua/plugins/*.lua
		{ import = "plugins" },
	},
	install = {
		colorscheme = {
			-- "habamax"
			"nightfox",
		},
	},
	checker = { enabled = false },
	performance = {
		rtp = {
			-- Prevents lazy.nvim from loading these built-in plugins at all
			-- Alternatively we could use in options
			--  g:loaded_python3_provider - Would disable after loading (less efficient)
			--  g:loaded_ruby_provider - Would disable after loading (less efficient)
			--  g:loaded_perl_provider - Would disable after loading (less efficient)
			--  g:loaded_node_provider - Would disable after loading (less efficient)
			--  g:loaded_vim.g.loaded_netrw - Would disable after loading (less efficient)
			disabled_plugins = {
				"gzip", -- Disable gzip file handling
				"netrw", -- Disable netrw (using neo-tree)
				"netrwPlugin", -- Disable netrw plugin
				"tarPlugin", -- Disable tar file handling
				"tohtml", -- Disable :TOhtml command
				"tutor", -- Disable :Tutor command
				"zipPlugin", -- Disable zip file handling
			},
		},
	},
})
