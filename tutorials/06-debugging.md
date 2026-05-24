# Debugging — nvim-dap

This chapter walks through debugging Java/Quarkus applications from inside neovim. The DAP (Debug Adapter Protocol) setup gives you the same capabilities as an IDE debugger: breakpoints, step-by-step execution, variable inspection, and an interactive REPL.

For Quarkus, the most common scenario is attaching to a running dev mode instance — no special launch configuration needed, just connect to port 5005.

---

## The DAP UI

When a debug session starts, the DAP UI opens automatically and rearranges the screen into panels:

```
┌─────────────────────┬──────────────────────────────────┐
│  Scopes             │                                  │
│  (local variables)  │    Your code (editor)            │
│                     │    ← breakpoints shown here      │
├─────────────────────┤                                  │
│  Breakpoints        │                                  │
│  (all set bps)      │                                  │
├─────────────────────┼──────────────────────────────────┤
│  Call Stack         │  REPL / Console                  │
│  (call hierarchy)   │  (output + interactive eval)     │
└─────────────────────┴──────────────────────────────────┘
```

- **Scopes**: All local variables and their current values in the active stack frame
- **Breakpoints**: Every breakpoint you've set across all files — click one to jump to it
- **Call Stack**: The chain of function calls that led to the current pause point. Click a frame to jump there and see its local variables
- **REPL**: Type any Java expression to evaluate it against the running state
- **Console**: Output from `System.out.println()` and your logger

Toggle the whole UI with `<leader>du` if it's in the way.

---

## Step 1 — Start Quarkus Dev Mode

Quarkus dev mode opens debug port 5005 automatically. You don't need any extra flags:

```
<C-/>           open terminal
mvn quarkus:dev  start dev mode
<Esc><Esc>      exit terminal mode
<C-/>           hide terminal
```

Wait for Quarkus to print `Listening for transport dt_socket at address: 5005` in the output. From that point on, a debugger can attach.

---

## Step 2 — Set Breakpoints

Navigate to the line where you want execution to pause and press `<F9>` to set a breakpoint. A coloured marker appears in the sign column on the left.

```
You want to inspect what's happening in your order endpoint:

@POST
@Path("/orders")
public Response createOrder(OrderRequest request) {
    OrderDto dto = mapper.toDto(request);         ← set breakpoint here
    Order saved = orderService.save(dto);
    return Response.ok(saved).build();
}

Press <F9> on the mapper.toDto line.
A ● marker appears in the gutter.
```

You can set multiple breakpoints across different files before attaching — they'll all be respected once the session is active.

**Remove a breakpoint**: Press `<F9>` again on the same line — it toggles.

---

## Step 3 — Attach the Debugger

Press `<F5>`. A picker appears showing available debug configurations. Select **"Debug (Attach) - Remote"** and press `<CR>`.

```
<F5>
→ picker shows:
  > Debug (Attach) - Remote
    Launch <ClassName> (auto-detected main classes)
→ select "Debug (Attach) - Remote"
→ DAP connects to 127.0.0.1:5005
→ DAP UI opens with the panels
```

The DAP UI opens. Your debug session is now live.

---

## Step 4 — Trigger the Code Path

The debugger is paused waiting. Now do something that will execute the code path containing your breakpoint. Send an HTTP request to your endpoint:

```bash
# In the terminal:
curl -s -X POST localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"productId":"abc","quantity":2}' | jq .
```

The moment execution reaches your breakpoint, neovim highlights that line and the Scopes panel fills with local variables. You're now in control.

---

## Step 5 — Stepping Through Code

| Key | What it does |
|-----|-------------|
| `<F10>` | **Step over** — execute the current line, stay at the same level. Does not enter the method being called. |
| `<F11>` | **Step into** — if the current line calls a method, enter that method and pause at its first line. |
| `<F12>` | **Step out** — finish executing the current method and pause at the line that called it. |
| `<F5>` | **Continue** — run until the next breakpoint or the request completes. |
| `<leader>dC` | **Run to cursor** — continue execution until it reaches the line your cursor is on (no breakpoint needed). |

**The typical step-over loop**: `<F10>` to advance one statement at a time, watching how variables change in the Scopes panel. `<F11>` when you want to descend into a specific method call. `<F12>` when you've seen enough of the current method and want to return.

---

## Inspecting Variables

### Scopes Panel

While paused, the Scopes panel on the left shows all local variables. Each variable shows its type and current value. Objects can be expanded with `<CR>` to see their fields.

### Hover Inspection

Put your cursor on any variable in the source code and press `<leader>de` — a floating window appears showing its current value.

```
Order saved = orderService.save(dto);
              ↑ cursor here
<leader>de
→ float shows: Order { id: null, productId: "abc", quantity: 2, status: PENDING }
```

This is quicker than finding the variable in the Scopes panel when you just want a quick look.

### The REPL

`<leader>dr` opens the REPL. You can type any valid Java expression and it evaluates against the current state:

```
> request.getProductId()
"abc"
> orderService.getClass().getSimpleName()
"OrderServiceImpl"
> dto.getQuantity() * 2
4
> dto.setQuantity(10)   // you can even mutate state
```

The REPL is powerful for hypothesis testing: "what would happen if this variable were different?" — evaluate it without modifying the source.

---

## Conditional Breakpoints

Sometimes you only want to pause on a specific condition — e.g. only when processing a particular product ID, or only on the 100th iteration of a loop.

Press `<leader>dB` instead of `<F9>`. A prompt appears asking for the condition:

```
<leader>dB  on the line inside a loop
→ prompt: "Breakpoint condition:"
→ type:    i == 99
→ <CR>
```

The breakpoint marker in the gutter looks slightly different (usually a different colour). Execution only pauses there when `i == 99` is true — all other iterations run at full speed.

**Examples**:
```java
// Only pause for a specific user
request.getUserId().equals("problematic-user-id")

// Only pause when a condition is met
result == null

// Only pause on a specific HTTP path
request.getPath().contains("/admin")
```

---

## Working With the Call Stack

When execution is paused, the Call Stack panel shows the full chain of calls that led to the current position. This includes your code, CDI interceptors, Quarkus framework code — everything.

Click on any frame in the call stack to jump to that position in the source and see that frame's local variables in the Scopes panel. This is how you answer "how did I get here?" — work up the call stack to find where the wrong data originated.

---

## Terminating the Session

`<leader>dt` terminates the debug session. Quarkus keeps running — you're just detaching the debugger. The next `<F5>` will re-attach.

`<leader>du` toggles the DAP UI panels if you want to reclaim screen space. The session stays active.

---

## Suspend on Start (Boot-time Bugs)

If the bug happens during application startup (e.g. in a `@PostConstruct` method or during CDI bean initialisation):

```bash
# In the terminal:
mvn quarkus:dev -Dsuspend
```

Quarkus boots but pauses before initialising anything, waiting for a debugger to attach. Connect with `<F5>` → Attach Remote, then `<F5>` again to continue. Set your breakpoints before connecting.

---

## Quick Reference

```
<F9>            toggle breakpoint
<leader>dB      conditional breakpoint
<F5>            start / continue
<F10>           step over
<F11>           step into
<F12>           step out
<leader>dC      run to cursor
<leader>dt      terminate session
<leader>du      toggle DAP UI panels
<leader>de      evaluate expression under cursor
<leader>dr      toggle REPL
```
