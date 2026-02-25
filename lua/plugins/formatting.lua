-- Formatting with conform.nvim
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- Load before saving
	-- cmd = { "ConformInfo" },
	-- keys = {
	--   {
	--     "<leader>cf",
	--     function()
	--       require("conform").format({ async = true, lsp_fallback = true })
	--     end,
	--     mode = { "n", "v" },
	--     desc = "Format buffer",
	--   },
	-- },
	opts = {
		-- Formatters by filetype
		formatters_by_ft = {
			lua = { "stylua" }, -- Use stylua for Lua

			-- Go and Rust use LSP formatting

			-- Add more languages later:
			java = { "google-java-format" },
			-- ruby = { "rubocop" },
			-- java = {}, -- fallback to LSP
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "prettier" },
			yaml = { "prettier" },
		},

		-- Format on save
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true, -- Use LSP formatter if conform formatter not available
		},

		-- Formatter-specific settings
		-- formatters = {
		--   ["google-java-format"] = {
		--     -- Installed via Mason
		--     -- Uses Google Java Style Guide
		--     -- Automatically formats on save
		--   },
		-- },
	},
	init = function()
		-- gqap → format around paragraph
		-- gq} → format until next paragraph
		-- gqG → format to end of file
		-- Visual select + gq → format selection

		-- make gq use conform (built-in Vim operator for formatting text)
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		-- add :Format command (conform → uses prettier/stylua or falls back to LSP)
		vim.api.nvim_create_user_command("Format", function()
			require("conform").format({ lsp_fallback = true })
		end, {})
	end,
}
