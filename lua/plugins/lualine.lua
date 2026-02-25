-- Lualine: A fast and customizable statusline plugin for Neovim
return {
	"nvim-lualine/lualine.nvim", -- Plugin repository
	event = "VeryLazy", -- Load after startup for faster initial load time
	opts = function()
		-- Icon definitions using Nerd Font symbols
		-- If icons don't display, ensure your terminal uses a Nerd Font (e.g., JetBrainsMono Nerd Font)
		local icons = {
			diagnostics = {
				Error = " ", -- Nerd Font icon for errors (LSP/linter errors)
				Warn = " ", -- Nerd Font icon for warnings
				Hint = " ", -- Nerd Font icon for hints
				Info = " ", -- Nerd Font icon for info messages
			},
			git = {
				added = " ", -- Icon for added lines in git diff
				modified = " ", -- Icon for modified lines in git diff
				removed = " ", -- Icon for removed lines in git diff
			},
		}

		return {
			options = {
				theme = "auto", -- Automatically match colorscheme (uses tokyonight theme)
				globalstatus = true, -- Single statusline for all windows instead of one per window
				disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } }, -- Hide statusline on these filetypes
			},
			-- Statusline is divided into sections: a, b, c (left) | x, y, z (right)
			sections = {
				-- Section A (far left): Current mode (NORMAL, INSERT, VISUAL, etc.)
				lualine_a = { "mode" },

				-- Section B (left): Git branch name
				lualine_b = { "branch" },

				-- Section C (left-center): Diagnostics, file icon, and filename
				lualine_c = {
					{
						"diagnostics", -- Shows count of errors, warnings, hints, info from LSP/linters
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
					},
					{
						"filetype",
						icon_only = true, -- Show only the file icon (e.g.,  for Lua files)
						separator = "", -- No separator after icon
						padding = { left = 1, right = 0 },
					},
					{
						"filename",
						path = 1, -- Show relative path (0=just filename, 1=relative, 2=absolute, 3=absolute with tilde)
					},
				},

				-- Section X (right-center): LSP client names and git diff stats
				lualine_x = {
					{
						-- Custom function to display active LSP clients for current buffer
						function()
							local clients = vim.lsp.get_clients({ bufnr = 0 }) -- Get LSP clients for current buffer
							if #clients == 0 then
								return "" -- Return empty if no LSP attached
							end
							local names = {}
							for _, client in ipairs(clients) do
								table.insert(names, client.name) -- Collect client names (e.g., "lua_ls", "pyright")
							end
							return " " .. table.concat(names, ", ") -- Display with LSP icon
						end,
					},
					{
						"diff", -- Shows git diff stats (+3 ~2 -1 for added/modified/removed lines)
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
					},
				},

				-- Section Y (right): File progress percentage and cursor location
				lualine_y = {
					{ "progress", separator = " ", padding = { left = 1, right = 0 } }, -- Shows percentage through file (e.g., "50%")
					{ "location", padding = { left = 0, right = 1 } }, -- Shows line:column (e.g., "42:15")
				},

				-- Section Z (far right): Empty (can add time, file encoding, etc.)
				lualine_z = {},
			},
			extensions = { "lazy" }, -- Enable lualine integration with lazy.nvim plugin manager UI
		}
	end,
}
