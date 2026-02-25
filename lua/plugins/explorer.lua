-- File Explorers
return {
	-- Neo-tree: File explorer sidebar (DISABLED - using oil.nvim)
	{
		"nvim-neo-tree/neo-tree.nvim",
		enabled = false,
		branch = "v3.x",
		lazy = false,
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
			{ "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus file explorer" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			default_component_configs = {
				indent = {
					padding = 0,
					with_expanders = true,
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "",
				},
				git_status = {
					symbols = {
						added = "",
						modified = "",
						deleted = "",
						renamed = "➜",
						untracked = "★",
						ignored = "◌",
						unstaged = "✗",
						staged = "✓",
						conflict = "",
					},
				},
			},
			window = {
				position = "left",
				width = 30,
				mappings = {
					["<space>"] = "none",
					["<cr>"] = "open",
					["l"] = "open",
					["h"] = "close_node",
					["v"] = "open_vsplit",
					["s"] = "open_split",
					["t"] = "open_tabnew",
					["C"] = "close_all_nodes",
					["z"] = "close_all_subnodes",
					["R"] = "refresh",
					["a"] = "add",
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["q"] = "close_window",
				},
			},
			filesystem = {
				follow_current_file = { enabled = false },
				hijack_netrw_behavior = "open_default",
				use_libuv_file_watcher = true,
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = { ".git", "node_modules" },
				},
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					local arg = vim.fn.argv(0)
					if arg and vim.fn.isdirectory(arg) == 1 then
						vim.cmd("Neotree left reveal")
					end
				end,
			})
		end,
	},

	-- Oil.nvim: Edit filesystem like a buffer
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
			{ "<leader>-", "<cmd>Oil --float<cr>", desc = "Open parent directory (float)" },
		},
		opts = {
			default_file_explorer = true,
			columns = { "icon" },
			keymaps = {
				["q"] = "actions.close",
				["<C-c>"] = "actions.close",
				["<C-h>"] = false,
				["<C-l>"] = false,
				["<C-r>"] = "actions.refresh",
			},
			view_options = {
				show_hidden = false,
			},
			float = {
				padding = 2,
				max_width = 90,
				max_height = 30,
				border = "rounded",
			},
		},
	},
}
