# Claude Code in Neovim (and other recent additions)

This config bridges Neovim to the `claude` CLI with
[claudecode.nvim](https://github.com/coder/claudecode.nvim). Claude runs in a
split beside your code, can see your current selection and open buffers, and
proposes edits as diffs you accept or reject **inside Neovim** — no copy-paste
between windows.

> **Prerequisite:** the `claude` CLI must be on your `PATH`. Everything below is
> a no-op without it.

## The mental model

claudecode.nvim starts a tiny local WebSocket server; the `claude` CLI connects
to it. That connection is what lets Claude read your selection/buffers and send
edits back as reviewable diffs. You drive the whole loop from normal-mode
keymaps under `<leader>a` ("ai").

## Keymaps

```
<leader>ac    toggle Claude (open/close the split)
<leader>af    focus the Claude split
<leader>ar    resume the previous conversation
<leader>aC    continue the most recent conversation
<leader>am    select the model
<leader>ab    add the current buffer to Claude's context
<leader>as    (visual) send the selected lines to Claude
<leader>as    (in oil / explorer) add the file under the cursor
<leader>aa    accept the proposed diff
<leader>ad    deny the proposed diff
```

`which-key` shows these under the `a` group — press `<leader>a` and pause if you
forget one.

## A practical loop

1. `<leader>ac` to open Claude beside your code.
2. Give it context deliberately — small is better than everything:
   - Visually select the function/block in question, then `<leader>as`.
   - Or `<leader>ab` to hand it the whole current file.
3. Ask for the change in the Claude split.
4. When Claude proposes an edit, it appears as a **diff in Neovim**. Read it,
   then `<leader>aa` to apply or `<leader>ad` to reject. Nothing changes on disk
   until you accept.
5. `<leader>ac` to tuck the split away when you're done; `<leader>ar` later to
   pick the thread back up.

**Tips**
- Tight selections beat dumping the whole file — Claude stays on target and the
  diffs are smaller to review.
- Moving between the Claude split and your editor uses the same `<C-h/j/k/l>`
  window navigation as everywhere else — including out of Neovim's `:terminal`.
  Inside herdr, herdr-splits extends those keys across herdr panes too.
- Prefer a raw REPL? Launch herdr with `h` and run `claude` in its own herdr
  pane. Use claudecode.nvim when you want the in-editor **diff review**; use a
  bare pane when you just want a chat next to the editor.

---

## Other recent additions

### File tree on `<leader>e`

Alongside `oil.nvim` (`-`, edit a directory like a buffer), there's now a
sidebar tree via `Snacks.explorer()`:

```
<leader>e     toggle the file-tree sidebar
-             open the parent directory in oil (buffer-style)
```

Use the tree to browse/orient; use oil to rename/move/create files as text.

### lazydev — Lua completion for the config itself

No keymaps, nothing to invoke. When you edit files under `~/.config/nvim`,
[lazydev.nvim](https://github.com/folke/lazydev.nvim) feeds the full Neovim Lua
API (`vim.*`, `vim.uv`, loaded plugin modules) into completion, so editing your
own config gets real autocomplete and signatures.

### `;` and `,` repeat treesitter motions

After `]f`/`[f`/`]c` (and friends), `;` repeats the jump and `,` reverses it —
see [04-editing.md](04-editing.md#treesitter-text-objects--syntax-aware-selection).

### Python support

Python now has the same LSP experience as Java/Go/Rust/TS:

- **basedpyright** — types, hover, `gd`/`grr`/`grn`, completion.
- **ruff** — lint diagnostics, quick-fixes, and import sorting.
- **format on save** via ruff (organize imports + format) — or `<leader>f`.
- **debugging** — `F5` launches the current file with debugpy (auto-detects an
  active virtualenv or a project `.venv`).

All auto-installed by Mason on first launch; nothing to configure.

### Local autocomplete (Ollama) vs Claude — the tiered split

Two AI layers, each for what it's actually good at:

- **Local, always-on — inline autocomplete.** [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) shows ghost-text suggestions from a small coder model (`qwen2.5-coder:7b`) served by local Ollama. Free, private, works offline, low-latency. This is where a local model genuinely shines. Requires `ollama pull qwen2.5-coder:7b`; if Ollama isn't running it simply shows nothing.

  ```
  <A-a>   accept suggestion      <A-l>   accept one line
  <A-]>   next suggestion        <A-[>   previous
  <A-e>   dismiss
  ```

- **Claude, on-demand — the real work.** Refactors, debugging, "why is this broken", multi-file changes, architecture. A 7B local model won't match it, so hand those to `claudecode.nvim` (`<leader>a*`) or `claude` in a herdr pane.

Rule of thumb: let the local model finish your line; call Claude when you need it to *think*.

