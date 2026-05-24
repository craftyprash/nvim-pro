# Navigation

This chapter covers how to find and open files, move between them, manage splits, and switch projects — the daily mechanics of working in neovim. By the end you should be able to navigate a multi-file Java project without ever reaching for a mouse.

---

## The Core Idea: Two Navigation Modes

There are two kinds of navigation in this setup:

1. **Fuzzy finding** (Snacks picker) — when you know what you're looking for but not exactly where it is. Type a partial name and let the tool find it.
2. **Directory browsing** (oil.nvim) — when you want to explore the project structure, rename files, or create new ones.

Most of the time you'll use fuzzy finding. Directory browsing is for structural work.

---

## Snacks Picker — Finding Anything by Name

The picker is built on ripgrep and fd, which are already on your PATH. It opens as a floating window: a search box at the top, results below, a file preview on the right.

### Opening Files

Press `<leader>ff` to open the file finder. Start typing any part of the filename — it doesn't have to be the beginning:

```
<leader>ff
Type: OrderSer
→ matches OrderService.java, OrderServiceTest.java
→ use <Tab> or arrow keys to move between results
→ press <CR> to open
```

**Try this**: Open neovim in your project root, press `<leader>ff`, type the name of a class you know exists, and open it. Then press `<leader>ff` again — your recently used files appear at the top, so it doubles as a quick-switch for files you've recently touched.

**Open in a split instead of the current window**:
- `<C-s>` — open in horizontal split
- `<C-v>` — open in vertical split
- `<C-t>` — open in new tab

### Recent Files

`<leader>fr` shows files you've opened recently across all projects. If you closed neovim and came back, this is the fastest way to get back to what you were working on (before session restore kicks in — see chapter 17).

### Searching Inside Files — Live Grep

`<leader>fg` opens live grep: as you type, it searches file contents across the whole project using ripgrep.

```
<leader>fg
Type: processOrder
→ shows every file + line containing "processOrder"
→ <CR> to open at that exact line
```

This is faster than `:grep` or `:vimgrep` — results appear as you type with no intermediate step.

**`<leader>sw`** is the same but pre-fills the word under your cursor. If your cursor is on `OrderService`, press `<leader>sw` and it immediately searches for all usages of that word. This is a quick way to find call sites without going through the LSP (which is more precise but takes a moment to load).

### Searching in the Current Buffer

`<leader>/` (or `<leader>sb`) searches only the lines in the current file. Useful when the file is large and you want to jump to a method or section by name without leaving the buffer.

### Other Useful Pickers

| Key | Use it when... |
|-----|----------------|
| `<leader>fb` | You have multiple files open and want to switch between them |
| `<leader>ss` | You want to jump to a specific class, method, or field by name (LSP symbols) |
| `<leader>sd` | You want to see all errors and warnings across the whole workspace |
| `<leader>st` | You left TODOs in the code and want to review them |
| `<leader>fc` | You want to edit your neovim config files |
| `<leader>sC` | You want to switch the colour scheme |

**Inside any picker**:
- Type to filter
- `<CR>` to open
- `<Esc>` to close without opening anything
- `<C-b>/<C-f>` to scroll the preview pane

---

## oil.nvim — The Filesystem as a Buffer

oil.nvim treats a directory listing like a text file. You can rename a file by editing its name on the line, delete a file with `dd`, create a file by typing a new name — and `:w` commits all the changes to disk at once.

### Opening oil

Press `-` from any buffer to open the parent directory of the current file. The cursor lands on the file you were just editing.

```
You're editing: src/main/java/com/example/OrderService.java
Press: -
→ oil opens showing the contents of com/example/
→ cursor is on OrderService.java
```

Press `-` again to go up another level. Press `<CR>` to enter a directory or open a file.

`<leader>-` opens oil as a floating window instead — useful when you want a quick directory glance without disrupting your split layout.

### File Operations in oil

| Key | Action |
|-----|--------|
| `<CR>` | Open file or enter directory |
| `-` | Go up to parent directory |
| `<C-r>` | Refresh the listing |
| `g.` | Toggle hidden files |
| `q` or `<C-c>` | Close oil |

**Creating a file**: Navigate to the directory where you want the file, then just type the filename on a new line (press `o` to open a new line). Type `NewClass.java`. Then `:w` — the file is created on disk.

**Renaming a file**: Move your cursor to the filename, use `cw` or `ciw` to change the name inline. `:w` renames it on disk.

**Deleting**: `dd` to delete the line (= the file). `:w` deletes it from disk.

**Batch operations**: You can rename multiple files in one session — edit several names, then `:w` once to apply them all. This is more reliable than doing it one by one in a shell.

**Try this**: Press `-` to open the parent directory of any open file. Navigate up a level or two with `-`, find a file you want to open, and press `<CR>` on it.

---

## Buffer Navigation

A buffer is neovim's in-memory copy of a file. Every file you open becomes a buffer and stays in memory until you explicitly delete it.

### Switching Between Open Buffers

`<S-l>` (Shift+L) goes to the next buffer. `<S-h>` (Shift+H) goes to the previous buffer. These cycle through all open buffers in order.

`<leader>bb` is the fastest: it toggles between the last two buffers you were in, like `Alt+Tab` on a desktop. When you jump to a definition and come back, this is what you use.

`<leader>fb` opens the buffer picker — see all open buffers with preview, type to filter. Use this when you have many files open and want to jump to one that isn't adjacent in the cycle.

### Closing Buffers

`<leader>bd` deletes the current buffer but keeps the window open (fills it with the previous buffer). This is usually what you want — `:q` would close the window too.

**Try this**: Open three or four Java files using `<leader>ff`. Then use `<S-l>` and `<S-h>` to cycle through them. Use `<leader>bb` to toggle between the last two. Then use `<leader>fb` to pick one by name from the picker.

---

## Window Splits

Sometimes you need to see two files at the same time — a controller and its service, a test and the class it's testing.

`<leader>w|` splits the current window vertically (opens a copy of the current file on the right).  
`<leader>w-` splits horizontally.

Then use `<C-h>` and `<C-l>` to move between the left and right split, `<C-j>` and `<C-k>` for top and bottom. **This works across tmux panes too** — the same keys move you between neovim splits and tmux panes seamlessly.

**Resizing**: Press `<leader>wr` to enter resize mode. Then use `h/j/k/l` to make the current window smaller or larger. Press `Esc` to exit resize mode.

`<leader>wx` closes the current window (doesn't delete the buffer).

**Try this**: Open a Java interface file. Split with `<leader>w|`. In the right split, use `<leader>ff` to open its implementation. Now you can see both side by side. Navigate between them with `<C-h>` and `<C-l>`.

---

## Zoxide — Project Switching

Zoxide tracks which directories you visit and scores them by recency and frequency. After you've visited a project directory once, `z <partial-name>` from the terminal jumps there instantly.

Inside neovim, `<leader>fp` opens the zoxide picker — a list of your most-visited directories. Type a partial name and press `<CR>` to switch to that project.

```
<leader>fp
Type: order
→ matches ~/Developer/forgejo.mintifi.com/org/order-service
→ <CR>
→ CWD changes to that project's root
→ <leader>qs to restore your last session there
```

The startup dashboard (the screen you see when you open neovim without a file) also has `p` for the same zoxide picker.

**The full project-switch flow**:
1. `<leader>fp` → pick the project → `<CR>`
2. `<leader>qs` → restore the session (opens your buffers from last time)
3. Open any `.java` file → jdtls re-attaches in the background

See chapter 17 for more detail on managing multiple projects.

---

## Jump List — Getting Back to Where You Were

Every time you make a significant jump (open a file, `gd` to a definition, search, `gg`, `G`), neovim records your position in the jump list.

`<C-o>` goes back. `<C-i>` goes forward.

**The pattern you'll use constantly**: press `gd` to jump to a definition → read it → press `<C-o>` to jump back to where you were. This works across files. You can chain multiple `<C-o>` presses to unwind a chain of jumps.

`g;` and `g,` are the change list — they navigate between positions where you made edits, not just where you jumped. Useful for finding the last place you typed something.

---

## Quick Reference

```
<leader>ff    find file by name
<leader>fr    recent files
<leader>fb    open buffers picker
<leader>fg    live grep (search file contents)
<leader>sw    grep word under cursor
<leader>/     search current buffer
<leader>ss    LSP symbols
<leader>sd    workspace diagnostics
<leader>fp    zoxide project picker

-             oil: parent directory
<leader>-     oil: floating parent directory
<CR>          oil: open file or directory

<S-h> / [b   previous buffer
<S-l> / ]b   next buffer
<leader>bb    toggle last two buffers
<leader>bd    delete buffer

<leader>w|    split right
<leader>w-    split below
<leader>wx    close window
<C-h/j/k/l>  navigate windows + tmux panes
<leader>wr    resize mode

<C-o>         jump back
<C-i>         jump forward
```
