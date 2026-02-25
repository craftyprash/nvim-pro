-- Colorschemes collection
return {
	-- Tokyonight: Clean dark theme inspired by Tokyo's night skyline
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = true,
			styles = {
				comments = { italic = false },
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},

	-- OneDark: Atom's iconic One Dark theme (closest to Zed)
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "dark", -- dark, darker, cool, deep, warm, warmer
			transparent = true,
			code_style = {
				comments = "none",
			},
		},
	},

	-- Catppuccin: Modern, polished theme with multiple flavors
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			transparent_background = true,
			styles = {
				comments = {},
			},
		},
	},

	-- Nightfox: Highly customizable with multiple variants
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			options = {
				transparent = true,
				styles = {
					comments = "NONE",
				},
			},
		},
	},

	-- Kanagawa: Inspired by Japanese art, warm muted colors
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
			commentStyle = { italic = false },
		},
	},

	-- Rose Pine: Low-contrast, easy on eyes
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		opts = {
			variant = "main", -- main, moon, dawn
			disable_background = true,
			styles = {
				italic = false,
			},
		},
	},

	-- Set default colorscheme
	{
		"folke/tokyonight.nvim",
		config = function()
			vim.cmd.colorscheme("onedark") -- Change this to switch default: tokyonight, onedark, catppuccin, nightfox, kanagawa, rose-pine
		end,
	},
}
