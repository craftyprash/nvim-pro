# Quarkus Dev Workflow

The day-to-day cycle of running, editing, and testing a Quarkus application inside neovim. The goal is a tight feedback loop: save a file, see the result in seconds, without leaving your editor.

---

## Starting Dev Mode

Open the floating terminal and start Quarkus:

```
<C-/>              open terminal
mvn quarkus:dev    start dev mode
```

Wait for the startup log to finish — you'll see something like:
```
Listening for transport dt_socket at address: 5005
__  ____  __  _____   ___  __ ____  ______
...
Quarkus x.y.z started in 2.456s
```

Once you see the startup banner, the app is running. From this point:

```
<Esc><Esc>    exit terminal mode → back to editing
<C-/>         hide the terminal (Quarkus keeps running)
```

You're now in your editor with a live Quarkus instance running in the background.

---

## The Hot Reload Loop

Quarkus dev mode watches your source files for changes and recompiles on save. The cycle:

1. **Edit your code** in neovim — work normally
2. **`<C-s>`** to save — triggers Quarkus hot reload
3. Quarkus recompiles in ~1–2 seconds (for small changes)
4. **Test your endpoint** — curl, browser, or Postman
5. Repeat

```
# Step 4 from the terminal:
<C-/>
curl -s localhost:8080/api/orders | jq .
# or
curl -s -X POST localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"productId":"abc","quantity":2}' | jq .
<C-/>    # hide terminal again
```

**Compilation errors**: If your save introduces a compile error, Quarkus reports it in the terminal output **and** jdtls reports it as an LSP diagnostic. You'll see `●` inline in the buffer. Fix the error and save again — Quarkus recovers and reloads.

**Try this**: Make a trivial change in a REST endpoint method (e.g. change the response message). Save with `<C-s>`. Toggle the terminal with `<C-/>` and watch Quarkus recompile. Run the endpoint with `curl` and see the change.

---

## Monitoring Errors While Editing

You have two sources of error feedback:

**LSP diagnostics (as you type)**:
- `●` virtual text inline on the error line
- `[d / ]d` to navigate between errors in the current file
- `<leader>sd` for all errors across the whole workspace

**Quarkus terminal output (on save)**:
- Stack traces, CDI injection failures, deployment errors
- `<C-/>` to toggle the terminal and read the full output

LSP catches most compile errors as you type. But CDI issues (ambiguous beans, missing `@ApplicationScoped`, injection failures) only appear at runtime — you'll see those in the terminal, not in LSP.

---

## Attaching the Debugger

Quarkus dev mode opens debug port 5005 by default. You don't need any extra flags — the port is always listening.

**Attach the debugger**:
1. Set breakpoints with `<F9>` on the lines you want to pause
2. Press `<F5>` → select "Debug (Attach) - Remote" → `<CR>`
3. Hit the endpoint that exercises your breakpoint
4. Execution pauses, DAP UI opens

See chapter 06 for the full debugging workflow.

**Suspend on startup** (for boot-time issues):
```bash
mvn quarkus:dev -Dsuspend
```
Quarkus pauses before initialising. Connect with `<F5>` first, then it continues booting.

---

## Common Maven Commands

Run these in the floating terminal (`<C-/>`):

### Development

```bash
mvn quarkus:dev                              # hot reload + debug port 5005
mvn quarkus:dev -Dquarkus.profile=local      # with local profile
mvn quarkus:dev -Dquarkus.http.port=8081     # on a different port
mvn quarkus:dev -Dsuspend                    # pause at startup for debugger
```

### Testing

```bash
mvn test                                     # all tests
mvn test -Dtest=OrderServiceTest             # specific test class
mvn test -Dtest=OrderServiceTest#createOrder # specific test method
mvn test -pl order-core/                     # specific module only
mvn verify                                   # tests + integration tests
```

### Building

```bash
mvn package -DskipTests                      # fast jar build
mvn clean package                            # clean build
mvn package -Pnative                         # native binary (slow, needs GraalVM)
```

### Dependencies and Version

```bash
mvn dependency:tree                          # inspect dependency graph
mvn dependency:resolve -Dclassifier=sources  # download sources for jar navigation
mvn versions:display-dependency-updates      # check for newer versions
mvn versions:set -DnewVersion=1.5.0          # set version across all poms
mvn versions:set -DnewVersion=1.5.0-SNAPSHOT # bump to next snapshot
```

---

## Application Profiles

Quarkus uses profile prefixes in `application.properties` to switch between environments:

```properties
# application.properties

# Applies to all profiles
quarkus.http.port=8080

# Only active in dev mode (mvn quarkus:dev)
%dev.quarkus.log.level=DEBUG
%dev.quarkus.datasource.db-kind=h2
%dev.quarkus.datasource.jdbc.url=jdbc:h2:mem:testdb

# Only active during tests
%test.quarkus.datasource.db-kind=h2

# Only active in production build
%prod.quarkus.datasource.jdbc.url=${DB_URL}
%prod.quarkus.datasource.username=${DB_USER}
```

Activate a custom profile:
```bash
mvn quarkus:dev -Dquarkus.profile=local
```

Create `application-local.properties` for local-only overrides (add it to `.gitignore` — it shouldn't be committed).

---

## The Dev UI

While dev mode is running, the Dev UI is available at:
```
http://localhost:8080/q/dev
```

Useful panels:
- **Configuration** — all active configuration values, showing which properties file each came from
- **Extensions** — every Quarkus extension loaded, with links to their docs
- **Health** — readiness and liveness endpoint results
- **Swagger UI** — `http://localhost:8080/q/swagger-ui` — interactive API documentation, try endpoints from the browser

---

## Testing Endpoints from the Terminal

The floating terminal is your curl interface. Useful patterns:

```bash
# GET with formatted JSON output
curl -s localhost:8080/api/orders | jq .

# GET with auth header
curl -s -H "Authorization: Bearer $TOKEN" localhost:8080/api/orders | jq .

# POST with JSON body
curl -s -X POST localhost:8080/api/orders \
  -H 'Content-Type: application/json' \
  -d '{"productId":"abc-123","quantity":2}' | jq .

# PUT
curl -s -X PUT localhost:8080/api/orders/42 \
  -H 'Content-Type: application/json' \
  -d '{"quantity":5}' | jq .

# Show HTTP status code
curl -s -o /dev/null -w "%{http_code}" localhost:8080/api/orders/999

# View response headers
curl -si localhost:8080/api/orders | head -20
```

`jq` is already on your PATH and formats JSON responses for readability.

---

## Multi-Module Dev Mode

For multi-module projects, `mvn quarkus:dev` should be run from the module that contains the Quarkus application (the one with the `quarkus-maven-plugin` configured in its `pom.xml`), not the root:

```bash
cd order-api/   # the application module
mvn quarkus:dev
```

Or from the root with the module flag:
```bash
mvn quarkus:dev -pl order-api
```
