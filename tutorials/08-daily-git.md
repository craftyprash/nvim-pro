# Daily Git Workflow

This is the chapter you'll use most. It covers the loop you'll run dozens of times a week: pull the latest changes, stage your work, write a commit, and push. Along the way: how to handle partial commits, amend mistakes, and undo things safely.

---

## Opening lazygit

`<leader>gg` — this is your main entry point for anything repo-level.

lazygit opens full-screen. It always operates on the git repository at the current CWD, so when you switch projects (chapter 17), lazygit automatically opens for the right repo.

Press `q` to close lazygit and return to your editor.

---

## Understanding the lazygit Layout

When lazygit opens, you see several panels. Navigate between them with the number keys:

- `1` — **Status**: overview of your working tree
- `2` — **Files**: changed files (staged and unstaged)
- `3` — **Branches**: local and remote branches
- `4` — **Commits**: commit log with graph
- `5` — **Stash**: stashed changes

Inside any panel, `j` and `k` move up and down. `<CR>` opens/expands something. `?` shows all available keys for the current panel — this is the help you'll use most while learning.

---

## Pulling Latest Changes

Before starting a work session, pull to make sure you're up to date:

```
<leader>gg     open lazygit
p              pull (respects pull.ff = only)
```

If the pull succeeds, you see the commits that were pulled shown in the log. If it fails (because your branch has diverged), lazygit shows an error. In that case:

```
In the branches panel (3):
→ navigate to your branch
→ R → rebase current branch onto origin/main
```

Or from the terminal: `git pull --rebase`

---

## Staging Changes

### Staging Whole Files

In the **Files panel** (`2`):

```
j / k          move between changed files
<CR>           open the file's diff
space          stage / unstage the file
a              stage all files at once
u              unstage all staged files
d              discard all changes in this file (prompts for confirm)
e              open the file in your editor
```

**Try this**: Make a small change to a Java file. Open lazygit (`<leader>gg>`), go to the Files panel, navigate to your changed file, and press `space` to stage it. Watch it move from the "Unstaged" section to "Staged".

### Staging Individual Hunks — the Right Approach for Focused Commits

If a file has multiple unrelated changes and you want to commit them separately, do the staging in the editor with gitsigns rather than in lazygit:

1. Close lazygit (`q`)
2. In the file, `]h` and `[h` navigate between changed hunks
3. `<leader>ghp` — preview the hunk (see exactly what changed)
4. `<leader>ghs` — stage just this hunk
5. Move to the next hunk, decide whether to stage it
6. Once you've staged what you want, `<leader>gg` to go commit

This workflow is the most precise: you decide exactly which lines go into each commit.

---

## Writing a Commit

Once you have staged changes, press `c` in lazygit. Neovim opens with your `.gitmessage` commit template. The template is already there — you just fill in the top line:

```
feat: add order validation endpoint
                                    ← blank line
The endpoint validates product availability before
persisting the order. Returns 422 if the product
is not available.
```

- First line: `type: short description` — keep it under 50 chars
- Blank line: required separator
- Body: explain the *why*, not the *what* — the diff already shows what changed

`:wq` saves the message and creates the commit. `:q!` aborts without committing.

### Quick Commit Without Opening the Editor

If the change is trivial and the one-liner says everything:

```bash
git cm "fix: handle null userId in order lookup"
```

(`cm` is your alias for `git commit -m`)

### WIP Commits

When you need to save your progress but aren't ready for a real commit:

```bash
git wip
```

This stages everything and commits with message "WIP". lazygit skips pre-commit hooks for WIP commits (configured via `skipHookPrefix: WIP`). Clean it up later with interactive rebase.

---

## Amending the Last Commit

Realized you forgot to include a file, or made a typo in the commit message?

In lazygit, go to the **Commits panel** (`4`). The most recent commit is at the top. Press `A` to amend it.

If you have **staged changes**, they're added to the last commit. If you just want to fix the message, press `r` instead (reword) — it opens nvim with just the message, no code changes.

**Only amend commits you haven't pushed yet.** Amending a commit that's already on the remote rewrites history and will require a force push (avoid this on shared branches).

---

## Pushing

`P` in lazygit (capital P) pushes the current branch to its upstream.

If it's the **first push** of a new branch, lazygit prompts you to set the upstream (usually `origin/<branch-name>`). Confirm and it pushes with tracking set up.

If the push is rejected because the remote has changes you don't have, pull first (rebase), then push again.

---

## Viewing the Diff Before Committing

Before committing, you can review exactly what you're about to include:

```
In lazygit Files panel:
→ navigate to a staged file
→ <CR> to open its diff

Or in the editor:
<leader>gs     Snacks git status picker (shows all changed files with preview)
<leader>gd     DiffviewOpen (working tree vs HEAD, full neovim view)
<leader>ghp    preview the hunk under cursor (inline, in the buffer)
<leader>ghd    full file diff vs HEAD in a split
```

---

## Inline Blame — Who Changed This?

`<leader>gb` shows a floating line at the current cursor position: who last changed this line, when, and the commit summary. Useful when you encounter something unexpected and want to understand its history.

For deeper investigation: in lazygit's Commits panel, navigate to the relevant commit and press `<CR>` to see the full diff.

---

## Undoing Things

| Situation | Fix |
|-----------|-----|
| Staged a hunk by mistake | `<leader>ghu` (gitsigns: undo stage hunk) |
| Want to discard a hunk entirely | `<leader>ghr` (gitsigns: reset hunk) |
| Want to discard all changes in a file | In lazygit Files panel: `d` on that file |
| Committed something wrong (not pushed) | Commits panel in lazygit: `g` → "soft reset" (keeps changes staged) |
| Want to throw away all local changes | `git drop` (alias: reset --hard + clean) — **destructive, no undo** |
| Need to undo a pushed commit | Make a new revert commit: in lazygit Commits panel → `r` on the commit to revert |

---

## Quick Daily Ritual

```
Morning: pull
  <leader>gg → p → q

Working: stage hunks as you finish each logical change
  ]h / [h → <leader>ghp → <leader>ghs

Committing: when you have a coherent set of staged changes
  <leader>gg → c → write message → :wq → P → q

Check project status from terminal:
  git state
  (= fetch + prune + tags + branch -vv + status)
```
