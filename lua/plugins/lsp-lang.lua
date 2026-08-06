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

      -- Pick the correct Eclipse config dir for this OS + CPU arch.
      -- Mason ships config_{mac,linux,win} and _arm variants; the previous
      -- hardcoded "config_mac" broke on Arch Linux and was wrong on Apple Silicon.
      local function jdtls_config_dir()
        local arch = vim.uv.os_uname().machine
        local is_arm = arch == "arm64" or arch == "aarch64"
        if vim.fn.has("mac") == 1 then
          return is_arm and "config_mac_arm" or "config_mac"
        elseif vim.fn.has("win32") == 1 then
          return "config_win"
        else
          return is_arm and "config_linux_arm" or "config_linux"
        end
      end

      -- Resolve a specific mise-managed JDK home (nil if not installed).
      local function mise_java(version)
        local p = vim.fn.trim(vim.fn.system("mise where java@" .. version))
        if vim.v.shell_error == 0 and p ~= "" and vim.fn.isdirectory(p) == 1 then
          return p
        end
        return nil
      end

      -- Register every JDK we have so projects can target either release.
      -- jdtls itself runs on whatever `java` is on PATH (the active mise JDK).
      local runtimes = {}
      for _, r in ipairs({
        { name = "JavaSE-21", version = "temurin-21" },
        { name = "JavaSE-25", version = "temurin-25" },
      }) do
        local path = mise_java(r.version)
        if path then
          table.insert(runtimes, { name = r.name, path = path })
        end
      end

      -- Autocmd ensures start_or_attach runs for EVERY java buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local root_markers = {
            ".git",
            "mvnw",
            "gradlew",
          }

          -- IMPORTANT: use current buffer path, not cwd
          local root_dir = require("lspconfig.util").root_pattern(unpack(root_markers))(vim.api.nvim_buf_get_name(0))

          if not root_dir then
            return
          end

          -- Unique workspace per project (collision-safe)
          local project_name = root_dir:gsub("[/\\]", "_")
          local workspace_dir = home .. "/.local/share/jdtls-workspace/" .. project_name

          -- Find equinox launcher dynamically
          local launcher = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

          local lombok_path = mason_path .. "/lombok.jar"

          -- Debug adapter bundles
          local bundles = {}
          local java_debug_path = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter"
          local java_debug_jar =
            vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
          if java_debug_jar ~= "" then
            table.insert(bundles, java_debug_jar)
          end

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
              mason_path .. "/" .. jdtls_config_dir(),
              "-data",
              workspace_dir,
            },

            root_dir = root_dir,

            init_options = {
              bundles = bundles,
            },

            settings = {
              java = {
                import = {
                  maven = { enabled = true },
                  gradle = { enabled = true },
                },
                maven = {
                  downloadSources = true,
                },
                configuration = {
                  updateBuildConfiguration = "automatic",
                  runtimes = runtimes,
                },
              },
            },
          }

          jdtls.start_or_attach(config)

          -- Setup Java debug configurations
          vim.schedule(function()
            local ok, dap = pcall(require, "dap")
            if ok then
              dap.configurations.java = {
                {
                  type = "java",
                  request = "launch",
                  name = "Debug (Attach) - Remote",
                  hostName = "127.0.0.1",
                  port = 5005,
                },
              }
              require("jdtls.dap").setup_dap_main_class_configs()
            end
          end)
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
      -- Wrap vim.lsp.foldexpr to auto-fold Java imports
      do
        local orig_foldexpr = vim.lsp.foldexpr
        vim.lsp.foldexpr = function(lnum)
          local level = orig_foldexpr(lnum)
          local bufnr = vim.api.nvim_get_current_buf()

          if vim.bo[bufnr].filetype == "java" and not vim.b[bufnr].imports_folded and level and level:match("^>") then
            vim.b[bufnr].imports_folded = true
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(bufnr) then
                return
              end
              local view = vim.fn.winsaveview()
              vim.cmd("silent! normal! zx")
              vim.cmd("normal! gg")
              if vim.fn.search("^import ", "W") > 0 then
                pcall(vim.cmd, "normal! zc")
              end
              vim.fn.winrestview(view)
            end)
          end
          return level
        end
      end

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.lsp.inlay_hint.enable(true)

          local map = vim.keymap.set
          local opts = { buffer = args.buf }

          -- Definition / Declaration
          map("n", "gd", vim.lsp.buf.definition, opts)
          map("n", "gD", vim.lsp.buf.declaration, opts)

          -- Diagnostics (vim.diagnostic.jump replaces the deprecated goto_prev/goto_next)
          map("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
          end, opts)
          map("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
          end, opts)

          -- Unified Format (conform)
          map("n", "<leader>f", function()
            require("conform").format({ lsp_fallback = true })
          end, opts)

          -- Inlay hints toggle
          map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
          end, opts)
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
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", "rust-project.json" },
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
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
        "rust-analyzer",
        -- Debug adapters
        "java-debug-adapter",
        "delve",
        "codelldb",
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
