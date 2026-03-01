# LSP & Debug Configuration

Complete guide to Language Server Protocol (LSP) and debugging setup for Java, Go, Rust, TypeScript, and Lua.

## LSP Configuration

### Modern Neovim 0.12 Approach

Uses native `vim.lsp.config()` and `vim.lsp.enable()` instead of lspconfig wrappers:
- Direct LSP client configuration without abstractions
- Unified keybindings via `LspAttach` autocmd
- Native Neovim 0.12 implementation (no lspconfig overhead)

### Supported Languages

| Language | LSP Server | Formatter | Linter |
|----------|-----------|-----------|--------|
| Java | nvim-jdtls | google-java-format | Built-in |
| Go | gopls | gofumpt | staticcheck |
| Rust | rust_analyzer | rustfmt | clippy |
| TypeScript/React | vtsls | prettier | eslint |
| Lua | lua_ls | stylua | Built-in |
| Tailwind CSS | tailwindcss | - | - |

### Key Features

- **Inlay hints**: Enabled by default (toggle with `<leader>ih`)
- **LSP-based folding**: Uses `vim.lsp.foldexpr()`
- **Format on save**: Via Conform.nvim with LSP fallback
- **Auto-install**: Mason automatically installs LSP servers and formatters
- **Java import folding**: Imports auto-fold on file open

### LSP Keybindings

**Auto-created (Neovim 0.12)**:
- `gra` - Code actions
- `grn` - Rename
- `grr` - References
- `gri` - Implementation
- `grt` - Type definition
- `gO` - Document symbols
- `<C-s>` - Signature help (insert mode)

**Custom additions**:
- `gd` - Go to definition
- `gD` - Go to declaration
- `K` - Hover documentation
- `[d` / `]d` - Previous/next diagnostic
- `<leader>f` - Format file
- `<leader>ih` - Toggle inlay hints

## Language-Specific Setup

### Java (nvim-jdtls)

**Features**:
- Multi-module Maven/Gradle project support
- Workspace isolation (unique workspace per project)
- Lombok support via javaagent
- Import auto-folding on file open
- Debug adapter integration

**Root detection**: `.git` → `mvnw` → `gradlew`

**Configuration**:
```lua
-- Auto-configured in lsp-lang.lua
-- Workspace: ~/.local/share/jdtls-workspace/<project-name>
-- Runtime: JavaSE-21 (via mise)
```

**Troubleshooting**:
- Multi-module errors: Clear workspace cache `rm -rf ~/.local/share/jdtls-workspace/`
- Check `:LspInfo` for client status
- Verify Mason installed `jdtls`: `:Mason`

### Go (gopls)

**Features**:
- gofumpt formatting (stricter than gofmt)
- staticcheck linting
- Format on save via LSP

**Configuration**:
```lua
-- Auto-configured in lsp-lang.lua
-- Requires: go.mod in project root
```

### Rust (rust_analyzer)

**Features**:
- Clippy linting on save
- Cargo integration (all features enabled)
- Format on save via LSP

**Configuration**:
```lua
-- Auto-configured in lsp-lang.lua
-- Requires: Cargo.toml in project root
```

### TypeScript/React (vtsls)

**Features**:
- Modern TS language server (replaces tsserver)
- ESLint linting
- Prettier formatting (disables LSP formatting)
- Inlay hints for parameters, types, return types
- Tailwind CSS utility class completion

**Configuration**:
```lua
-- Auto-configured in lsp-lang.lua
-- Prettier takes precedence over LSP formatting
```

### Lua (lua_ls)

**Features**:
- Neovim API awareness
- Diagnostics for `vim` global
- Format on save via stylua

**Configuration**:
```lua
-- Auto-configured in lsp-lang.lua
-- stylua.toml: 2 spaces, double quotes
```

## Debugging (nvim-dap)

### Supported Languages

- **Java**: java-debug-adapter (integrated with jdtls)
- **Go**: delve
- **Rust**: codelldb

### Debug Keybindings

**F-keys (frequent actions)**:
- `F5` - Continue/Start
- `F9` - Toggle breakpoint
- `F10` - Step over
- `F11` - Step into
- `F12` - Step out

**Leader keys (advanced)**:
- `<leader>dB` - Conditional breakpoint
- `<leader>dC` - Run to cursor
- `<leader>dt` - Terminate
- `<leader>du` - Toggle UI (dap-ui)
- `<leader>de` - Eval/hover variable
- `<leader>dr` - REPL toggle

### Debug UI

**nvim-dap-ui** provides visual panels:
- **Left panel**: Scopes (variables), Breakpoints, Call stack
- **Bottom panel**: REPL, Console output
- **Auto-behavior**: Opens on debug start, closes on session end
- **Manual toggle**: `<leader>du`

**nvim-dap-virtual-text** shows variable values inline as you step through code.

### Debugging Workflow

1. **Set breakpoints**: `F9` on any line
2. **Start debugging**: `F5`
3. **Step through code**: `F10` (over), `F11` (into), `F12` (out)
4. **Inspect variables**: `<leader>de` (hover) or `<leader>dr` (REPL)
5. **Continue**: `F5` to next breakpoint
6. **Terminate**: `<leader>dt`

### Language-Specific Debugging

#### Java

**Auto-detection**: jdtls finds main classes automatically

**Configurations**:
- Launch main class (auto-detected)
- Remote attach (port 5005)

**Usage**:
1. Set breakpoints with `F9`
2. Press `F5` to start
3. Select configuration from list
4. Debug with F-keys

#### Go

**Configurations**:
- Debug current file
- Debug with arguments
- Debug entire package

**Usage**:
1. Set breakpoints with `F9`
2. Press `F5` to start
3. Select configuration
4. Debug with F-keys

**Requirements**: `go.mod` in project root

#### Rust

**Configuration**:
- Debug executable (prompts for path)

**Usage**:
1. Build first: `cargo build`
2. Set breakpoints with `F9`
3. Press `F5` to start
4. Enter path: `target/debug/<binary-name>`
5. Debug with F-keys

**Requirements**: `Cargo.toml` in project root

### Breakpoint Management

**Visual indicators**:
- `●` (red) - Breakpoint set
- `→` (yellow) - Execution stopped here

**Conditional breakpoints**: `<leader>dB` prompts for condition

**Run to cursor**: `<leader>dC` runs until cursor position

### Variable Inspection

**Hover method** (quick):
- Move cursor over variable
- Press `<leader>de`
- Value shown in floating window

**REPL method** (interactive):
- Press `<leader>dr` to open REPL
- Type expressions to evaluate
- Press `<leader>dr` again to close

**Virtual text** (automatic):
- Variable values shown inline while debugging
- Updates as you step through code

## Mason Auto-Install

All LSP servers, formatters, and debug adapters are auto-installed via Mason:

**LSP Servers**:
- jdtls, gopls, rust_analyzer, vtsls, eslint-lsp, tailwindcss-language-server, lua-language-server

**Formatters**:
- stylua, prettier, google-java-format

**Debug Adapters**:
- java-debug-adapter, delve, codelldb

**Manual check**: `:Mason`

## Troubleshooting

### LSP Issues

**LSP not attaching**:
```vim
:LspInfo                    " Check client status
:Mason                      " Verify tools installed
:checkhealth lsp            " Run health check
```

**Root detection**:
```lua
:lua print(vim.lsp.get_clients()[1].config.root_dir)
```

**View logs**:
```vim
:LspLog                     " LSP logs
:messages                   " All messages
```

### Debug Issues

**Java debugging not working**:
- Check `:Mason` for `java-debug-adapter`
- Verify jdtls attached: `:LspInfo`
- Check `:messages` for errors

**Go debugging not working**:
- Ensure `delve` installed: `which dlv` or `:Mason`
- Verify `go.mod` exists
- Try `go build` first

**Rust debugging not working**:
- Ensure `codelldb` installed: `:Mason`
- Run `cargo build` first
- Verify binary path: `target/debug/<name>`
- Check `Cargo.toml` exists

**General debug issues**:
```vim
:checkhealth dap            " Check DAP health
:messages                   " View errors
:Mason                      " Verify adapters
```

### Common Issues

**First file has no syntax highlighting**:
- Fixed by treesitter `lazy=false` with `priority=1000`

**Java imports not folding**:
- Requires LSP to compute folds first
- Uses `vim.lsp.foldexpr` wrapper
- Only runs once per buffer

**Format on save not working**:
```vim
:ConformInfo                " Check available formatters
```

## Adding New Languages

### 1. Add LSP Configuration

Edit `lua/plugins/lsp-lang.lua`:
```lua
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = { typeCheckingMode = "basic" }
    }
  }
})

vim.lsp.enable({ "pyright", ... })
```

### 2. Add Formatter

Edit `lua/plugins/formatting.lua`:
```lua
formatters_by_ft = {
  python = { "black" },
}
```

### 3. Install via Mason

Edit `lua/plugins/lsp-lang.lua`:
```lua
ensure_installed = {
  "pyright",
  "black",
  ...
}
```

### 4. Add Debug Adapter (Optional)

Edit `lua/plugins/debug.lua`:
```lua
dap.adapters.debugpy = {
  type = "executable",
  command = "python",
  args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
  {
    type = "debugpy",
    request = "launch",
    name = "Launch file",
    program = "${file}",
  },
}
```

Add to Mason:
```lua
ensure_installed = { "debugpy", ... }
```

## Performance

- **LSP startup**: Native Neovim 0.12 (no lspconfig overhead)
- **Debug startup**: Lazy-loaded on first F-key press
- **Memory**: Minimal (adapters start on-demand)
- **Format on save**: 500ms timeout with LSP fallback

## Credits

- **nvim-jdtls**: Java LSP with debug integration by @mfussenegger
- **nvim-dap**: Debug Adapter Protocol by @mfussenegger
- **nvim-dap-ui**: Debug UI by @rcarriga
- **nvim-dap-virtual-text**: Inline variable display by @theHamsta
- **Conform.nvim**: Formatter by @stevearc
- **Mason.nvim**: Tool installer by @williamboman
