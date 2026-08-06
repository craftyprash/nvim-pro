-- Treesitter: Advanced syntax highlighting using AST (Abstract Syntax Tree) parsing
--
-- NOTE: This config targets the `main` branch of nvim-treesitter (the 2024+
-- rewrite), which requires Neovim 0.11+. The API is very different from the old
-- `master` branch:
--   * setup() no longer takes highlight/indent/ensure_installed/textobjects
--   * parsers are installed via require("nvim-treesitter").install{...}
--   * highlighting/indent/folds are started per-buffer via a FileType autocmd
--   * textobjects are plain keymaps calling the textobjects modules directly
local langs = {
  "lua",
  "vim",
  "vimdoc",
  "javascript",
  "typescript",
  "tsx",
  "python",
  "go",
  "rust",
  "java",
  "markdown",
  "markdown_inline",
  "json",
  "yaml",
  "xml",
  "toml",
  "bash",
  "html",
  "css",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install any missing parsers (async; no-op if already installed)
      local installed = require("nvim-treesitter.config").get_installed()
      local to_install = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, langs)
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- Start highlighting + treesitter-based folds/indent per buffer.
      -- On the `main` branch this is our responsibility, not the plugin's.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("crafty_treesitter_start", { clear = true }),
        callback = function(ev)
          local ft = ev.match
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not vim.tbl_contains(langs, lang) then
            return
          end
          -- Only start if a parser is actually available for this buffer.
          if not pcall(vim.treesitter.get_parser, ev.buf, lang) then
            return
          end
          vim.treesitter.start(ev.buf, lang)
          -- treesitter-powered indentation (opt-in per buffer)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Textobjects: select (af/if/ac/ic) + repeatable movement (]f/[f/]c/[c ...)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      -- Selection text objects (operator + visual mode)
      local objs = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }
      for lhs, obj in pairs(objs) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(obj, "textobjects")
        end, { desc = "TS " .. obj })
      end

      -- Repeatable movements (also makes ; and , repeat the last TS move)
      local function m(lhs, fn, obj, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          fn(obj, "textobjects")
        end, { desc = desc })
      end
      m("]f", move.goto_next_start, "@function.outer", "Next function start")
      m("]c", move.goto_next_start, "@class.outer", "Next class start")
      m("]F", move.goto_next_end, "@function.outer", "Next function end")
      m("]C", move.goto_next_end, "@class.outer", "Next class end")
      m("[f", move.goto_previous_start, "@function.outer", "Prev function start")
      m("[c", move.goto_previous_start, "@class.outer", "Prev class start")
      m("[F", move.goto_previous_end, "@function.outer", "Prev function end")
      m("[C", move.goto_previous_end, "@class.outer", "Prev class end")

      -- Make ; / , repeat the last textobject move (and stay useful for f/t)
      local repeatable = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", repeatable.repeat_last_move, { desc = "Repeat last TS move" })
      vim.keymap.set(
        { "n", "x", "o" },
        ",",
        repeatable.repeat_last_move_opposite,
        { desc = "Repeat last TS move (opposite)" }
      )
    end,
  },

  -- Sticky context header (shows the enclosing function/class at the top)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = { max_lines = 3 },
  },
}
