# Config & Plugins

## Directory Layout

```
~/.config/nvim-pro/
├── init.lua                    # Entry: sets leader keys, loads lua/config/
├── lua/
│   ├── config/
│   │   ├── options.lua         # vim.opt settings (tabs, search, folds, etc.)
│   │   ├── keymaps.lua         # global keybindings
│   │   ├── autocmds.lua        # autocommands (last position, yank highlight, etc.)
│   │   └── lazy.lua            # plugin manager bootstrap
│   └── plugins/                # one file per plugin or logical group
│       ├── snacks.lua          # picker, terminal, git, dashboard, notifier
│       ├── lsp-lang.lua        # LSP servers + Mason auto-install
│       ├── completion.lua      # blink.cmp
│       ├── coding.lua          # gitsigns, surround, comments, todo-comments
│       ├── explorer.lua        # oil.nvim
│       ├── debug.lua           # nvim-dap + UI
│       ├── treesitter.lua      # syntax + textobjects
│       ├── which-key.lua       # keybinding discovery
│       ├── persistence.lua     # session management
│       ├── diffview.lua        # git diffs and file history
│       ├── formatting.lua      # conform.nvim (format on save)
│       ├── colorscheme.lua     # 6 themes
│       └── lualine.lua         # statusline
└── tutorials/                  # this series
```

**Leader key**: `Space`  
**Local leader**: `\`

---

## How Lazy.nvim Works

Every `.lua` file in `lua/plugins/` is auto-imported. Each returns a plugin spec table:

```lua
return {
  "author/plugin-name",           -- GitHub slug
  event = "VeryLazy",             -- defer until after startup
  cmd   = { "SomeCommand" },      -- load when this command is run
  ft    = "java",                 -- load only for this filetype
  keys  = {                       -- load when key is pressed
    { "<leader>x", "<cmd>Cmd<cr>", desc = "Description" },
  },
  opts   = { option = true },     -- passed to require("plugin").setup()
  config = function(_, opts)      -- custom setup (when opts alone isn't enough)
    require("plugin").setup(opts)
  end,
  dependencies = { "other/dep" }, -- load these first
  priority = 1000,                -- higher = loads earlier (use for colorschemes)
  lazy = false,                   -- force eager load
}
```

**Lazy loading** — plugins with `event`/`cmd`/`ft`/`keys` load on demand. This keeps startup under ~80ms. Avoid setting `lazy = false` unless the plugin must run at startup.

---

## :Lazy UI

Open with `<leader>l`.

| Key | Action |
|-----|--------|
| `I` | Install missing plugins |
| `U` | Update all plugins |
| `S` | Sync (install + update + clean) |
| `C` | Check for updates without installing |
| `X` | Clean unused plugins |
| `P` | Profile — startup time per plugin |
| `L` | Plugin log |
| `<CR>` | Open plugin details / source |
| `q` | Close |

After editing a plugin spec, run `:Lazy sync` or restart to apply.

---

## which-key — Live Keymap Discovery

Press `<leader>` and pause ~300ms — a popup shows all bindings grouped by prefix. Press a prefix key to drill down.

Also works with `[`, `]`, `g`, `z` — press and wait.

**Groups configured** (`lua/plugins/which-key.lua`):

| Prefix | Group |
|--------|-------|
| `<leader>b` | buffer |
| `<leader>c` | code |
| `<leader>d` | debug |
| `<leader>f` | find / file |
| `<leader>g` | git |
| `<leader>gh` | hunks |
| `<leader>q` | quit / session |
| `<leader>s` | search |
| `<leader>w` | window |
| `<leader>x` | quickfix |

---

## Mason — Tool Management

Open with `<leader>cm`.

Manages LSP servers, formatters, and debug adapters. All tools are **auto-installed on startup** — you shouldn't need to open Mason unless something is wrong.

| Key | Action |
|-----|--------|
| `i` | Install package |
| `X` | Uninstall package |
| `u` | Update package |
| `<CR>` | Show package details |
| `g?` | Help |

**Auto-installed tools**:

| Category | Tools |
|----------|-------|
| LSP | jdtls, gopls, rust_analyzer, vtsls, eslint-lsp, tailwindcss, lua-language-server |
| Formatters | stylua, prettier, google-java-format |
| Debug adapters | java-debug-adapter, delve, codelldb |

If a tool is missing, open Mason and press `i` to install it manually.

---

## Adding a Plugin

Create a new file in `lua/plugins/` or add to an existing one:

```lua
-- lua/plugins/example.lua
return {
  "author/plugin",
  event = "VeryLazy",
  opts = {
    some_option = true,
  },
  keys = {
    { "<leader>e", "<cmd>SomeCmd<cr>", desc = "Do thing" },
  },
}
```

Then run `:Lazy sync`. The plugin installs and the key works immediately.

---

## Editing the Config

| Key / Command | Action |
|---------------|--------|
| `<leader>fc` | Browse config files with Snacks picker |
| `<leader>l` | Open Lazy UI |
| `<leader>cm` | Open Mason |

Config changes in `lua/plugins/` take effect after `:Lazy sync` or restart.  
Changes in `lua/config/*.lua` can be applied with `:source %` on that file, or restart.

---

## Key Options (lua/config/options.lua)

| Setting | Value | Effect |
|---------|-------|--------|
| Indentation | 2 spaces, expandtab | Spaces not tabs, 2-wide |
| Line numbers | relative + absolute | `relativenumber` + `number` |
| Search | smartcase | Case-insensitive unless you type uppercase |
| Clipboard | system sync | `"+` register = system clipboard |
| Folds | LSP-based | `foldexpr = vim.lsp.foldexpr()` |
| Splits | right + below | `splitright`, `splitbelow` |
| Undo | persistent 10k levels | Survives restarts |
| Grep | ripgrep | `grepprg = "rg --vimgrep"` |
| Diagnostics | virtual text with `●` prefix | Inline error display |

---

## Autocmds Worth Knowing

These run automatically — no keybindings needed.

| Autocmd | Behaviour |
|---------|-----------|
| `highlight_yank` | Flash highlight after yank |
| `last_loc` | Opens file at last cursor position |
| `checktime` | Reloads file if changed on disk when you focus nvim |
| `resize_splits` | Re-balances splits when terminal is resized |
| `close_with_q` | `q` closes help, lspinfo, quickfix, notify windows |
| `wrap_spell` | Enables wrap + spellcheck for markdown and gitcommit |
| `auto_create_dir` | Creates parent directories when saving a new file |
| `smart_cwd` | Sets CWD to project root (`.git` / `mvnw`) on startup |
