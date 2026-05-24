# Tags & Releases

Tags mark specific commits as significant — usually a release. For Maven projects, tags align with the version in `pom.xml`. This chapter covers creating, pushing, and managing tags in lazygit, and a simple release flow without the maven-release-plugin.

---

## What Tags Are

A tag is a named pointer to a specific commit. Unlike a branch, it doesn't move — once you tag commit `abc123` as `v1.4.0`, that tag always points to `abc123`.

There are two kinds:
- **Lightweight**: just a name, like a sticky note on the commit
- **Annotated**: has a message, author, and date — treated as a full object in git. This is the standard for releases.

**Always use annotated tags for releases** — they carry meaningful metadata and show up properly in `git log --tags`.

---

## Creating a Tag in lazygit

Open lazygit (`<leader>gg`) and go to the **Commits panel** (`4`). Navigate to the commit you want to tag — usually the last commit on `main` after a version bump.

```
4               → Commits panel
j / k           → navigate to the release commit
T               → create annotated tag (capital T — use this one)
```

lazygit prompts for:
1. **Tag name**: `v1.4.0`
2. **Tag message**: `Release 1.4.0 — payment validation and performance improvements`

Press `<CR>` after each. The tag appears in the commit list.

(`t` lowercase creates a lightweight tag — avoid for releases.)

---

## Aligning Tags with Maven Versions

The convention for Maven projects:

```
pom.xml <version>: 1.4.0-SNAPSHOT   ← development
pom.xml <version>: 1.4.0            ← release (remove -SNAPSHOT)
git tag:           v1.4.0           ← tag the release commit
```

The tag name is `v` + the Maven version with `-SNAPSHOT` removed.

---

## The Release Flow

A complete release from branch to tag:

### 1. Merge and prepare

Ensure your release branch is merged into `main` and the CI is green.

### 2. Bump the version in pom.xml

Remove `-SNAPSHOT` from the `<version>` element:

```xml
<!-- Before -->
<version>1.4.0-SNAPSHOT</version>

<!-- After -->
<version>1.4.0</version>
```

If it's a multi-module project, update the parent pom and all child pom versions. You can use the Maven versions plugin:

```bash
mvn versions:set -DnewVersion=1.4.0
```

### 3. Commit the version bump

```bash
git cm "chore: release 1.4.0"
```

### 4. Tag the release commit

In lazygit: Commits panel → navigate to the version bump commit → `T` → `v1.4.0` → message → `<CR>`.

### 5. Bump to next SNAPSHOT

```xml
<version>1.5.0-SNAPSHOT</version>
```

```bash
mvn versions:set -DnewVersion=1.5.0-SNAPSHOT
git cm "chore: bump to 1.5.0-SNAPSHOT"
```

### 6. Push everything

```bash
git push                    # push the commits
git push origin v1.4.0      # push the specific tag
```

Or in lazygit: `P` to push commits, then in the Tags section `P` to push the tag.

---

## Pushing Tags

**Push a specific tag** (recommended — don't push accidental scratch tags):
```bash
git push origin v1.4.0
```

**Push all tags** (use carefully — pushes everything, including any test tags):
```bash
git push --tags
```

In lazygit: navigate to the Tags section (visible in the Status panel) and press `P` on the tag you want to push.

---

## Viewing Tags

```bash
git tag                        # list all tags
git tag -l "v1.*"              # filter
git show v1.4.0                # show tag details + the commit it points to
git log --tags --oneline       # commits with their tags
git log --oneline v1.3.0..v1.4.0  # commits between two releases
```

The last command is useful for generating release notes: it shows exactly what went into this version.

---

## Checking Out a Tag

To inspect or build a specific past release:

```
In lazygit: navigate to the tag → space to checkout
```

This puts you in **detached HEAD** state — you're not on any branch. You can look around and build, but don't commit here. If you need to make changes (e.g. for a hotfix on an old release), create a branch first:

```bash
git checkout -b hotfix/1.3.1 v1.3.0
```

Now you're on a proper branch based on the `v1.3.0` release.

---

## Deleting Tags

If you created a tag by mistake or need to move it to a different commit (you can't move a tag — you have to delete and recreate):

**Delete local tag**:
```bash
git tag -d v1.4.0
```
Or in lazygit: navigate to the tag in the Tags section → `d`.

**Delete remote tag**:
```bash
git push origin --delete v1.4.0
```

Do both to fully remove it. Then recreate on the correct commit.
