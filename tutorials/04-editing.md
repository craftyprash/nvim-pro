# Power Editing

This chapter covers the editing tools that go beyond basic vim: completion, surround, comments, treesitter-aware text objects, and the small habits that compound into speed. These work together — by the end, you should be able to write and reshape Java code with very few keystrokes.

---

## Completion — blink.cmp

Completion in this config uses blink.cmp with four sources: LSP (primary), file paths, buffer words, and snippets. The menu appears automatically as you type — you don't have to trigger it manually most of the time.

### Accepting a Completion

When the menu is open:
- `<Tab>` or `<C-n>` — move to the next item
- `<S-Tab>` or `<C-p>` — move to the previous item
- `<CR>` or `<C-y>` — accept the selected item
- `<C-e>` — close the menu without accepting

**Auto-brackets**: If you accept a method completion, blink automatically adds `()` and places your cursor inside the parentheses. You can immediately start typing arguments.

**Try this**: In a Java class, type `this.` — the menu shows all fields and methods of the current class. Navigate with `<Tab>` and accept one with `<CR>`.

### Scrolling Documentation

When an item is selected, its documentation (Javadoc) appears in a side panel after 200ms. If you want to scroll that panel without closing the menu, use `<C-b>` (up) and `<C-f>` (down).

### Forcing the Menu Open

If the menu didn't appear (e.g. after a deletion), `<C-space>` forces it open at the current cursor position.

### Path Completion

Inside a string, type a `/` or `./` and the path source kicks in, showing filesystem completions. Useful for `@ConfigProperty(name = "...")` or resource paths.

### Snippets

Snippets from `friendly-snippets` appear in the completion menu alongside LSP completions — they show with a different icon. Accept them the same way. Once accepted, a snippet with placeholders lets you `<Tab>` between the placeholder positions.

**Try this**: In a Java file, type `sout` — you should see a snippet for `System.out.println()`. Accept it and it expands with the cursor inside the parentheses.

---

## Signature Help — While Typing Arguments

When you're inside a function call, in insert mode, a float shows the parameter signature. This appears automatically when you type `(`. If it disappeared:

`<C-s>` in insert mode brings it back.

```java
LocalDate.of(|           ← cursor is here, inside the call
// float shows: of(int year, int month, int dayOfMonth)
// and highlights which parameter you're currently on
```

---

## Surround — nvim-surround

Surround lets you add, change, or delete the characters that wrap a piece of text: quotes, brackets, tags, anything. The mental model is simple: `ys` adds, `cs` changes, `ds` deletes.

### Adding Surround — `ys{motion}{char}`

Think of it as "you surround {motion} with {char}":

```
Cursor on the word:  hello

ysiw"    →   "hello"         (surround inner word with double quotes)
ysiw(    →   ( hello )       (with spaces — open bracket adds spaces)
ysiw)    →   (hello)         (no spaces — close bracket, no spaces)
ysap{    →   {               (surround paragraph with braces)
             ...paragraph...
             }
yss"     →   "entire line"   (surround the whole line)
```

### Changing Surround — `cs{old}{new}`

Cursor just needs to be somewhere inside the surrounded text:

```
"hello world"   →  cs"'   →  'hello world'
(hello world)   →  cs({   →  { hello world }
"hello"         →  cs"<b> →  <b>hello</b>
```

### Deleting Surround — `ds{char}`

```
"hello"         →  ds"   →   hello
(hello)         →  ds(   →   hello
<em>hello</em>  →  dst   →   hello    (t = tag)
```

### In Visual Mode

Select text, then `S{char}` to wrap the selection:
```
V → select a line → S"   →  "the selected line"
```

**Try this**: Open a Java file. Find a method argument that's a plain string. Put your cursor on it and type `ysiw"` to wrap it in quotes. Then type `cs"'` to change to single quotes. Then `ds'` to remove them. You should end up back where you started.

---

## Comments — Comment.nvim

Comments are context-aware — the plugin uses treesitter to apply the correct comment style for the language. In a `.java` file it uses `//`. In a JSX file it uses `{/* */}` inside JSX expressions and `//` in JavaScript. You don't have to think about this.

### Line Comments

`gcc` toggles a `//` comment on the current line. Press it again to uncomment.

In **visual mode** (select lines first with `V`), `gc` toggles comments on all selected lines:
```
V → select 5 lines → gc   → all 5 lines commented
                   → gc   → all 5 lines uncommented
```

### Block Comments

`gbc` toggles a `/* */` block comment on the current line.

`gb{motion}` adds block comments over a motion:
```
gbap    →  /* ... paragraph ... */
```

### With a Count or Motion

```
gcc         toggle current line
3gcc        toggle next 3 lines
gcap        toggle comment on entire paragraph
gcG         toggle comment from cursor to end of file
```

**Try this**: In a Java method, use `V` to select 3 lines, then `gc` to comment them out. Use `gc` again on the same selection to uncomment. Then try `gcap` on a whole paragraph block.

---

## Treesitter Text Objects — Syntax-Aware Selection

Standard vim text objects (`iw`, `ip`, etc.) work with characters. Treesitter text objects understand the code's structure — they know where a function starts and ends, what's inside a class body, etc.

### Selecting Functions and Classes

```
if    inner function body (without the signature line)
af    outer function (signature + body)
ic    inner class body
ac    outer class (including the class declaration)
```

Use these with any operator:
```
daf        → delete the entire function (method declaration + body)
yif        → yank just the method body
cif        → change (replace) the method body, keeping the signature
vac        → visually select the whole class
```

**Try this**: Put your cursor anywhere inside a Java method. Press `vaf` to see what gets selected — it should highlight the entire method including its signature. Press `daf` (undo with `u` afterward) to see that it would delete the whole method.

### Navigating Between Functions

You can jump between methods in a class without knowing their names:

```
]f    → jump to the start of the next function/method
[f    → jump to the start of the previous function/method
]F    → jump to the end of the next function
[F    → jump to the end of the previous function
]c    → jump to the next class
[c    → jump to the previous class
```

**Try this**: In a Java file with multiple methods, press `]f` repeatedly to jump from method to method. Then try `daf` on one — it deletes the entire method. `u` to undo.

### Incremental Selection — Expand by Syntax Node

`<C-space>` in normal mode starts a selection at the smallest syntax node under the cursor. Each subsequent `<C-space>` expands the selection to the parent node. `<BS>` shrinks it back.

```
Cursor on a variable name
<C-space>   →  selects the identifier
<C-space>   →  expands to the expression (e.g. method call)
<C-space>   →  expands to the statement
<C-space>   →  expands to the method body
<C-space>   →  expands to the entire method
<BS>        →  shrinks back to method body
```

This is useful when you want to select "this expression" without counting characters or thinking about boundaries.

---

## Moving Lines

You can move lines up and down without cutting and pasting:

- `<A-j>` — move current line down (normal mode)
- `<A-k>` — move current line up (normal mode)
- Same keys in **insert mode** — move the line while you keep typing
- `J` / `K` in **visual mode** — move the entire selection up or down

The line is re-indented automatically when moved.

**Try this**: Put your cursor on a method in a Java class. Use `<A-j>` several times to move it down past other methods. Notice it stays properly indented.

---

## Indenting

In **visual mode** (`V` to select lines):
- `>` — indent right (adds one level of indentation)
- `<` — indent left
- The selection stays active after indenting, so you can press `>` multiple times to indent further

In **normal mode**:
- `>>` — indent current line right
- `<<` — indent current line left
- `=ap` — auto-indent the current paragraph
- `gg=G` — auto-indent the entire file

---

## Paste Without Clobbering

Normally in vim, when you paste over a selection, the deleted text replaces your register. This means you can't paste the same thing twice in a row after a visual paste.

In this config, `p` in visual mode is remapped: it pastes without touching the register. The deleted text goes to the black-hole register. Your original yank stays intact.

```
Yank: "OrderService"
→ go to another word
→ v to select it
→ p — pastes "OrderService", selected word discarded
→ go to another word
→ v → p — pastes "OrderService" again
```

This makes repetitive replacements straightforward.

---

## Undo Breakpoints

In insert mode, `,` `.` `;` each insert an undo breakpoint. This means `u` in normal mode undoes back to the last punctuation mark rather than undoing the entire insert session.

**Practical example**: You're writing a long method body. You type 4 lines, then realise line 3 was wrong. `<Esc>u` without breakpoints would undo everything you typed back to when you entered insert mode. With breakpoints, it undoes back to the last `;` or `.` — usually just the last statement.

---

## Quick Reference

```
Completion:
<C-space>       force open menu
<Tab>/<S-Tab>   next / prev item
<CR> or <C-y>   accept
<C-e>           close menu
<C-b>/<C-f>     scroll docs

Surround:
ys{m}{c}        add surround (e.g. ysiw")
cs{old}{new}    change surround (e.g. cs"')
ds{c}           delete surround (e.g. ds")
S{c}            surround visual selection

Comments:
gcc             toggle line comment
gc{motion}      comment with motion (e.g. gcap)
gbc             toggle block comment

Treesitter text objects:
if / af         function inner / outer
ic / ac         class inner / outer
]f / [f         next / prev function start
]F / [F         next / prev function end

Incremental selection:
<C-space>       expand selection
<BS>            shrink selection

Move lines:
<A-j> / <A-k>   move line down / up
J / K (visual)  move selection down / up
```
