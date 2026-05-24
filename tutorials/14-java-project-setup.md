# Java Project Setup

This chapter covers the workflow from cloning a repo to a fully working LSP session — how jdtls attaches, what to do when it doesn't, and how multi-module Maven projects are handled.

---

## Cloning and Opening a Project

All repos live under `~/Developer/<host>/<org>/<repo>`. The `ghq` tool handles placement:

```bash
# Work repo on Forgejo
ghq get forgejo.mintifi.com/org/order-service
# → cloned to ~/Developer/forgejo.mintifi.com/org/order-service

# Personal repo
ghq get github.com/craftyprash/my-tool
# → cloned to ~/Developer/github.com/craftyprash/my-tool
```

After cloning, navigate with zoxide and open neovim:

```bash
z order-service    # zoxide jumps to ~/Developer/forgejo.mintifi.com/org/order-service
nvim .
```

The `smart_cwd` autocmd detects the `.git` directory and sets neovim's CWD to the project root automatically. The dashboard appears on startup — press `f` to find a file, or just open a `.java` file directly with `<leader>ff`.

---

## jdtls Auto-Attach

jdtls starts in the background as soon as you open any `.java` file. It looks for a project root by searching ancestor directories for:
1. `.git`
2. `mvnw` (Maven wrapper)
3. `gradlew` (Gradle wrapper)

Once it finds the root, it starts indexing. **Watch the statusline** — it shows `[jdtls]` once the server has attached and is ready. On first open this takes 30–60 seconds. On subsequent opens the workspace is cached and it's near-instant.

**You can keep editing while jdtls loads** — completions and diagnostics start appearing as they become available.

---

## Multi-Module Maven Projects

A typical Quarkus multi-module structure:

```
order-service/           ← project root (has .git and pom.xml)
├── pom.xml              ← parent POM
├── order-api/
│   ├── pom.xml          ← module POM
│   └── src/main/java/
├── order-core/
│   ├── pom.xml
│   └── src/main/java/
└── order-infrastructure/
    ├── pom.xml
    └── src/main/java/
```

jdtls reads the parent `pom.xml`, discovers all modules, and provides cross-module navigation. You can `gd` from a class in `order-api` to a type defined in `order-core` — even though they're in different Maven modules.

**Each project gets an isolated workspace**:
```
~/.local/share/jdtls-workspace/<sanitised-project-path>/
```
The path is derived from the project root. Two projects with the same module names won't interfere with each other.

---

## Java Runtime — mise

Your Java version is managed by `mise`. The jdtls config reads `mise where java` at startup to find the JDK path — no manual configuration needed.

```bash
mise current java           # what version is active in CWD
mise use java@21            # pin Java 21 for this project (creates .mise.toml)
mise use --global java@21   # set as default for all projects
```

If you have a `.mise.toml` or `.tool-versions` file in the project directory, `mise` activates the right version automatically when you `cd` there.

If jdtls fails to start, check that `mise where java` returns a valid JDK path:
```bash
mise where java    # should print something like /Users/.../java-21.0.5-...
```

---

## Lombok

Lombok is configured via javaagent in Mason's jdtls installation. It works out of the box — you don't need to install anything separately or configure the project.

These annotations all work without any setup:

```java
@Data               // getters, setters, equals, hashCode, toString
@Value              // immutable variant of @Data
@Builder            // builder pattern
@Getter / @Setter   // selective getters/setters
@Slf4j              // adds private static final Logger log = ...
@RequiredArgsConstructor  // constructor for final fields
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
@ToString
@SneakyThrows       // checked exceptions without try/catch
```

**If Lombok annotations show errors**: check that jdtls is installed in Mason (`<leader>cm`) and that `lombok.jar` exists at `~/.local/share/nvim/mason/packages/jdtls/lombok.jar`.

---

## Import Fold

Java files have a custom autocmd that automatically folds the import block when jdtls provides fold information. The fold closes within the first few seconds of opening the file.

- **Expand imports**: `za` with cursor on the import line (or anywhere in the fold)
- **See all folds**: `zR` to open all folds in the file
- **Close everything**: `zM` to close all folds

This keeps the file clean — you don't need to scroll past 30 import lines to get to the class body.

---

## Verifying the Setup

After opening a Java file, check these to confirm LSP is working:

1. **Statusline shows `[jdtls]`** — server has attached
2. **`gd` on a class name** — should jump to its definition (even into library sources)
3. **`K` on a method** — should show Javadoc in a float
4. **`gra` anywhere in a class body** — should show Java-specific code actions (generate getters, etc.)
5. **`<leader>sd`** — workspace diagnostics should be empty (or show real issues)

If `gd` and `K` work, the setup is healthy.

---

## Troubleshooting

| Symptom | Cause and fix |
|---------|---------------|
| No `[jdtls]` in statusline after 60s | Project root not detected. Run `:LspInfo` — check if "root_dir" is shown. Ensure `.git` or `mvnw` exists at the actual project root. |
| `:LspInfo` shows "No clients" | The FileType autocmd didn't fire, or root detection failed. Try `:e` to reload the buffer, or open a different `.java` file. |
| Completions work but no Javadoc (`K` shows nothing) | Maven sources not downloaded. Run `mvn dependency:resolve -Dclassifier=sources`. |
| Lombok annotations show red underlines | `lombok.jar` missing from Mason's jdtls package. Reinstall jdtls in Mason (`<leader>cm` → find jdtls → `i`). |
| jdtls is slow every time (no caching) | Workspace directory might be wrong. Check `~/.local/share/jdtls-workspace/` — there should be a folder for your project. |
| Stale workspace (wrong completions, old type info) | Delete the project's workspace: `rm -rf ~/.local/share/jdtls-workspace/<your-project>/` then reopen. |
| Wrong Java version errors | Run `mise where java` to check the path. If wrong: `mise use java@21` in the project dir. |

```vim
" Useful diagnostic commands:
:LspInfo           " attached clients, root dir, buffer info
:LspLog            " jdtls server log (errors, warnings from the server)
:checkhealth lsp   " full LSP health check
```
