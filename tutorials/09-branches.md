# Branches

Branch management in lazygit — creating feature branches, handling hotfixes, and cleaning up when work is merged.

---

## The Branches Panel

In lazygit, press `3` to navigate to the Branches panel. It shows your local branches and, below them, remote-tracking branches. The current branch is highlighted.

Key actions in the Branches panel:

| Key | Action |
|-----|--------|
| `n` | Create a new branch from current HEAD |
| `space` | Checkout a branch (switch to it) |
| `d` | Delete branch (safe — won't delete if unmerged) |
| `D` | Force delete |
| `r` | Rename branch |
| `u` | Set / change upstream tracking |
| `f` | Fetch this branch from remote |
| `M` | Merge this branch into the current branch |
| `R` | Rebase current branch onto this one |
| `<CR>` | View the branch's commit log |
| `p` | Pull |
| `P` | Push |
| `?` | Show all available keys |

---

## Feature Branch Lifecycle

The pattern for all feature work:

### 1. Create the branch

In lazygit, go to the Branches panel (`3`), press `n`:

```
Branch name: feature/add-payment-validation
<CR>
```

Name it descriptively with a prefix: `feature/`, `fix/`, `chore/`, `refactor/`.

lazygit creates the branch and checks it out immediately. Your statusline now shows the new branch name.

### 2. Do the work

Edit, commit, repeat (chapter 8 for the commit workflow). Multiple commits are fine — you can squash them before the PR if needed.

### 3. Push and open a PR

```
P → lazygit prompts to set upstream → confirm
```

First push sets up tracking between your local branch and `origin/<branch-name>`. After that, `P` always pushes to the right place.

Open the PR on Forgejo's web interface (or `gh pr create` from the terminal for GitHub repos).

### 4. Clean up after merge

Once the PR is merged:

```
space on main → checkout main
p             → pull (fast-forward to include the merged changes)
3             → back to branches panel
d             → delete the feature branch (now merged, safe to delete)
```

---

## Hotfix Workflow

A critical bug is found in production while you're mid-way through a feature. You need to fix it without bundling your in-progress work.

### Save your current state

If your working tree is clean (everything committed or WIP-committed), you're ready. Otherwise:

```bash
git wip    # stages everything and commits "WIP" — hooks skipped
```

Or stash in lazygit: Files panel (`2`) → `s` → give it a name like "wip: payment feature".

### Create the hotfix branch from main

```
3             → Branches panel
space         → checkout main
p             → pull latest main (make sure you're fixing the right base)
n             → create hotfix/payment-timeout
```

### Fix, commit, merge

Make the targeted fix. Commit it cleanly (this goes to production, so write a proper message).

```
c → "fix: resolve payment gateway timeout on slow connections"
```

Depending on your team's process: push and PR, or merge directly to main.

```
P             → push
```

After merging:
- Checkout main (`space` on main)
- Pull (`p`)
- Tag the release if needed (chapter 13)

### Return to your feature work

```
space → checkout your feature branch
```

Restore your WIP if you stashed:
- If you used `git wip`: Commits panel (`4`) → navigate to the WIP commit → `g` → soft reset → your changes are back as staged
- If you used lazygit stash: Stash panel (`5`) → `space` to pop

Continue where you left off.

---

## Stash in lazygit

Stash is for temporarily shelving changes when you need to switch context but aren't ready to commit.

**Creating a stash** (in Files panel `2`):

```
s    → stash all changes (prompts for an optional name)
S    → stash options: staged only, untracked only, etc.
```

Give it a descriptive name: "wip: half-finished order validation" — you'll thank yourself later.

**Using the Stash panel** (`5`):

```
space    → pop: apply the stash and delete it
g        → apply: apply without deleting (keeps it for reference)
d        → drop: delete the stash entry
<CR>     → view the stash diff
```

**When to use stash vs `git wip`**:
- Use `git wip` when you might need to rebase or you want the checkpoint in the commit history
- Use stash when it's truly temporary and you'll restore it within minutes/hours

---

## Comparing Branches Before Merging

Before merging a feature branch into main, review what you're about to merge:

```vim
:DiffviewOpen main..HEAD
```

This shows every file that changed in your branch, with the full diff. Navigate through files with `<Tab>`. This is the same view your code reviewer will see.

From the terminal:
```bash
git log main..HEAD --oneline    # list of commits in your branch not in main
git diff main..HEAD -- path/to/file.java    # diff of a specific file
```

---

## Cleaning Up Merged Branches

Over time, merged branches accumulate. Clean them up periodically:

In lazygit Branches panel, `d` on each merged branch.

Or from the terminal (batch cleanup):
```bash
# Delete all local branches that are fully merged into main
git branch --merged main | grep -v "^\* \|main\|develop" | xargs git branch -d
```

Check before running — make sure `develop` or any branches you want to keep are excluded from the grep filter.

---

## Branch Naming Conventions

Consistent naming makes branches scannable in lazygit and on Forgejo:

```
feature/add-order-validation
feature/TICKET-123-payment-gateway
fix/payment-timeout
fix/null-user-id-crash
hotfix/prod-order-processing-failure
chore/upgrade-quarkus-3.9
refactor/extract-payment-service
```

Keep names lowercase-with-hyphens, include a ticket number when relevant, be specific enough that the branch name alone explains the intent.
