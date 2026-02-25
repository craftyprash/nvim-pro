-- Completion with blink.cmp
return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	version = "*", -- Use latest release
	dependencies = {
		"rafamadriz/friendly-snippets", -- Optional: pre-built snippets for common languages
	},
	opts = {
		-- Appearance
		appearance = {
			-- use_nvim_cmp_as_default = true, -- Use nvim-cmp style UI
			nerd_font_variant = "mono",
		},

		-- Completion sources (LSP is primary)
		sources = {
			default = { "lsp", "path", "buffer", "snippets" },
			-- lsp: LSP completion (jdtls for Java)
			-- path: File path completion
			-- buffer: Words from current buffer
			-- snippets: Snippets for common languages
		},

		-- Completion behavior
		completion = {
			list = {
				selection = {
					preselect = true,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			accept = {
				auto_brackets = {
					enabled = true, -- Auto-add brackets for functions/methods
				},
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
					border = "rounded",
					-- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					border = "rounded",
				},
			},
		},

		-- Keybindings
		keymap = {
			preset = "enter",
			["<C-y>"] = { "select_and_accept" },
			-- preset = "default", -- Use default keybindings
			-- <C-Space>: Show completion menu
			-- <C-e>: Close completion menu
			-- <CR>: Accept completion
			-- <Tab>: Select next item
			-- <S-Tab>: Select previous item
			-- <C-n>/<C-p>: Navigate items
			-- <C-b>/<C-f>: Scroll documentation
		},

		-- Signature help (shows function parameters while typing)
		signature = {
			enabled = true,
		},
	},
}
