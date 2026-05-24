# Git Mental Model

Before diving into specific git workflows, it's worth understanding the three tools in this setup and when to reach for each one. Using the wrong tool for a task creates friction; using the right one makes git feel natural.

---

## Three Tools, One Workflow

### gitsigns — Stay in the Buffer

gitsigns adds git awareness to the buffer you're already editing. The coloured marks in the left gutter (`▎` for added/changed lines, `` for deleted lines) show what's changed since the last commit, updated live as you edit.

**Reach for gitsigns when** you want to work at the *hunk* level — a hunk being a contiguous block of changed lines. You can preview a hunk to see what you changed, stage just that hunk (leaving other changes in the file unstaged), reset it (discard those specific lines), or get blame for the current line.

The key insight: gitsigns keeps you in the file. You never have to open a separate panel. It's for surgical, granular work: "I want to commit this change but not that one in the same file."

### lazygit — Everything at the Repo Level

`<leader>gg` opens lazygit, a full-screen TUI (text user interface) that shows your repository's state: files, branches, commits, stashes — everything. It's the tool for any operation that affects the whole repo rather than a single hunk.

**Reach for lazygit when** you're committing, pushing, pulling, creating branches, doing interactive rebase, managing stashes, or reading the log. Basically: once you've decided what to stage, go to lazygit to write the commit and push.

### diffview — Visual Comparison

diffview renders diffs as neovim splits with syntax highlighting. Unlike lazygit's TUI overlay, diffview integrates with the editor — you can navigate between files, search, yank from diffs, and resolve conflicts in a familiar environment.

**Reach for diffview when** you need to *read* changes carefully: reviewing your branch's diff before a PR, exploring a file's full history, or resolving merge conflicts in a three-way layout.

---

## How They Compose

The three tools work together naturally:

```
1. You've been editing OrderService.java and PaymentService.java.
   You want to commit only the OrderService changes.

2. In OrderService.java:
   → ]h to navigate to each changed hunk
   → <leader>ghp to preview each hunk (what did I change here?)
   → <leader>ghs to stage the hunks you want in this commit
   → Leave the PaymentService hunks unstaged

3. <leader>gg to open lazygit
   → Files panel shows OrderService as staged, PaymentService as unstaged
   → c to commit → write message following the template → :wq
   → P to push

4. Later, when you're ready to commit PaymentService:
   → Repeat from step 2 for that file
```

The result is a clean, focused commit history even when you've made changes across multiple concerns simultaneously.

---

## Your Configuration Notes

### `git wip` + `skipHookPrefix: WIP`

Your `~/.gitconfig` has a `wip` alias:
```bash
git wip   # = git add --all && git commit -m 'WIP'
```

And your `~/.config/lazygit/config.yml` has:
```yaml
git:
  skipHookPrefix: WIP
```

This means WIP commits bypass pre-commit hooks (linting, tests, etc.). The intended use is quick checkpointing — save your progress when you need to switch branches or step away, without going through the full commit ceremony. These WIP commits are temporary scaffolding: clean them up before a PR using interactive rebase (chapter 10).

**Don't ship WIP commits** — they're for your working-in-progress only.

### `pull.ff = only`

Your gitconfig has `pull.ff = only`. This means `git pull` (and `p` in lazygit) will refuse to pull if your local branch has diverged from the remote. You'll see an error like "fatal: Not possible to fast-forward".

This is intentional — it prevents silent merge commits from polluting your history. When it happens, you have two options:

```bash
# Option 1: rebase your local commits on top of the remote
git pull --rebase

# Option 2: fetch first, then decide
git fetch
git log HEAD..origin/main --oneline  # see what's new on remote
git rebase origin/main               # or git merge origin/main
```

In lazygit, when a pull fails due to divergence, the error is shown clearly. Use the rebase option — it's cleaner for feature branch work.

### `rebase.autosquash = true`

When you run interactive rebase and you have commits titled `fixup! some message`, git automatically moves them next to the commit with `some message` and marks them as `fixup`. You don't have to arrange them manually.

This pairs with `git commit --fixup <hash>` — create a fix for a specific commit, and the next rebase will absorb it automatically. Chapter 10 covers this in practice.

### Multi-Identity — Automatic

Your `.gitconfig` has `includeIf` blocks that switch git identity based on the directory:

```
~/Developer/forgejo.mintifi.com/   →  work identity
~/Developer/github.com/craftyprash/ →  crafty identity
~/Developer/github.com/craftyshelf/ →  crafty identity
```

You don't have to do anything — git reads the right config per directory automatically. SSH key selection is handled by `~/.ssh/config` per host. If you're ever unsure which identity is active:

```bash
git config user.email    # in the repo directory
```

### Commit Template

When you commit in lazygit (`c`) or from the terminal (`git c`), nvim opens with your `.gitmessage` template. The template shows the conventional commits format:

```
feat:     new feature
fix:      bug fix
refactor: code change that neither fixes nor adds
chore:    maintenance (deps, build)
docs:     documentation only
perf:     performance improvement
```

Write the subject line first (max 50 chars), leave a blank line, then explain the *why* in the body if needed. `:wq` to confirm the commit.

---

## The Golden Rule

**Stage with gitsigns. Commit and branch with lazygit. Compare and resolve with diffview.**

When in doubt about which tool to use: if you're inside a file, use gitsigns. If you need to look at the whole repository, open lazygit. If you need to see a diff or resolve a conflict, open diffview.
