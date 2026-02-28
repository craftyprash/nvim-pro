# Debug Support - Java, Go, Rust

## Overview

Minimal nvim-dap configuration for debugging Java, Go, and Rust applications. No UI dependencies - keyboard-driven debugging using native Neovim commands.

## What Was Added

### New Files
- `lua/plugins/debug.lua` - nvim-dap configuration with adapters for all three languages

### Modified Files
- `lua/plugins/lsp-lang.lua`:
  - Added Java debug adapter bundles to jdtls
  - Added debug adapters to Mason auto-install
  - Added Java debug configuration setup

### Auto-Installed Tools (via Mason)
- `java-debug-adapter` - Java debugging
- `delve` - Go debugging
- `codelldb` - Rust debugging

## Keybindings

All debug commands use `<leader>d` prefix:

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>db` | Toggle Breakpoint | Set/remove breakpoint at current line |
| `<leader>dc` | Continue | Start debugging or continue to next breakpoint |
| `<leader>di` | Step Into | Step into function calls |
| `<leader>do` | Step Over | Step over function calls |
| `<leader>dO` | Step Out | Step out of current function |
| `<leader>dt` | Terminate | Stop debugging session |
| `<leader>dr` | REPL | Toggle debug REPL for evaluating expressions |
| `<leader>dh` | Hover | Show value of variable under cursor |

## Usage by Language

### Java

1. **Set breakpoints**: Navigate to line, press `<leader>db`
2. **Start debugging**: Press `<leader>dc`
3. **Select configuration**: Choose from auto-detected main classes or remote attach
4. **Debug**: Use step commands to navigate

**Auto-detection**: jdtls automatically finds main classes in your project

**Remote debugging**: Attach to running Java app on port 5005

### Go

1. **Set breakpoints**: Navigate to line, press `<leader>db`
2. **Start debugging**: Press `<leader>dc`
3. **Select configuration**:
   - "Debug" - Debug current file
   - "Debug (Arguments)" - Debug with command-line args
   - "Debug Package" - Debug entire package
4. **Debug**: Use step commands

**Requirements**: Must have `dlv` (delve) installed (auto-installed via Mason)

### Rust

1. **Build first**: Run `cargo build` to create debug binary
2. **Set breakpoints**: Navigate to line, press `<leader>db`
3. **Start debugging**: Press `<leader>dc`
4. **Enter path**: Provide path to debug binary (usually `target/debug/<binary-name>`)
5. **Debug**: Use step commands

**Requirements**: Must have `codelldb` installed (auto-installed via Mason)

## Debugging Workflow

### Basic Flow
```
1. Open file
2. Set breakpoints (<leader>db)
3. Start debugging (<leader>dc)
4. Step through code (<leader>di/do/dO)
5. Inspect variables (<leader>dh or use REPL with <leader>dr)
6. Continue to next breakpoint (<leader>dc)
7. Terminate when done (<leader>dt)
```

### Inspecting Variables

**Hover method** (quick):
- Move cursor over variable
- Press `<leader>dh`
- Value shown in floating window

**REPL method** (interactive):
- Press `<leader>dr` to open REPL
- Type expressions to evaluate
- Press `<leader>dr` again to close

### Breakpoint Management

**Set/remove**: `<leader>db` on any line
**Visual indicator**: 
- `●` (red) = breakpoint set
- `→` (yellow) = execution stopped here

## Commands

Manual commands (if needed):

```vim
:DapContinue          " Start/continue debugging
:DapStepOver          " Step over
:DapStepInto          " Step into
:DapStepOut           " Step out
:DapToggleBreakpoint  " Toggle breakpoint
:DapTerminate         " Stop debugging
```

## Troubleshooting

### Java debugging not working
- Ensure `java-debug-adapter` is installed: `:Mason`
- Check jdtls is attached: `:LspInfo`
- Verify bundles loaded: Check for errors in `:messages`

### Go debugging not working
- Ensure `delve` is installed: `which dlv` or `:Mason`
- Check Go module is initialized: `go.mod` exists
- Try building first: `go build`

### Rust debugging not working
- Ensure `codelldb` is installed: `:Mason`
- Build debug binary first: `cargo build`
- Verify binary path is correct (usually `target/debug/<name>`)
- Check Cargo.toml exists in project root

### General issues
```vim
:checkhealth dap      " Check DAP health
:messages             " View error messages
:Mason                " Verify adapters installed
```

## Future Enhancements (Parked)

### nvim-dap-ui
Can be added later for visual debugging panels:
- Variables/Scopes panel
- Call stack panel
- Watches panel
- Breakpoints list
- Console output

To add: Create `lua/plugins/dap-ui.lua` with nvim-dap-ui configuration

## Architecture

### Why This Approach?

**Minimal**: Only nvim-dap core, no UI dependencies
**Native**: Uses Neovim's built-in debugging protocol
**Unified**: Same keybindings work across all languages
**Keyboard-first**: No mouse needed, all commands via keys
**Lazy-loaded**: Plugins load only when debug keys pressed

### How It Works

1. **nvim-dap**: Core debugging protocol implementation
2. **Adapters**: Language-specific debug servers (delve, codelldb, java-debug)
3. **Configurations**: Per-language launch configs (auto-detected for Java)
4. **jdtls integration**: Java debug bundles loaded into jdtls for seamless debugging

## Performance

- **Startup impact**: None (lazy-loaded on first debug keypress)
- **Memory**: Minimal (no UI, only core DAP)
- **Adapters**: Start on-demand, terminate after session

## Credits

- **nvim-dap**: Debug Adapter Protocol for Neovim by @mfussenegger
- **nvim-jdtls**: Java LSP with debug integration by @mfussenegger
- **delve**: Official Go debugger
- **codelldb**: LLDB-based debugger for Rust/C++
