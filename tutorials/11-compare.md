# Comparing — Diffs and History

This chapter covers how to see what changed: in a file over time, between two branches, in a specific commit. The right tool depends on what question you're asking.

---

## The Comparison Tools

| Tool | Best for |
|------|---------|
| `<leader>gf` — diffview file history | "What changed in this file over its lifetime?" |
| `<leader>gd` — DiffviewOpen | "What's changed in my working tree vs HEAD?" |
| `:DiffviewOpen main..HEAD` | "What's the full diff of my feature branch?" |
| `<leader>ghd` — gitsigns diffthis | "How does this file look vs HEAD, right now?" |
| `<leader>ghp` — gitsigns hunk preview | "What exactly is in this single changed hunk?" |
| `<leader>gc` — Snacks git log picker | "Let me browse commits and jump to a specific one" |
| `<leader>gl` — lazygit log | "Show me the full graph with branch topology" |

---

## diffview — Full History of a File

`<leader>gf` opens `DiffviewFileHistory` for the current file. This is the answer to "how did we get here?" for any piece of code.

It opens a two-pane layout:
- **Left**: list of every commit that touched this file, in reverse chronological order
- **Right**: the diff for whichever commit you're hovering over

```
<leader>gf
→ left panel: list of commits
→ navigate with j/k
→ the right panel updates live showing that commit's changes to this file
→ <CR> on a commit to open the full diff view
```

**Try this**: Open `OrderService.java` (or whatever your main service class is). Press `<leader>gf`. Navigate up and down the commit list with `j`/`k` — watch the right panel show you what changed in each version. This is how you track down when a behaviour was introduced or when a bug was added.

**Close diffview**: `<leader>gx` or `:DiffviewClose`

### File History Inside a Line Range

In visual mode, select a few lines, then `:DiffviewFileHistory %`. This shows only commits that touched those specific lines — extremely precise when investigating a bug in a specific function.

---

## DiffviewOpen — Working Tree vs HEAD

`<leader>gd` opens a view of everything you've changed since the last commit. This is your "pre-commit review" view.

The layout:
- **Left panel**: list of changed files (staged and unstaged)
- **Right panel**: the diff for the selected file

Navigate the file list with `j`/`k`. Press `<Tab>` to jump to the next changed file, `<S-Tab>` for the previous.

**When to use this**: Before committing, to review exactly what you're about to include. It's a more comfortable reading environment than the lazygit diff view because you have full neovim rendering with syntax highlighting, and you can yank from the diff or search it with `/`.

---

## Branch Comparison — The PR Review View

Before opening a pull request, review the full diff of your branch against main:

```vim
:DiffviewOpen main..HEAD
```

This shows every file your branch has changed compared to main, and the complete diff for each. Navigate with `<Tab>` through files. This is the view your reviewer will see — checking it yourself first catches things you'd otherwise miss.

**Specific commit range**:
```vim
:DiffviewOpen abc123..def456
```

**Compare two branches explicitly** (not just against HEAD):
```vim
:DiffviewOpen feature/old..feature/new
```

---

## Snacks Git Log — Browsing Commits

`<leader>gc` opens the git log in the Snacks picker. Each entry is a commit with its hash, message, author, and date. Type to filter by commit message.

```
<leader>gc
Type: "payment"
→ shows all commits mentioning "payment"
→ <CR> to jump to that commit's diff
→ <C-s> to open in a split
```

This is useful when you remember something about a change ("we added payment validation in March") but don't know which file it's in — search by commit message and navigate from there.

---

## lazygit Log — Full Graph View

`<leader>gl` opens lazygit in the Commits panel. Your config has `showGraph: always`, so you see the full branch topology:

```
* abc123  feat: add order validation
* def456  fix: payment timeout
| * ghi789  feature/old-work (merged)
|/
* jkl012  chore: upgrade quarkus
```

This is the best view for understanding the big picture of your branch's history — merges, branches, the full graph. `<CR>` on any commit to see its full diff.

---

## gitsigns — Quick Inline Comparison

For a quick look without opening diffview:

`<leader>ghp` shows the current hunk as an inline popup. The popup shows the old version in red, the new version in green. Press `<Esc>` to close it. This is the fastest way to double-check a single change before staging it.

`<leader>ghd` opens a vertical split showing the current file versus HEAD. Left side is HEAD, right side is your working tree. Close it with `<leader>wx` or `:q` in the diff split.

---

## Blame — Understanding the History of a Line

`<leader>gb` shows a single-line blame for the current line: the abbreviated commit hash, the author, the date, and the commit message summary. Appears as a floating annotation.

**Go deeper**: If the blame points to a commit you want to investigate further, note the hash, close the float, then search for it in `<leader>gc` (Snacks git log). Or in lazygit commits panel, press `/` to search for the hash.

---

## Delta — CLI Diffs

When you run git commands in the terminal, delta renders them with syntax highlighting, side-by-side view, and line numbers. Your config has:

```ini
[delta]
  side-by-side = true
  line-numbers = true
  navigate = true
```

The `navigate` setting means inside a paged diff, `n` and `N` jump between files — useful when `git diff` produces a multi-file output.

```bash
git diff              # working tree vs staged
git diff HEAD         # working tree vs HEAD (same as <leader>gd but in terminal)
git diff main..HEAD   # your branch diff (same as :DiffviewOpen main..HEAD)
git show abc123       # a specific commit
git log -p            # full log with patches
```

---

## Choosing the Right Tool in Practice

**Before committing**: `<leader>gd` to read through all changes. More comfortable than lazygit's diff for anything non-trivial.

**Before a PR**: `:DiffviewOpen main..HEAD` to simulate the reviewer's view.

**Investigating a bug**: `<leader>gf` on the affected file. Browse the history until you find when the behaviour changed.

**Quick hunk check before staging**: `<leader>ghp` — two seconds, doesn't leave the buffer.

**Understanding the overall history shape**: `<leader>gl` for the lazygit graph.

**Finding a commit by message**: `<leader>gc` Snacks git log picker, type keywords.
