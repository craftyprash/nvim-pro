# LSP & Code Intelligence

The Language Server Protocol (LSP) is what turns neovim from a text editor into something that understands your code. For Java, jdtls (Eclipse JDT Language Server) provides everything: completions, go-to-definition, find references, rename, code actions, and diagnostics — the same engine that powers Eclipse and VSCode's Java support.

This chapter covers how to use those features effectively in day-to-day coding. Chapter 14 covers setup and troubleshooting when jdtls doesn't attach correctly.

---

## Knowing When LSP is Ready

When you open a `.java` file, jdtls starts in the background. Watch the statusline at the bottom — it shows `[jdtls]` once the server has attached. On first open it can take 30–60 seconds while it indexes the project. On subsequent opens the workspace is cached and it's near-instant.

**You can start editing immediately** — the LSP attaches asynchronously. Diagnostics and completions will start appearing once it's ready, even if you opened the file while it was still loading.

To check the current status:
```vim
:LspInfo
```
This shows which servers are attached to the current buffer, the project root it detected, and any errors.

---

## Go-to-Definition — The Most Used Feature

Put your cursor on any class name, method name, or field, and press `gd`. Neovim jumps to where that symbol is defined — even if it's in a different file, a different module, or inside a library jar.

```
You're reading:
    OrderService service = new OrderService();

Cursor on "OrderService" → press gd
→ jumps to OrderService.java, class declaration line
```

Press `<C-o>` to jump back. You can chain this: `gd` into a method, `gd` again into something it calls, `<C-o>` `<C-o>` to unwind both jumps.

**`gD`** is go-to-declaration — for Java this is typically the same as definition, but matters for interfaces where the declaration and implementation differ.

**`gri`** is go-to-implementation. When your cursor is on an interface method, `gri` shows you all concrete implementations in a picker. When there's only one, it jumps directly. When there are multiple, you choose.

```
Cursor on: OrderRepository (interface)
→ press gri
→ picker shows: JpaOrderRepository, MockOrderRepository
→ pick one → jumps to that class
```

**`grt`** is go-to-type-definition. Useful for generics: when you have `List<OrderDto>` and want to see what `OrderDto` looks like, cursor on the variable and `grt` takes you to the type.

**Try this**: Open any Java service class. Find a method call on an injected dependency. Put your cursor on the dependency class name and press `gd` — you should land in that class's source. Press `<C-o>` to come back. Now put your cursor on the interface name in a field declaration and press `gri` — it should show you the implementations.

---

## Finding References — Where Is This Used?

`grr` finds every place in the project where the symbol under the cursor is referenced, and opens them in the Snacks picker.

```
Cursor on: processOrder (method name in the declaration)
→ press grr
→ picker shows all call sites with file and line number
→ navigate with j/k, <CR> to jump to that location
```

This is how you understand the impact of a change before making it. Before renaming a method, `grr` tells you how many callers exist and where they are.

**`<leader>ss`** is similar but searches by name across the whole project — useful when you know the name of something but don't have a file open that references it.

---

## Hover Documentation — `K`

Press `K` with the cursor on any symbol to see its Javadoc in a floating window. Press `K` again to move the cursor into the float so you can scroll it. Press `<Esc>` or `q` to close it.

```
Cursor on: LocalDateTime.now()
→ press K
→ float shows: "Obtains the current date-time from the system clock..."
               with parameter docs and return type
```

This works for your own code too — if you've written Javadoc on a method, `K` shows it when hovering from a call site.

---

## Signature Help — Parameter Hints While Typing

When you're inside a method call, in **insert mode**, press `<C-s>` to show the parameter list:

```java
createOrder(|         ← cursor here in insert mode
→ press <C-s>
→ float shows: createOrder(String productId, int quantity, UserId userId)
```

This appears automatically as a float when you type `(` after a method name — you shouldn't need to press `<C-s>` manually in most cases. But if it disappeared and you want it back, `<C-s>` brings it up again.

---

## Inlay Hints

Inlay hints show parameter names and inferred types inline in the code, without you having to hover:

```java
// What you see with inlay hints on:
createOrder(productId: "abc", quantity: 2, notify: true);

// What the source actually contains:
createOrder("abc", 2, true);
```

They're enabled by default. Toggle with `<leader>ih`. If they're making the code feel cluttered, turn them off — they're most valuable on methods with multiple boolean or int parameters where the purpose isn't obvious.

---

## Code Actions — `gra`

`gra` opens a context-sensitive menu of actions the language server can perform at the current cursor position. The options change depending on where your cursor is.

**Try this workflow**: Open a Java class that has fields but no getters/setters. Put your cursor anywhere in the class body. Press `gra`. You should see options like "Generate getters", "Generate setters", "Generate constructor", "Generate toString".

**On a line with a diagnostic error** (red underline):
```
import com.example.OrderDto;   ← unused import
→ cursor on this line → gra
→ "Remove unused import"
→ "Organize imports"
```

**On a selected range of code** (select first with `v` or `V`, then `gra`):
```
V → select 3 lines of code → gra
→ "Extract method" — wraps selection into a new method
→ "Extract variable" — pulls expression into a named local
```

The full list of jdtls code actions is in chapter 15. The key habit to build is: whenever you see a yellow lightbulb hint or a diagnostic, reach for `gra` before reaching for your keyboard to type the fix manually.

---

## Rename — `grn`

`grn` renames the symbol under the cursor **across every file in the project**. It uses the AST (abstract syntax tree), so it only renames actual usages of that symbol — not string literals that happen to contain the same text.

```
Cursor on: processOrder (the method declaration)
→ press grn
→ a small input box appears, pre-filled with "processOrder"
→ type the new name: "handleOrder"
→ press <CR>
→ jdtls renames every call site, import, and reference
```

**Try renaming a local variable first** to see how it works — low risk, easy to undo with `u`.

`<leader>cR` renames the **file** itself (not the symbol) and updates the class name and imports throughout the project.

---

## Diagnostics — Errors and Warnings

jdtls reports errors and warnings continuously as you type. They appear as:
- `●` virtual text at the end of the line, coloured by severity
- Coloured underlines on the problematic code
- Signs in the left gutter (the sign column)

### Navigating Diagnostics

`[d` and `]d` jump to the previous/next diagnostic in the current file.

```
→ press ]d
→ cursor jumps to the next error
→ a float appears showing the full error message
→ press gra to see code action options for this error
```

`<leader>sd` opens all diagnostics across the whole workspace in the picker. When you've made a large refactor and want to see all the broken things at once, this is the view you want.

`<leader>sD` is the same but scoped to the current buffer.

### Responding to Diagnostics

The typical flow when you see a red underline:
1. Move to it with `]d` or just navigate there
2. Press `K` to read the full error message
3. Press `gra` to see if there's an automated fix

---

## Formatting

Format the current buffer with `<leader>f`. This runs `google-java-format` via conform.nvim — the same formatter that runs automatically on save.

If you want to format just a selection: select with `V`, then `<leader>f` formats the selected lines.

Format also runs on every `:w` (save) automatically. If you want to save **without** formatting: `:noautocmd w`.

---

## Quick Reference

```
gd          go to definition
gD          go to declaration
gri         go to implementation
grt         go to type definition
grr         find all references
gO          document symbols (current file)
<leader>ss  workspace symbols (project-wide search)

K           hover docs
<C-s>       signature help (insert mode)
<leader>ih  toggle inlay hints

gra         code actions
grn         rename symbol
<leader>cR  rename file + update imports
<leader>f   format buffer

[d / ]d     prev / next diagnostic
<leader>sd  workspace diagnostics picker
<leader>sD  buffer diagnostics picker

<C-o>       jump back after gd/gri/grr
:LspInfo    check server status
```
