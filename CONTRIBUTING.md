# Contributing Guide

Guidelines for maintaining and contributing to this Neovim configuration.

## Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated changelog generation.

### Commit Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Commit Types

| Type | Description | Changelog Section |
|------|-------------|-------------------|
| `feat` | New feature | Features |
| `fix` | Bug fix | Bug Fixes |
| `docs` | Documentation changes | Documentation |
| `style` | Code style (formatting, no logic change) | Styling |
| `refactor` | Code refactoring | Refactor |
| `perf` | Performance improvements | Performance |
| `test` | Adding/updating tests | Testing |
| `chore` | Maintenance (dependencies, config) | Miscellaneous |

### Commit Examples

```bash
# Adding a new feature
git commit -m "feat: add Python LSP support with pyright"

# Fixing a bug
git commit -m "fix: correct Oil.nvim cwd detection for nested directories"

# Documentation update
git commit -m "docs: update LSP.md with Python debugging setup"

# Refactoring code
git commit -m "refactor: simplify autocmd logic in config/autocmds.lua"

# Updating dependencies
git commit -m "chore: update lazy-lock.json"

# With scope
git commit -m "feat(lsp): add inlay hints for Python"
git commit -m "fix(debug): resolve breakpoint sync issue in Rust"

# With body
git commit -m "feat: add markdown preview plugin

- Integrates render-markdown.nvim
- Auto-renders on markdown file open
- Configurable heading styles"
```

### Breaking Changes

For breaking changes, add `!` after type or add `BREAKING CHANGE:` in footer:

```bash
git commit -m "feat!: change default leader key to space"

# Or
git commit -m "refactor: restructure plugin directory

BREAKING CHANGE: Plugins moved from lua/plugins/ to lua/config/plugins/"
```

## Development Workflow

### 1. Making Changes

```bash
# Create a branch (optional)
git checkout -b feature/add-python-support

# Make your changes
nvim lua/plugins/lsp-lang.lua

# Stage and commit with conventional format
git add lua/plugins/lsp-lang.lua
git commit -m "feat: add Python LSP support"

# Continue making changes
git commit -m "docs: update LSP.md with Python setup"
git commit -m "chore: add pyright to Mason auto-install"
```

### 2. Testing Changes

```bash
# Test the configuration
nvim

# Check health
:checkhealth
:checkhealth lsp

# Verify LSP
:LspInfo
:Mason

# Test formatting
:ConformInfo
```

### 3. Generating Changelog

When ready for a new release:

```bash
# Generate changelog for next version
git-cliff --tag v0.0.2 -o CHANGELOG.md

# Review the generated changelog
cat CHANGELOG.md

# Commit the changelog
git add CHANGELOG.md
git commit -m "chore(release): prepare for v0.0.2"
```

### 4. Creating a Release

```bash
# Create an annotated tag
git tag -a v0.0.2 -m "Release v0.0.2

Highlights:
- Added Python LSP support
- Fixed Oil.nvim cwd detection
- Updated documentation"

# Verify the tag
git tag -l -n9 v0.0.2

# Push to remote (if applicable)
git push origin main --tags
```

## Changelog Management

### Automatic Generation

The project uses [git-cliff](https://git-cliff.org/) for automatic changelog generation from conventional commits.

**Configuration**: `cliff.toml`

**Generate changelog**:
```bash
# For next release
git-cliff --tag v0.0.2 -o CHANGELOG.md

# Preview without writing
git-cliff --tag v0.0.2

# Generate for specific range
git-cliff v0.0.1..HEAD -o CHANGELOG.md
```

### Manual Updates

For major releases or special notes, you can manually edit `CHANGELOG.md`:

1. Generate with git-cliff
2. Edit to add additional context
3. Commit the changes

## Release Process

### Semantic Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (v1.0.0): Breaking changes
- **MINOR** (v0.1.0): New features (backward compatible)
- **PATCH** (v0.0.1): Bug fixes (backward compatible)

### Release Checklist

1. **Ensure all changes are committed**
   ```bash
   git status
   ```

2. **Update version references** (if any in docs)
   ```bash
   # Check README.md, LSP.md for version mentions
   ```

3. **Generate changelog**
   ```bash
   git-cliff --tag v0.1.0 -o CHANGELOG.md
   ```

4. **Review changelog**
   ```bash
   cat CHANGELOG.md
   # Verify all changes are captured correctly
   ```

5. **Commit changelog**
   ```bash
   git add CHANGELOG.md
   git commit -m "chore(release): prepare for v0.1.0"
   ```

6. **Create tag**
   ```bash
   git tag -a v0.1.0 -m "Release v0.1.0

   See CHANGELOG.md for details."
   ```

7. **Push to remote** (if applicable)
   ```bash
   git push origin main --tags
   ```

## Publishing to Remote

### Initial Setup

```bash
# Add remote repository
git remote add origin git@github.com:username/nvim-config.git

# Verify remote
git remote -v
```

### Push Changes

```bash
# Push main branch
git push origin main

# Push all tags
git push origin --tags

# Or push specific tag
git push origin v0.1.0
```

### GitHub Release (Optional)

After pushing tags, create a GitHub release:

1. Go to repository → Releases → Draft a new release
2. Select the tag (e.g., v0.1.0)
3. Copy content from CHANGELOG.md for that version
4. Publish release

## Code Style

### Lua Formatting

This project uses [stylua](https://github.com/JohnnyMorganz/StyLua) for Lua formatting.

**Configuration**: `stylua.toml`
- Indent: 2 spaces
- Quote style: Double quotes (auto-prefer)
- Line width: 120 characters

**Format files**:
```bash
# Format all Lua files
stylua .

# Check formatting
stylua --check .

# Format specific file
stylua lua/plugins/lsp-lang.lua
```

**VSCode**: Install StyLua extension for format-on-save

### Commit Message Style

- Use present tense: "add feature" not "added feature"
- Use imperative mood: "move cursor to..." not "moves cursor to..."
- First line should be concise (50 chars or less)
- Capitalize first letter
- No period at the end of subject line

**Good**:
```
feat: add Python LSP support
fix: correct cwd detection in Oil.nvim
docs: update keybindings reference
```

**Bad**:
```
Added python support.
Fixed a bug
updated docs
```

## File Organization

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua        # Plugin manager
│   │   ├── options.lua     # Editor settings
│   │   ├── keymaps.lua     # Global keybindings
│   │   └── autocmds.lua    # Auto-commands
│   └── plugins/
│       ├── lsp-lang.lua    # LSP configuration
│       ├── debug.lua       # Debugging setup
│       ├── completion.lua  # Completion engine
│       └── ...             # Other plugins
├── CHANGELOG.md            # Auto-generated changelog
├── CONTRIBUTING.md         # This file
├── README.md               # Main documentation
├── LSP.md                  # LSP & debug guide
├── KEYBINDINGS.md          # Keybinding reference
├── cliff.toml              # Changelog config
└── stylua.toml             # Lua formatter config
```

## Adding New Features

### Adding a Language

1. **Update LSP config** (`lua/plugins/lsp-lang.lua`)
2. **Add formatter** (`lua/plugins/formatting.lua`)
3. **Add to Mason** (ensure_installed list)
4. **Update documentation** (LSP.md)
5. **Commit with conventional format**:
   ```bash
   git commit -m "feat: add Python LSP support with pyright and black"
   ```

### Adding a Plugin

1. **Create plugin spec** in `lua/plugins/`
2. **Configure keybindings** (if needed)
3. **Update documentation** (README.md, KEYBINDINGS.md)
4. **Test thoroughly**
5. **Commit**:
   ```bash
   git commit -m "feat: add telescope.nvim for fuzzy finding"
   ```

## Questions or Issues?

- Check existing documentation (README.md, LSP.md, KEYBINDINGS.md)
- Review git history for examples: `git log --oneline`
- Test in a separate branch before committing to main

## Tools Required

- **Neovim 0.12+**: Editor
- **git**: Version control
- **git-cliff**: Changelog generation (`cargo install git-cliff`)
- **stylua**: Lua formatting (`cargo install stylua` or via Mason)
- **ripgrep**: For grep picker (`brew install ripgrep`)
- **fd**: For file picker (`brew install fd`)
- **lazygit**: Git UI (`brew install lazygit`)

## License

MIT - See LICENSE file for details.
