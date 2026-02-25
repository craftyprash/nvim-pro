-- Tmux Navigator: Seamless navigation between tmux panes and nvim splits using same keybinds
return {
	"christoomey/vim-tmux-navigator",
	init = function()
		vim.g.tmux_navigator_no_mappings = 1
	end,
	keys = { -- Keybindings (overrides default <C-h/j/k/l> from keymaps.lua)
		-- normal mode
		{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
		{ "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
		{ "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
		{ "<C-l>", "<cmd>TmuxNavigateRight<cr>" },

		-- terminal mode
		{ "<C-h>", [[<C-\><C-n><cmd>TmuxNavigateLeft<cr>]], mode = "t" },
		{ "<C-j>", [[<C-\><C-n><cmd>TmuxNavigateDown<cr>]], mode = "t" },
		{ "<C-k>", [[<C-\><C-n><cmd>TmuxNavigateUp<cr>]], mode = "t" },
		{ "<C-l>", [[<C-\><C-n><cmd>TmuxNavigateRight<cr>]], mode = "t" },
	},
}
