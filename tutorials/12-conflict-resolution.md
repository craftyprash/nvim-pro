# Conflict Resolution

Merge conflicts happen when two branches both modified the same part of a file. This chapter walks through how to resolve them using diffview's three-way merge layout — which is significantly easier than editing raw conflict markers by hand.

---

## Understanding Your Conflict Format

Your gitconfig has `conflictstyle = diff3`. This gives you three sections instead of the usual two:

```java
<<<<<<< HEAD (your branch)
return processOrder(order);
||||||| base (common ancestor — what it looked like before either branch touched it)
return handleOrder(order);
=======
return validateAndProcess(order);
>>>>>>> feature/payment-validation (incoming branch)
```

The **base** section (between `|||||||` and `=======`) shows the original code before either branch diverged. This is invaluable: it tells you what both sides *changed from*, not just what they each changed *to*. Without it, you're guessing what the intent was. With it, you can reason about both changes.

---

## How Conflicts Arise

**During a merge**:
```
git merge feature/payment-validation
```
When main has diverged from your feature branch and both touched the same lines.

**During a rebase**:
```
git rebase origin/main
```
When replaying your commits on top of main, a conflict appears for each commit that touches conflicting lines.

The resolution process is the same for both — the difference is what you run afterwards (`git commit` for merge, `git rebase --continue` for rebase).

---

## Opening the diffview Merge Tool

When you're mid-conflict, open diffview:

```
<leader>gd    (DiffviewOpen)
```

diffview detects the conflicted state and automatically opens the three-way merge tool layout:

```
┌──────────────────┬──────────────────┬──────────────────┐
│   OURS           │   BASE           │   THEIRS         │
│  (your branch)   │  (common anc.)   │  (incoming)      │
│  [read only]     │  [read only]     │  [read only]     │
├──────────────────┴──────────────────┴──────────────────┤
│                   RESULT                                │
│           (edit this buffer directly)                   │
└─────────────────────────────────────────────────────────┘
```

The three top panels are **read-only references** — you can't accidentally break them. The **result** panel at the bottom is what you edit. This is the file as it will look after you resolve the conflict.

---

## Navigating Through Conflicts

In the result buffer:

```
]x    → jump to next conflict marker
[x    → jump to previous conflict marker
<Tab> → next conflicted file (in the file list panel)
```

Each conflict in the result buffer looks like the diff3 output. Your job is to replace each conflict block with the correct code.

---

## Resolving a Conflict

For each conflict block, you have three main approaches:

### Choose one side entirely

In the **result** buffer, with cursor anywhere in the conflict block:

```
<leader>co    → take "ours" (your branch's version)
<leader>ct    → take "theirs" (the incoming branch's version)
<leader>cb    → take "base" (the version before either branch changed it)
<leader>ca    → take all (both ours and theirs, ours first)
```

These commands replace the entire conflict block (including the markers) with the chosen version. Use this when one side is clearly right and the other is wrong, or when the changes don't interact.

### Edit manually

When neither side is fully right — you need to combine both changes, or the result is something different from either:

Just edit the result buffer directly like any file. Delete the `<<<<<<<`, `|||||||`, `=======`, `>>>>>>>` markers and write what the code should actually look like. The three top panels are your reference — look at ours, base, and theirs to understand both sides' intent, then write the correct merged version.

**Example**: Ours added validation, theirs added logging to the same method. Neither alone is right — you need both:

```java
// What you write in the result buffer:
public Response createOrder(OrderRequest request) {
    log.info("Creating order for product: {}", request.getProductId()); // from theirs
    validateRequest(request);  // from ours
    Order saved = orderService.save(request);
    return Response.ok(saved).build();
}
```

---

## After Resolving Each File

Once you've fixed all conflicts in a file:
1. `:w` to save the result buffer
2. `<Tab>` to move to the next conflicted file
3. Repeat

When all files are resolved:
1. `<leader>gx` to close diffview
2. Stage the resolved files:
   - `<leader>ghS` on each resolved file (gitsigns: stage buffer), OR
   - `<leader>gg` → lazygit Files panel → `space` to stage each file
3. Continue:
   - **Merge**: In lazygit, `c` to commit (git pre-fills the merge commit message)
   - **Rebase**: `git rebase --continue` in the terminal, or lazygit will show a "continue" option

---

## Aborting — Starting Over

If the conflicts are overwhelming or you've made a mess:

```bash
git merge --abort      # during a merge conflict
git rebase --abort     # during a rebase conflict
```

This returns everything to exactly the pre-conflict state. No permanent damage — you can try again.

---

## Prevention: Rebase Frequently

The most effective conflict reduction strategy is keeping your feature branch rebased onto latest main. Small, frequent rebases mean conflicts are small and recent — you have context for what both sides changed and why.

```bash
# From your feature branch:
git fetch
git rebase origin/main
```

Or in lazygit: Branches panel (`3`) → navigate to `main` → `R` to rebase current branch onto it.

A branch that diverged for a week might have 20 conflicting commits to resolve one by one during rebase. A branch rebased daily usually has zero conflicts, or one tiny one.

---

## Rebase Conflicts Are Different From Merge Conflicts

During a **rebase**, conflicts are resolved commit-by-commit. If your branch has 5 commits and 3 of them conflict with main, you'll resolve conflicts 3 times (once per conflicting commit), running `git rebase --continue` after each resolution.

During a **merge**, all conflicts appear at once. You resolve them all in one session, then `git commit`.

This is why rebases with many conflicting commits can feel tedious — you're replaying history one commit at a time. If a rebase gets unwieldy, `git rebase --abort` and consider a merge instead (accepting the merge commit in your history).
