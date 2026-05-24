# Multi-Project Workflow

Managing several repos — switching between them cleanly, restoring where you left off, and keeping git identities straight without any manual intervention.

---

## Your Repository Layout

Everything lives under `~/Developer/`, organised by host:

```
~/Developer/
├── forgejo.mintifi.com/
│   └── org-name/
│       ├── order-service/          ← work repo
│       ├── payment-service/        ← work repo
│       └── api-gateway/            ← work repo
├── github.com/
│   ├── craftyprash/                ← personal
│   └── craftyshelf/                ← personal
└── gitlab.com/
    └── username/                   ← personal
```

All git identities switch automatically based on directory path (via `includeIf` in `~/.gitconfig`). SSH keys are managed by `~/.ssh/config` per host. You never have to configure anything when opening a different project.

---

## Cloning a New Repo

`ghq get` handles placement automatically — you never have to think about where to put things:

```bash
# Work repos on Forgejo
ghq get forgejo.mintifi.com/org/new-service

# Personal GitHub
ghq get github.com/craftyprash/new-project

# From a full SSH or HTTPS URL
ghq get git@forgejo.mintifi.com:org/service.git
```

After cloning, `z <repo-name>` starts working immediately (zoxide learns the directory). The repo is ready to open.

---

## Switching Projects — The Full Flow

### First visit to a project

```bash
z order-service    # terminal: jump to the project directory
nvim .             # open neovim
```

`smart_cwd` sets CWD to the project root automatically (detects `.git`). Open a `.java` file — jdtls starts indexing in the background. Work. When you close neovim, persistence.nvim saves your session automatically.

### Returning to a project

```
<leader>fp         open zoxide project picker
type: order        filter to order-service
<CR>               CWD switches to that project
<leader>qs         restore session (opens your buffers exactly as you left them)
```

Alternatively, from the dashboard (`p` key) when you first open neovim.

The session includes: open buffers, split layout, cursor positions, fold state. It doesn't include: running terminals, DAP sessions, or LSP state — those restart fresh each time.

---

## Session Management Keys

| Key | What it does |
|-----|-------------|
| `<leader>qs` | Restore the session for the current directory |
| `<leader>qS` | Browse all saved sessions across projects and pick one |
| `<leader>ql` | Restore the most recently closed session (regardless of CWD) |
| `<leader>qd` | Stop saving session for this directory (use before closing if you want a clean state next time) |

**Practical tip**: If you've left a project in a messy state (wrong split layout, too many buffers open), press `<leader>qd` before closing neovim. Next visit starts fresh instead of restoring the mess.

**`<leader>qS`** is useful when you want to quickly resume whichever project you were in most recently across all your work — it lists sessions by last modification date.

---

## Identity Verification

Before pushing work, confirm you're committing as the right person:

```bash
git config user.email    # in the repo directory
```

Expected:
- In `~/Developer/forgejo.mintifi.com/`: your work email
- In `~/Developer/github.com/craftyprash/` or `craftyshelf/`: your personal/crafty email

If you see the wrong identity, check that the `includeIf` path in `~/.gitconfig` matches the actual directory path exactly (trailing slash in the glob pattern matters).

---

## lazygit Follows CWD

`<leader>gg` opens lazygit for whatever git repository is at the current CWD. When you switch projects with `<leader>fp`, the CWD changes, so the next `<leader>gg` automatically opens for the new project's repo.

No configuration needed. lazygit doesn't have a concept of "current repo" separate from the directory.

---

## jdtls Per-Project Isolation

Each Java project gets its own jdtls workspace:
```
~/.local/share/jdtls-workspace/<sanitised-project-path>/
```

This means:
- Switching projects never confuses jdtls — each project's types, imports, and class index are completely separate
- Opening `OrderService` in the payment-service project doesn't show completions from the order-service project
- If one project's workspace gets corrupted, deleting just that directory fixes it without affecting other projects

When you first open a project, jdtls re-indexes it (30–60s). After that, subsequent opens use the cache.

---

## Finding Repos

```bash
ghq list                     # all cloned repos
ghq list | grep service      # filter by name
ghq list -p                  # full absolute paths

z <partial-name>             # jump by zoxide score (most recently visited first)
```

Inside neovim, `<leader>fp` (zoxide picker) shows your most-visited directories. The dashboard `p` key does the same. Type to filter — partial matches work.

---

## Keeping Multiple Projects Open Simultaneously

Sometimes you genuinely need two projects side by side — e.g. reading an API contract from one service while implementing the client in another.

**Option 1: Two tmux windows**
```
<prefix>c    # new tmux window
z second-project
nvim .
```
Each tmux window runs its own neovim session. `<C-h/j/k/l>` navigates within each neovim instance. Switch between tmux windows with `<prefix>1`, `<prefix>2`, etc.

**Option 2: Multiple neovim splits pointing at different projects**
Not recommended — CWD is global in neovim, so only one project can be "active" for LSP, git, and file-finding at a time.

For most multi-project work, tmux windows are the right tool. Use neovim's split workflow for files within a single project.

---

## Checking What's Pending Across Projects

When you come back to work after time away, a quick check on each project:

```bash
# In each project directory:
git state
# (= git fetch --prune && git fetch --tags && git branch -vv && git status)
```

This shows: all branches, their tracking status (ahead/behind remote), and working tree state. Run it before starting the day on each project you'll be touching.
