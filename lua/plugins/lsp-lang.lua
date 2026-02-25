-- # Global Keymaps (Auto-created)
-- gra     → Code Action
-- grn     → Rename
-- grr     → References
-- gri     → Implementation
-- grt     → Type Definition
-- gO      → Document Symbols
-- <C-s>   → Signature Help (Insert mode)
-- an      → Around selection range
-- in      → Inside selection range

-- # Buffer Defaults (on LspAttach)
-- K       → Hover (unless overridden)
-- gq      → Format (uses formatexpr)
-- CTRL-]  → Go to definition (via tagfunc)

-- # Custom Additions
-- gd      → Definition
-- gD      → Declaration
-- [d      → Previous diagnostic
-- ]d      → Next diagnostic
-- <leader>f  → Unified format (conform)
-- <leader>ih → Toggle inlay hints

return {
	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		config = function()
			local jdtls = require("jdtls")
			local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
			local home = os.getenv("HOME")

			-- Autocmd ensures start_or_attach runs for EVERY java buffer
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "java",
				callback = function()
					local root_markers = {
						"gradlew",
						"mvnw",
						"pom.xml",
						"build.gradle",
						".git",
					}

					-- IMPORTANT: use current buffer path, not cwd
					local root_dir =
						require("lspconfig.util").root_pattern(unpack(root_markers))(vim.api.nvim_buf_get_name(0))

					if not root_dir then
						return
					end

					-- Unique workspace per project (collision-safe)
					local project_name = root_dir:gsub("[/\\]", "_")
					local workspace_dir = home .. "/.local/share/jdtls-workspace/" .. project_name

					-- Find equinox launcher dynamically
					local launcher = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

					local lombok_path = mason_path .. "/lombok.jar"

					local config = {
						cmd = {
							"java",
							"-javaagent:" .. lombok_path,

							"-Declipse.application=org.eclipse.jdt.ls.core.id1",
							"-Dosgi.bundles.defaultStartLevel=4",
							"-Declipse.product=org.eclipse.jdt.ls.core.product",

							"-Dlog.protocol=false",
							"-Dlog.level=ERROR",

							"-Xms1g",

							"--add-modules=ALL-SYSTEM",
							"--add-opens",
							"java.base/java.util=ALL-UNNAMED",
							"--add-opens",
							"java.base/java.lang=ALL-UNNAMED",

							"-jar",
							launcher,
							"-configuration",
							mason_path .. "/config_mac",
							"-data",
							workspace_dir,
						},

						root_dir = root_dir,

						settings = {
							java = {
								configuration = {
									runtimes = {
										{
											name = "JavaSE-21",
											path = vim.fn.trim(vim.fn.system("mise where java")),
										},
									},
								},
							},
						},
					}

					jdtls.start_or_attach(config)
				end,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		priority = 900,
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			-- LSP keybindings
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					vim.lsp.inlay_hint.enable(true)

					local map = vim.keymap.set
					local opts = { buffer = args.buf }

					-- Definition / Declaration
					map("n", "gd", vim.lsp.buf.definition, opts)
					map("n", "gD", vim.lsp.buf.declaration, opts)

					-- Diagnostics
					map("n", "[d", vim.diagnostic.goto_prev, opts)
					map("n", "]d", vim.diagnostic.goto_next, opts)

					-- Unified Format (conform)
					map("n", "<leader>f", function()
						require("conform").format({ lsp_fallback = true })
					end, opts)

					-- Inlay hints toggle
					map("n", "<leader>ih", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }),
							{ bufnr = args.buf }
						)
					end, opts)

					-- Fold Java imports after LSP attaches
					if vim.bo[args.buf].filetype == "java" then
						vim.schedule(function()
							if not vim.api.nvim_buf_is_valid(args.buf) then
								return
							end
							local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
							for i, line in ipairs(lines) do
								if line:match("^import ") and vim.fn.foldclosed(i) == -1 then
									pcall(vim.cmd, i .. "foldclose")
								end
							end
						end)
					end
				end,
			})

			-- LUA (for Neovim config)
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							checkThirdParty = false,
						},
					},
				},
			})

			-- GO
			vim.lsp.config("gopls", {
				settings = {
					gopls = {
						gofumpt = true,
						usePlaceholders = true,
						staticcheck = true,
						-- hints = {
						--   assignVariableTypes = true,
						--   compositeLiteralFields = true,
						--   constantValues = true,
						--   functionTypeParameters = true,
						--   parameterNames = true,
						--   rangeVariableTypes = true,
						-- },
					},
				},
			})

			-- RUST
			vim.lsp.config("rust_analyzer", {
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						-- checkOnSave = true,
						-- check = { command = "clippy" },
						checkOnSave = {
							command = "clippy",
						},
						-- inlayHints = {
						--   bindingModeHints = { enable = true },
						--   closureReturnTypeHints = { enable = "with_block" },
						--   lifetimeElisionHints = { enable = "always" },
						-- },
					},
				},
			})

			-- TYPESCRIPT / REACT (vtsls is preferred)
			vim.lsp.config("vtsls", {
				settings = {
					typescript = {
						inlayHints = {
							parameterNames = { enabled = "all" },
							variableTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
						},
					},
				},
				on_attach = function(client)
					-- disable formatting (we use prettier)
					client.server_capabilities.documentFormattingProvider = false
				end,
			})

			-- ESLINT
			vim.lsp.config("eslint", {
				settings = {
					workingDirectory = { mode = "auto" },
				},
			})

			-- TAILWIND
			vim.lsp.config("tailwindcss", {})

			-- Enable all servers
			vim.lsp.enable({
				"gopls",
				"rust_analyzer",
				"lua_ls",
				"vtsls",
				"eslint",
				"tailwindcss",
			})
		end,
	},

	-- Mason auto-install
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		config = function()
			require("mason").setup()
			local mr = require("mason-registry")
			local ensure_installed = {
				"jdtls",
				"gopls",
				"vtsls",
				"eslint-lsp",
				"tailwindcss-language-server",
				"lua-language-server",
				"stylua",
				"prettier",
				"google-java-format",
			}
			local function install_tools()
				for _, tool in ipairs(ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(install_tools)
			else
				install_tools()
			end
		end,
	},
}
