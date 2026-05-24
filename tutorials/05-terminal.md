# Terminal Workflow

This chapter is about how to run commands and long-running processes — like `mvn quarkus:dev` — without leaving neovim. The goal is a single editing environment where you can write code, watch it compile, and interact with the running application, all without switching windows.

---

## The Floating Terminal

Press `<C-/>` to open a floating terminal. It appears in the centre of the screen, on top of whatever you were editing. Press `<C-/>` again to hide it. **The process keeps running when hidden** — if you've started `mvn quarkus:dev`, it continues compiling and serving while you edit.

When the terminal is open:
- You are in **terminal mode** — keystrokes go to the shell, not to neovim
- The statusline shows `TERMINAL`
- `<Esc><Esc>` exits terminal mode and puts you back in normal mode (so you can scroll, yank output, or navigate away)

### Getting Back to Editing

The typical flow:
```
1. <C-/>          open terminal
2. type a command  (e.g. mvn quarkus:dev)
3. <Esc><Esc>     exit terminal mode → cursor is now in the terminal buffer (normal mode)
4. <C-/>          hide the terminal → back to your file, process still running
```

Or from inside terminal mode, `<C-h>` / `<C-l>` move you to other neovim windows directly (vim-tmux-navigator works from inside the terminal). You don't have to `<Esc><Esc>` first if you just want to move to a split.

**Try this**: Press `<C-/>` to open the terminal. Run `pwd` — it should be your project root (smart_cwd sets CWD on startup). Run `ls` to see your project files. Press `<Esc><Esc>` to exit terminal mode, then scroll up with `k` to see the output. Press `<C-/>` to hide it.

---

## Running Quarkus Dev Mode

`mvn quarkus:dev` is the process you'll keep running most of the time. Here's the workflow:

```
1. <C-/>                open terminal
2. mvn quarkus:dev       start dev mode (takes ~5s first time)
3. <Esc><Esc>           exit terminal mode
4. <C-/>                hide terminal — Quarkus is running in the background
5. edit your code
6. <C-s>                save → Quarkus detects the change and recompiles (~1-2s)
7. test your endpoint    (browser, curl, Postman)
8. <C-/>                toggle terminal back to check logs if needed
```

Quarkus hot reload triggers on file save, not on every keystroke. So you can make multiple edits and then save once — Quarkus picks up all the changes together.

**Watch for compilation errors**: If your save introduces a compilation error, Quarkus reports it in the terminal output. You'll also see it as LSP diagnostics in the buffer (red `●` inline). Fix the error and save again — Quarkus recovers automatically.

---

## Scrolling Through Terminal Output

After a command runs and produces a lot of output, you often need to scroll up to read it. Here's how:

1. `<Esc><Esc>` — exit terminal mode (cursor is now in the terminal buffer)
2. `k` or `<C-u>` — scroll up through the output
3. `G` — jump to the bottom (latest output)
4. `/{pattern}` — search in the output (e.g. `/ERROR` to find errors)
5. `yy` — yank a line of output to paste elsewhere
6. `i` or `a` — return to terminal mode to type more commands

---

## Interacting With the Running Process

If Quarkus is running and you want to interact with it (e.g. it's waiting for input, or you want to trigger a reload):

1. `<C-/>` — open the terminal
2. `i` or `a` — enter terminal mode
3. Type your input or press the key it's waiting for (e.g. `r` for Quarkus manual reload, `s` to stop)

Quarkus dev mode responds to:
- `r` — force restart
- `s` — stop the application (but keep the JVM running)
- `q` — quit dev mode entirely

---

## Multiple Terminal Instances

`<C-/>` always toggles the same shared terminal. If you need a second terminal (e.g. to run `curl` commands while Quarkus is running in the first terminal), open it from command mode:

```vim
:lua Snacks.terminal("bash", { id = "tools" })
```

Or add a keybinding for it in your config:
```lua
{ "<leader>t2", function() Snacks.terminal("bash", { id = "tools" }) end, desc = "Second terminal" }
```

Each `id` is a separate terminal instance — `<C-/>` still toggles the default one.

---

## Viewing Quarkus Logs While Editing

A common setup when debugging: split the screen and keep the terminal visible in one pane.

```
1. <leader>w-        open a horizontal split below
2. <C-j>             move to the lower split
3. <C-/>             open terminal in the lower split area

Alternatively, open the terminal first:
1. <C-/>             open floating terminal
2. <Esc><Esc>        exit terminal mode
3. <leader>w-        this won't work on the floating terminal

Better approach: use a split, not the float, for persistent log viewing:
1. <leader>w-        split below
2. <C-j>             go to lower split
3. :terminal          open a proper terminal buffer in that split
4. i                  enter terminal mode
5. mvn quarkus:dev    start dev mode
6. <Esc><Esc>        exit terminal mode
7. <C-k>             go back to upper split to edit
```

The lower split stays visible with the Quarkus output scrolling. `<C-j>` jumps down to it, `<C-k>` jumps back up.

---

## When to Use a Tmux Window Instead

The floating terminal is ideal for **short-lived commands** and processes that belong to the current project session. Use a **tmux window** when:

- A process needs to survive beyond your neovim session (e.g. a database, a background service)
- You need a full-screen terminal without neovim's chrome
- You're connecting to a remote server or running something that produces very high-frequency output
- You're running two entirely different projects simultaneously (one per tmux window)

Within a single project, the neovim terminal handles everything. The tmux panes and windows are for cross-project or cross-session concerns.

`<C-h/j/k/l>` moves between neovim splits and tmux panes seamlessly — there's no mental mode-switch required.

---

## Quick Reference

```
<C-/>           toggle floating terminal (open / hide)
<Esc><Esc>      exit terminal mode → normal mode in terminal buffer
i or a          enter terminal mode from normal mode
<C-h/j/k/l>    navigate to other windows / tmux panes (works from terminal)

Common terminal commands:
mvn quarkus:dev                   start Quarkus dev mode
mvn test -Dtest=ClassName         run a specific test class
mvn package -DskipTests           build jar
curl -s localhost:8080/api | jq . test an endpoint
git state                         project status overview
```
