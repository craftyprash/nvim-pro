# Rebase

Rebase rewrites commit history. Used well, it gives you clean, logical commit sequences. This chapter covers the two main uses: cleaning up messy local commits before a PR, and keeping a feature branch up to date with main.

---

## When to Rebase (and When Not To)

**Use rebase for**:
- Cleaning up WIP commits, squashing related commits, reordering before a PR
- Updating a feature branch with new commits from main (instead of a merge commit)
- Fixing a typo in a commit message from earlier in your branch

**Never rebase**:
- Commits that have been pushed to a shared/remote branch that others might have pulled
- The `main` or `develop` branch — merge into those, never rebase them

The rule: rebase is for history you own privately. Once others depend on it, it's immutable.

---

## Interactive Rebase in lazygit

Interactive rebase is where you rearrange, rename, squash, and drop commits. In lazygit, go to the **Commits panel** (`4`).

You'll see your recent commits listed with the most recent at the top. Navigate to the **oldest commit you want to change** and press `e` (or `i` for interactive rebase from that point).

lazygit shows the interactive rebase UI inline — you act on each commit one at a time without opening a separate editor.

### Actions on each commit

Navigate to a commit and press:

| Key | Action |
|-----|--------|
| `r` | **Reword** — change the commit message |
| `s` | **Squash** — merge this commit into the one above it (combines messages) |
| `f` | **Fixup** — merge into the one above, discarding this message |
| `d` | **Drop** — delete this commit entirely |
| `e` | **Edit** — pause the rebase here so you can amend |
| `<C-j>/<C-k>` | Reorder commits (move up/down) |

**Squash vs Fixup**: `s` squash combines both commit messages and prompts you to edit the result. `f` fixup silently drops the message of the lower commit — use it for "fix: typo" style commits where the message adds nothing.

---

## Common Scenario: Cleaning Up Before a PR

You've been working on a feature and your branch looks like this:

```
feat: add order validation endpoint
WIP
fix: forgot to handle null case
WIP
fix: tests passing now
refactor: pull out validation logic
```

That's messy. You want to turn it into something reviewable:

```
feat: add order validation endpoint
refactor: extract validation logic to OrderValidator
```

**Step-by-step in lazygit**:

1. `<leader>gg` → Commits panel (`4`)
2. Navigate to the oldest commit you want to touch (the bottom of the mess)
3. Press `e` to start interactive rebase from there
4. Work through each commit:
   - On each WIP: press `f` (fixup into the commit above) or `d` (drop)
   - On "fix: forgot to handle null case": `f` — fixup into the feature commit
   - On "fix: tests passing now": `d` — drop it (meaningless message)
   - On "refactor: pull out validation logic": `r` — reword it to something better
5. Confirm — lazygit applies the changes

**Try this** on a test repo: Make 3 commits, open lazygit Commits panel, and try squashing two of them. Undo with `git rebase --abort` if you want to start over.

---

## The Fixup Pattern (with autosquash)

Your gitconfig has `rebase.autosquash = true`. This enables a powerful workflow:

### Making a fixup commit

You committed `feat: add order endpoint` (hash `abc123`). Later you find a bug in that commit. Fix it, then:

```bash
git commit --fixup abc123
```

This creates a commit titled `fixup! feat: add order endpoint`. The title is the signal.

### Running the rebase

Later, run interactive rebase covering the range that includes both commits:

```bash
git ri 5    # your alias: git rebase -i HEAD~5
```

Or in lazygit, navigate to the commit before `feat: add order endpoint` and press `e`.

Because `autosquash = true`, git **automatically**:
1. Moves the `fixup!` commit to be directly below `feat: add order endpoint`
2. Marks it as `fixup`

You just confirm and the rebase completes. The fixup is absorbed into the original commit — clean history.

**The advantage**: you can make fixup commits throughout the day and clean them all up in one rebase at the end, without having to manually drag commits around in the interactive editor.

---

## Rebasing a Feature Branch onto Main

When main has moved ahead while you were working on your branch, you need to incorporate those changes. Rebasing is cleaner than merging because it avoids a merge commit in your branch history.

**What's happening visually**:
```
Before:
main:    A - B - C - D - E
feature:         C - X - Y - Z

After rebase:
main:    A - B - C - D - E
feature:                 E - X' - Y' - Z'
```

Your commits X, Y, Z are replayed on top of E. They get new hashes (hence X') because their parent changed.

**In lazygit**:
1. Checkout your feature branch (it should already be checked out)
2. Branches panel (`3`) → navigate to `main`
3. Press `R` → "Rebase current branch onto selected branch"
4. lazygit runs the rebase

**From the terminal**:
```bash
git fetch
git rebase origin/main
```

If there are conflicts, resolve them as described in chapter 12, then `git rebase --continue`. Repeat for each conflicting commit.

---

## Rewording a Commit Message

Found a typo in a commit message from three commits ago?

In lazygit Commits panel, navigate to that commit and press `r`. Neovim opens with just the message. Fix it, `:wq`. Done.

---

## Aborting a Rebase

Something went wrong mid-rebase and you want to start over?

```bash
git rebase --abort
```

This returns the branch to exactly how it was before the rebase started. No permanent damage.

In lazygit: when a rebase is in progress, the status panel shows an abort option.

---

## `git ri` Alias

Your gitconfig has:
```
ri = "!f() { git rebase -i HEAD~$1; }; f"
```

So `git ri 4` opens an interactive rebase for the last 4 commits. This opens nvim with the rebase todo list — an alternative to lazygit's inline UI if you prefer the text-file approach:

```
pick abc123 feat: add order validation
pick def456 WIP
pick ghi789 fix: null pointer in validator
pick jkl012 WIP
```

Change `pick` to `f` (fixup), `s` (squash), `d` (drop), `r` (reword). `:wq` and the rebase runs.
