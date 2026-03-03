# Changelog

All notable changes to this Neovim configuration will be documented in this file.

## [0.0.1] - 2025-01-09

### Initial Release

A minimal yet essential Neovim 0.12 configuration built for modern development workflows.

#### Core Features

**LSP & Language Support**
- Modern Neovim 0.12 native LSP (no lspconfig wrapper)
- Java (nvim-jdtls): Multi-module Maven/Gradle, Lombok, workspace isolation
- Go (gopls): gofumpt formatting, staticcheck linting
- Rust (rust_analyzer): Clippy linting, Cargo integration
- TypeScript/React (vtsls): ESLint, Prettier, Tailwind CSS
- Lua (lua_ls): Neovim API awareness
- Auto-install via Mason
- Format on save with Conform.nvim
- LSP-based folding with auto-fold Java imports

**Debugging (nvim-dap)**
- Java debugging with java-debug-adapter
- Go debugging with delve
- Rust debugging with codelldb
- nvim-dap-ui with visual panels (scopes, breakpoints, call stack)
- nvim-dap-virtual-text for inline variable display
- F-key bindings (F5/F9/F10/F11/F12) for quick debugging
- Auto-open/close UI on debug start/end

**File Management**
- Oil.nvim: Edit directories like buffers
- Snacks.nvim picker: Fuzzy finder for files, grep, buffers, git
- Smart project root detection (finds .git directory)
- Auto-change cwd when opening directories

**Completion & Editing**
- Blink.cmp: Fast completion engine with LSP, path, buffer, snippets
- Treesitter: Syntax highlighting for 21 languages
- Comment.nvim: Easy commenting with context awareness
- nvim-surround: Add/change/delete surroundings
- nvim-autopairs: Auto-close brackets
- todo-comments: Highlight TODO/FIXME/NOTE

**Git Integration**
- LazyGit integration via Snacks.nvim
- Gitsigns: Git hunks, stage/reset, blame
- Git-aware file picker

**UI & Appearance**
- 6 colorschemes with transparency (onedark, tokyonight, catppuccin, nightfox, kanagawa, rose-pine)
- Lualine statusline
- Snacks.nvim dashboard
- Snacks.nvim notifications
- render-markdown.nvim for beautiful markdown rendering

**Workflow**
- Tmux-style window management keybindings
- Toggle terminal with Ctrl+/
- Zoxide project navigation
- Smart resize mode
- Persistent undo
- Auto-create parent directories on save

#### Performance

- Startup time: ~50-80ms
- Lazy loading for most plugins
- Disabled unnecessary built-ins (netrw, gzip, tutor)
- Native Neovim 0.12 LSP (no lspconfig overhead)

#### Philosophy

- Minimal but Essential: Only plugins that directly enhance productivity
- Keyboard-First: Tmux-style keybindings, no mouse dependency
- Modern Neovim 0.12: Leverages native LSP features
- Transparent UI: All colorschemes use terminal background
- Performance: Optimized for fast startup and responsiveness

#### Documentation

- README.md: Complete setup guide
- LSP.md: Detailed LSP and debugging documentation
- KEYBINDINGS.md: Comprehensive keybinding reference
- stylua.toml: Code formatting configuration (2 spaces)
