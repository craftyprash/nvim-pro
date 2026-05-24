# Vim Reference Card

## Modes

| Key | From Normal | Mode |
|-----|-------------|------|
| `i` | Normal | Insert before cursor |
| `a` | Normal | Insert after cursor |
| `I` | Normal | Insert at line start |
| `A` | Normal | Insert at line end |
| `o` | Normal | Insert on new line below |
| `O` | Normal | Insert on new line above |
| `v` | Normal | Visual (char) |
| `V` | Normal | Visual (line) |
| `<C-v>` | Normal | Visual (block) |
| `R` | Normal | Replace |
| `:` | Normal | Command-line |
| `<Esc>` | Any | Back to Normal |

---

## Motions — Horizontal

| Key | Move to |
|-----|---------|
| `h l` | Left / right |
| `w W` | Next word start (word / WORD) |
| `b B` | Prev word start |
| `e E` | Word end |
| `ge gE` | Prev word end |
| `0` | Column 0 |
| `^` | First non-blank |
| `$` | Line end |
| `g_` | Last non-blank |
| `f{c} F{c}` | Find char forward / backward (lands on char) |
| `t{c} T{c}` | Till char forward / backward (lands before char) |
| `;` `,` | Repeat last f/t forward / backward |
| `%` | Jump to matching bracket |

## Motions — Vertical

| Key | Move to |
|-----|---------|
| `j k` | Down / up (wrapped lines: `gj gk`) |
| `{ }` | Prev / next empty line (paragraph boundary) |
| `gg G` | File start / end |
| `{n}G` or `:{n}` | Line n |
| `<C-d> <C-u>` | Half page down / up |
| `<C-f> <C-b>` | Full page down / up |
| `M` | Move cursor to middle of visible screen |
| `zz` | Scroll: bring current line to centre of screen |
| `zt` | Scroll: bring current line to top of screen |
| `zb` | Scroll: bring current line to bottom of screen |

> **Note**: `H` and `L` are remapped in this config — they navigate buffers (`<S-h>` / `<S-l>`), not the screen.
> `M` is untouched and still moves the cursor to the visible middle.
>
> `zz / zt / zb` scroll the viewport without moving the cursor's line — useful when you want to
> read context above/below the current position. These are *not* fold commands (fold commands use
> `za zo zc zR zM` — different letters after `z`).

---

## Operators

Operators wait for a **motion** or **text object**: `{operator}{motion}`  
Double the operator to act on the whole line: `dd cc yy ==`

| Operator | Action |
|----------|--------|
| `d` | Delete (cut to register) |
| `c` | Change (delete + enter insert) |
| `y` | Yank (copy) |
| `=` | Auto-indent |
| `>` `<` | Indent right / left |
| `gU` `gu` | Uppercase / lowercase |
| `g~` | Toggle case |
| `!` | Filter through external shell command |

### `=` — Auto-indent

`=` is an operator, so it composes with any motion or text object:

```
==        re-indent current line
=ap       re-indent this paragraph
=aB       re-indent current { } block
gg=G      re-indent entire file
```

In **visual mode**: select lines then `=` to re-indent the selection.

### `!` — Filter through shell

`!` sends a range of lines to a shell command and replaces them with the output.

```
!!date           replace current line with output of `date`
!ap sort         sort the current paragraph alphabetically
!ap column -t    align the paragraph into columns
:%!jq .          pretty-print entire file as JSON (requires jq)
```

**Visual mode**: select lines → `!sort` → the selection is replaced with sorted output.

**In command mode**:
```vim
:.!date          " replace current line
:%!jq .          " replace whole buffer
:'<,'>!sort      " sort visual selection (happens automatically when you type ! in visual)
```

This is powerful for one-off transformations: prettify JSON, sort lines, base64 encode, run a custom script over selected code.

---

## Text Objects

Prefix `i` = inner (no surrounding whitespace/delimiters), `a` = around (includes them).

| Object | Keys |
|--------|------|
| Word | `iw aw` |
| WORD (space-delimited) | `iW aW` |
| Sentence | `is as` |
| Paragraph | `ip ap` |
| `( )` parentheses | `i( a(` or `ib ab` |
| `[ ]` brackets | `i[ a[` |
| `{ }` braces | `i{ a{` or `iB aB` |
| `< >` angle brackets | `i< a<` |
| `" "` double quotes | `i" a"` |
| `' '` single quotes | `i' a'` |
| `` ` ` `` backticks | `` i` a` `` |
| Tag (HTML/XML) | `it at` |
| **Function** (treesitter) | `if af` |
| **Class** (treesitter) | `ic ac` |

**Treesitter incremental selection**: `<C-space>` to expand selection node by node, `<BS>` to shrink.

---

## Registers

| Register | Contents |
|----------|----------|
| `""` | Default (unnamed) — every `d c y` writes here |
| `"0` | Last yank only (not affected by deletes) |
| `"1`–`"9` | Delete history, shifted on each delete |
| `"a`–`"z` | Named: lowercase replaces, uppercase appends |
| `"+` | System clipboard |
| `"_` | Black hole (discard without affecting other registers) |
| `"/` | Last search pattern |
| `":` | Last command |
| `".` | Last inserted text |
| `"%` | Current filename |

**Yank to register**: `"ay{motion}` — **Paste from register**: `"ap`  
**In insert/command mode**: `<C-r>{reg}` pastes inline.  
**Visual paste without clobbering**: `p` is remapped in this config — your yanked text survives paste.

---

## Marks

| Key | Action |
|-----|--------|
| `m{a-z}` | Set local mark (buffer-scoped) |
| `m{A-Z}` | Set global mark (works across files) |
| `` `{mark} `` | Jump to exact position (line + column) |
| `'{mark}` | Jump to mark's line start |
| ` `` ` | Last jump position |
| `''` | Last jump line |
| `` `. `` | Last change position |
| `<C-o> <C-i>` | Jump list: back / forward |
| `g; g,` | Change list: older / newer edit position |

---

## Macros

| Key | Action |
|-----|--------|
| `q{a-z}` | Start recording into register |
| `q` | Stop recording |
| `@{a-z}` | Play macro |
| `@@` | Replay last macro |
| `{n}@{a}` | Play macro n times |
| `:norm @a` | Run macro on every line in a range |

**Edit a macro**: `"ap` to paste into a buffer, edit the text, `V"ay` to yank it back into the register.

---

## Search & Replace

| Key / Command | Action |
|---------------|--------|
| `/{pattern}<CR>` | Search forward |
| `?{pattern}<CR>` | Search backward |
| `n N` | Next / prev result (centered + unfolded) |
| `*` `#` | Search word under cursor fwd / bwd |
| `<Esc>` | Clear highlight |
| `cgn` | Change next match — repeat with `.` for each subsequent match |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace all, confirm each |
| `:'<,'>s/old/new/g` | Replace in visual selection |
| `:g/pattern/d` | Delete all matching lines |
| `:g/pattern/norm @a` | Run macro on all matching lines |

---

## Windows & Splits

| Key | Action |
|-----|--------|
| `<leader>w\|` | Split right (vertical) |
| `<leader>w-` | Split below (horizontal) |
| `<leader>wx` | Close current window |
| `<C-h/j/k/l>` | Navigate between windows **and** tmux panes |
| `<leader>wr` | Enter resize mode (h/j/k/l to resize, Esc exits) |

## Buffers

| Key | Action |
|-----|--------|
| `<S-h>` or `[b` | Previous buffer |
| `<S-l>` or `]b` | Next buffer |
| `<leader>bb` | Toggle between last two buffers |
| `<leader>bd` | Delete buffer (keeps window open) |
| `<leader>fb` | Fuzzy pick from open buffers |

---

## Folds

| Key | Action |
|-----|--------|
| `za` | Toggle fold under cursor |
| `zo zc` | Open / close fold |
| `zO zC` | Open / close all nested folds |
| `zR zM` | Open all / close all folds in file |
| `zj zk` | Jump to next / prev fold |

Folds in this config are **LSP-driven** (`foldexpr = vim.lsp.foldexpr()`). Java import blocks auto-fold on file open — `za` on the imports line to toggle.

---

## Useful Editing

| Key / Command | Action |
|---------------|--------|
| `u` `<C-r>` | Undo / redo |
| `.` | Repeat last change |
| `<C-s>` | Save from any mode |
| `<C-o>` in insert | Execute one normal command then return to insert |
| `xp` | Transpose two characters |
| `J` | Join line below onto current line |
| `ga` | Show Unicode code point for char under cursor |
| `:sort` | Sort selected lines |
