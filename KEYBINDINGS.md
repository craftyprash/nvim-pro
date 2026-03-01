# Neovim Keybindings Cheatsheet

> Leader key: `<Space>`

## General Navigation

### Windows
- `<C-h/j/k/l>` - Navigate windows
- `<leader>w|` - Split vertical
- `<leader>w-` - Split horizontal
- `<leader>wx` - Close window
- `<leader>wr` - Resize mode (h/j/k/l to resize, Esc to exit)

### Buffers
- `<S-h>` / `[b` - Previous buffer
- `<S-l>` / `]b` - Next buffer
- `<leader>bb` - Switch to alternate buffer
- `<leader>bd` - Delete buffer

### Search
- `<Esc>` - Clear search highlight
- `n` / `N` - Next/previous search (centered)

### Terminal
- `<C-/>` - Toggle terminal
- `<Esc><Esc>` - Exit terminal mode (enter normal mode)

**In Terminal Normal Mode:**
- `<C-u>` / `<C-d>` - Scroll up/down half page
- `<C-b>` / `<C-f>` - Scroll up/down full page
- `gg` / `G` - Go to top/bottom
- `j` / `k` - Scroll line by line
- `i` or `a` - Return to terminal mode

## File Explorer (Oil.nvim)

- `-` - Open parent directory
- `<leader>-` - Open parent directory (float)

**Inside Oil:**
- `<CR>` - Enter directory / open file
- `-` - Go to parent
- `q` / `<C-c>` - Close
- `g.` - Toggle hidden files
- `g?` - Show help
- `dd` - Delete file/dir
- `yy` / `p` - Copy/paste
- `i` - Create new file
- `:w` - Save changes to filesystem

## Fuzzy Finder (Snacks Picker)

### Files
- `<leader>ff` - Find files
- `<leader>fr` - Recent files
- `<leader>fb` - Buffers
- `<leader>fc` - Config files
- `<leader>gF` - Git files

### Search
- `<leader>fg` / `<leader>sg` - Grep
- `<leader>sw` - Grep word under cursor
- `<leader>/` / `<leader>sb` - Search buffer lines
- `<leader>sc` - Command history
- `<leader>:` - Commands

### Git
- `<leader>gg` - Lazygit
- `<leader>gb` - Git blame line
- `<leader>gf` - File history
- `<leader>gl` - Git log
- `<leader>gc` - Git log (picker)
- `<leader>gs` - Git status

### LSP/Diagnostics
- `<leader>sd` - Workspace diagnostics
- `<leader>sD` - Buffer diagnostics
- `<leader>ss` - LSP symbols

### Other
- `<leader>sC` - Colorschemes

## LSP (Code Intelligence)

### Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gri` - Go to implementation
- `grr` - Find references
- `grt` - Go to type definition
- `gO` - Document symbols
- `K` - Hover documentation
- `<C-s>` - Signature help (insert mode)

### Diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic

### Code Actions
- `gra` - Code action
- `grn` - Rename symbol
- `<leader>cR` - Rename file

### Formatting
- `<leader>f` - Format buffer (conform + LSP fallback)
- `gq` - Format (uses formatexpr)

### Inlay Hints
- `<leader>ih` - Toggle inlay hints

## Debugging (nvim-dap)

### F-Keys (Frequent Actions)
- `F5` - Continue/Start debugging
- `F9` - Toggle breakpoint
- `F10` - Step over
- `F11` - Step into
- `F12` - Step out

### Leader Keys (Advanced)
- `<leader>dB` - Conditional breakpoint
- `<leader>dC` - Run to cursor
- `<leader>dt` - Terminate session
- `<leader>du` - Toggle debug UI
- `<leader>de` - Eval/hover variable
- `<leader>dr` - Toggle REPL

### Debug Workflow
1. Set breakpoints: `F9`
2. Start debugging: `F5`
3. Step through: `F10` (over), `F11` (into), `F12` (out)
4. Inspect: `<leader>de` (hover) or `<leader>dr` (REPL)
5. Continue: `F5`
6. Terminate: `<leader>dt`

## Completion (Blink.cmp)

**Insert mode:**
- `<C-Space>` - Show completion
- `<C-e>` - Close completion
- `<CR>` - Accept completion
- `<Tab>` - Next item
- `<S-Tab>` - Previous item
- `<C-n>` / `<C-p>` - Navigate items
- `<C-b>` / `<C-f>` - Scroll docs

## Treesitter (Text Objects)

### Selection
- `<C-Space>` - Init/expand selection
- `<BS>` - Shrink selection

### Text Objects
- `af` / `if` - Around/inside function
- `ac` / `ic` - Around/inside class

### Navigation
- `]f` / `[f` - Next/prev function start
- `]F` / `[F` - Next/prev function end
- `]c` / `[c` - Next/prev class start
- `]C` / `[C` - Next/prev class end

## Git Workflow

### Lazygit (Full Git UI)
- `<leader>gg` - Open Lazygit (main interface)
- `<leader>gf` - File history in Lazygit
- `<leader>gl` - Git log in Lazygit

**Inside Lazygit:**
- `1-5` - Switch panels (Status/Files/Branches/Commits/Stash)
- `<Space>` - Stage/unstage file or hunk
- `a` - Stage all
- `c` - Commit
- `A` - Amend commit
- `P` - Push
- `p` - Pull
- `f` - Fetch
- `n` - New branch
- `<Space>` on branch - Checkout branch
- `M` - Merge branch
- `r` - Rebase
- `t` - Create tag
- `T` - View tags
- `d` - View diff options
- `<Enter>` - View file/commit details
- `?` - Show help
- `q` - Quit

### Gitsigns (In-Buffer Git)

**Hunk Navigation:**
- `]h` - Next hunk
- `[h` - Previous hunk

**Hunk Actions:**
- `<leader>ghs` - Stage hunk (normal/visual)
- `<leader>ghr` - Reset hunk (normal/visual)
- `<leader>ghp` - Preview hunk (inline diff)
- `<leader>ghd` - Diff this (split view)

**Buffer Actions:**
- `<leader>ghS` - Stage entire buffer
- `<leader>ghR` - Reset entire buffer
- `<leader>ghu` - Undo stage hunk

**Git Blame:**
- `<leader>gb` - Show blame for current line

### Snacks Picker (Git Search)
- `<leader>gc` - Browse commit history
- `<leader>gs` - Git status (staged/unstaged files)
- `<leader>gF` - Find git-tracked files

### Common Git Workflows

**Quick Commit:**
1. `<leader>gg` - Open Lazygit
2. `<Space>` - Stage files
3. `c` - Commit
4. `P` - Push

**Review Changes:**
1. `]h` / `[h` - Navigate hunks
2. `<leader>ghp` - Preview each hunk
3. `<leader>ghs` - Stage good hunks
4. `<leader>ghr` - Reset bad hunks

**Branch Workflow:**
1. `<leader>gg` - Open Lazygit
2. `3` - Switch to Branches panel
3. `n` - Create new branch
4. Make changes, commit
5. `M` - Merge when ready

**View History:**
- `<leader>gf` - File history (Lazygit)
- `<leader>gc` - Commit history (Picker)
- `<leader>gl` - Full log (Lazygit)

**Compare Branches:**
1. `<leader>gg` - Open Lazygit
2. `3` - Branches panel
3. `<Space>` on branch - Checkout
4. `4` - Commits panel to see diff

## Editing Enhancements

### Move Lines
- `<A-j>` / `<A-k>` - Move line down/up (normal)
- `J` / `K` - Move lines down/up (visual)

### Indenting
- `<` / `>` - Indent left/right (visual, repeatable)

### Git (Gitsigns)
- `]h` / `[h` - Next/prev hunk
- `<leader>ghs` - Stage hunk
- `<leader>ghr` - Reset hunk
- `<leader>ghS` - Stage buffer
- `<leader>ghu` - Undo stage hunk
- `<leader>ghR` - Reset buffer
- `<leader>ghp` - Preview hunk
- `<leader>ghd` - Diff this

## Quickfix / Location List

- `[q` / `]q` - Previous/next quickfix
- `<leader>xq` - Open quickfix list
- `<leader>xl` - Open location list

## Notifications

- `<leader>n` - Notification history
- `<leader>un` - Dismiss notifications

## Plugin Management

- `<leader>l` - Lazy plugin manager
- `<leader>cm` - Mason (LSP/tools)

## Misc

- `<leader>qq` - Quit all
- `<leader>fn` - New file
