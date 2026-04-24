---
title: git
layout: default
parent: Standard Library
nav_order: 2
---

# git

Git command helpers for orchestration-heavy workflows.

```seagrass
import git
```

## Functions

### `git.clone(repo)`

Clone a repository into the current working directory.

```seagrass
git.clone("https://github.com/example/project.git")
```

**BEAM target:** `git:clone(Repo)`

### `git.pull()`

Pull the current repository.

```seagrass
git.pull()
```

**BEAM target:** `git:pull()`

### `git.status()`

Return `git status --short` as text.

```seagrass
git.status()
```

**BEAM target:** `git:status()`

### `git.current_branch()`

Return the current branch name.

```seagrass
git.current_branch()
```

**BEAM target:** `git:current_branch()`

## Status

| Feature | Status |
|---|---|
| `git.clone` | ✅ implemented |
| `git.pull` | ✅ implemented |
| `git.status` | ✅ implemented |
| `git.current_branch` | ✅ implemented |
