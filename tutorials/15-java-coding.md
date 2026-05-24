# Java Coding

Day-to-day Java editing with jdtls: code actions, navigation, rename, Quarkus annotations, and the patterns that come up in every work session.

---

## The Core Habit: Reach for `gra` First

`gra` (code action) is the most powerful key in Java editing. Before typing boilerplate, check if jdtls can generate it. Before manually fixing a diagnostic, check if there's an automated fix.

The options in `gra` change based on exactly where your cursor is:

**Cursor in a class body** (not inside a method):
- Generate getters / setters (for selected fields)
- Generate constructor from fields
- Generate `toString()`, `equals()`, `hashCode()`
- Override / implement methods from parent class / interface
- Add `@SuppressWarnings`

**Cursor on an unknown type / import error**:
- Add import (picks the right one if unambiguous, shows picker if multiple)
- Organize imports (removes unused, sorts, adds missing)

**Cursor on a diagnostic marker** (error or warning):
- Context-specific fix for that exact error
- "Remove unused import", "Add cast", "Create method", etc.

**After selecting code with visual mode** (select first, then `gra`):
- Extract method: wraps selection in a new method, turns referenced local variables into parameters
- Extract variable: wraps expression in a named local variable
- Inline variable: inlines a local back to its usage

**Try this workflow**: Create a Java class with three private fields and no methods. Put your cursor anywhere in the class body (not inside a method). Press `gra`. Select "Generate getters and setters". Watch jdtls generate all of them. Undo with `u`.

---

## Navigation — Moving Through Code

### Go to Definition — `gd`

The workhorse. Put your cursor on any class, method, field, or annotation name and press `gd`. It jumps to where that symbol is defined.

```java
@Inject
private OrderRepository repository;
            ↑ cursor here → gd → opens OrderRepository.java at the interface declaration
```

Then `<C-o>` to jump back. Chain multiple `gd` jumps (go to definition, then go to a type that uses, etc.) and unwind them all with repeated `<C-o>`.

### Go to Implementation — `gri`

When your cursor is on an interface or abstract method, `gri` shows all concrete implementations.

```java
public interface OrderRepository {
    Order save(Order order);
    ↑ cursor here → gri → picker shows: JpaOrderRepository, MockOrderRepository
    →  choose one → jumps to that implementation
}
```

This is the fastest way to navigate from an injected interface to the actual running code.

### Find All References — `grr`

Shows every place in the project where the symbol under the cursor is used. Opens in the Snacks picker.

```java
public void processOrder(Order order) {
                ↑ cursor anywhere on processOrder → grr
→ picker shows:
  OrderController.java:45  service.processOrder(order)
  OrderBatch.java:23       processor.processOrder(batch.next())
  OrderServiceTest.java:67  service.processOrder(mockOrder)
```

Use `grr` before renaming a method (to understand the impact) or before modifying a method signature (to find all callers that need updating).

### Workspace Symbols — `<leader>ss`

Searches by name across the entire project — classes, methods, fields, enums, constants.

```
<leader>ss
Type: OrderDto
→ finds class definition, constructor, all usages as a type
→ <CR> to jump
```

Use this when you know the name of something but don't have a file open that references it.

---

## Rename — `grn`

`grn` renames the symbol under the cursor across every file in the project. It uses AST-level analysis, so it only renames actual usages — not string literals that happen to match.

```java
// Cursor on "processOrder" in the method declaration
public void processOrder(Order order) { ... }
↑ press grn
→ input box appears pre-filled with "processOrder"
→ type "handleOrder" → <CR>
→ jdtls renames: the declaration, all call sites, test references
```

**Practice first on a local variable** — low risk, undo with `u`. Once you're confident it works correctly, use it on public methods and classes.

**Renaming a file** (updates the class name and all imports): `<leader>cR`

---

## Inlay Hints

Inlay hints show parameter names and inferred types inline. They're on by default. Toggle with `<leader>ih`.

```java
// With inlay hints off:
createOrder("prod-123", 5, true, Priority.HIGH);

// With inlay hints on:
createOrder(productId: "prod-123", quantity: 5, notify: true, priority: Priority.HIGH);
```

Inlay hints are most valuable for methods you didn't write — they make the argument intent clear without having to hover over each parameter. They can feel noisy once you know the code well — toggle them off with `<leader>ih` when needed.

---

## Quarkus Annotations — CDI (Dependency Injection)

### Bean Scopes

| Annotation | When to use |
|------------|-------------|
| `@ApplicationScoped` | Services that are stateless or hold shared state — one instance for the app's lifetime. Most common. |
| `@RequestScoped` | Beans that need a fresh instance per HTTP request (e.g. request context holders). |
| `@Singleton` | Like `@ApplicationScoped` but without the CDI proxy. Slightly faster, but can't be overridden for testing. |

### Injection

```java
@ApplicationScoped
public class OrderService {

    @Inject
    OrderRepository repository;     // field injection

    @Inject
    PaymentService paymentService;  // jdtls shows completions for all injectable beans

    // Constructor injection (preferred with Lombok)
    @RequiredArgsConstructor
    // → generates constructor, CDI uses it automatically
}
```

**Tip**: When you type `@Inject` and press `<CR>` to start the next line, blink.cmp shows completions for all injectable beans registered in the CDI context. This is one of the most useful completions jdtls provides.

### When You Have Multiple Implementations

```java
public interface NotificationService { ... }

@ApplicationScoped
@Named("email")
public class EmailNotificationService implements NotificationService { ... }

@ApplicationScoped
@Named("sms")
public class SmsNotificationService implements NotificationService { ... }

// Inject by name:
@Inject
@Named("email")
NotificationService notifier;
```

---

## Quarkus Annotations — REST Endpoints

```java
@Path("/api/v1/orders")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@ApplicationScoped
public class OrderResource {

    @GET
    public List<OrderDto> getAll() { ... }

    @GET
    @Path("/{id}")
    public Response getById(@PathParam("id") Long id) { ... }

    @POST
    public Response create(@Valid OrderRequest request) { ... }

    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") Long id, OrderRequest request) { ... }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) { ... }

    @GET
    @Path("/search")
    public List<OrderDto> search(@QueryParam("status") String status,
                                 @QueryParam("page") @DefaultValue("0") int page) { ... }
}
```

jdtls understands these annotations — `gd` on `@Valid` takes you to the Bean Validation annotation, `grr` on `@PathParam("id")` finds all usages.

---

## Working with Interfaces — The Full Pattern

When you have an interface, here's the navigation cycle:

1. **Reading the interface**: `gO` shows all method declarations in the current file
2. **Finding implementations**: `gri` on the interface name or a method
3. **Finding callers**: `grr` on any method to see call sites
4. **Generating implementations**: In an implementing class, `gra` → "Override / Implement methods" → pick which ones

**Try this**: Create an interface with two methods. Create a class that `implements` it. In the class, press `gra` → "Override / Implement Methods". Select both methods. jdtls generates the method stubs.

---

## Import Management

jdtls handles imports automatically in most cases:
- **Accept a completion** → import is added automatically
- **Type a class name** → a diagnostic appears → `gra` → "Add import"
- **Organize everything** → `gra` → "Organize Imports" (removes unused, sorts, adds missing)

The import fold auto-closes on file open. If you need to check imports: `za` on the import line to toggle the fold.

**Watch for duplicate imports**: If you see "The import X is never used", move to that line with `]d` and press `gra` → "Remove unused import".

---

## Diagnostics in Practice

The typical response to a red underline:

1. `]d` to navigate to it (or just move your cursor there)
2. `K` to read the full error message in a float (sometimes the virtual text is truncated)
3. `gra` to see if there's an automated fix
4. If no automated fix: fix it manually based on what `K` told you

**`<leader>sd`** when you want the big picture — all errors across the workspace in a searchable list. After a large refactor (like renaming a class), this shows you everything that broke.
