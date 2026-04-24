---
title: Import System
layout: default
parent: Home
nav_order: 20
---

# Import System

Bring external modules into the current file's scope.

## Syntax

```
import <module>
import <module>, <module>, <module>
import <module>.<submodule>
import <module>.<function>
```

## Description

An `import` declaration makes a module (or a specific symbol inside a module)
available in the current file. You can import one module per line or a
comma-separated list on a single line. Imports are normally listed at the top
of the file before any executable code.

```seagrass
import io
import send_invoice
import send_email

import io, git, xml
```

After importing, the module is referenced by its short name:

```seagrass
import io
io.print("hello")
```

## Dot notation

A dot in the import path means one of two things:

- **Subdirectory**: `import module1.submodule1` looks for `module1/submodule1.sg`
- **Symbol**: `import io.print` imports only the `print` function from `io`,
  making it callable as `print(...)` without the `io.` prefix

## Module resolution

The compiler searches for modules in this order:

1. **Built-in stdlib** — modules shipped with Seagrass (`io`, `math`, …)
2. **Local files** — `.sg` files in the project root or relative to the current file
3. **Library path** — directories listed in the `SEAGRASS_LIB` environment variable
   (colon-separated, same convention as `PATH`)

The standard library itself is distributed as `.sg` source files and compiled
on demand.

## Calling a module directly

A module can be invoked **as a function** using its name followed by `()`:

```seagrass
import miomodulo

miomodulo()
```

This executes the **root-level statements** of `miomodulo.sg` — i.e., every
statement that lives at the top scope of that file, not inside a function or
class body.

Given `miomodulo.sg`:

```seagrass
hello()
world()
```

Calling `miomodulo()` runs `hello()` then `world()` in sequence, exactly as
if those lines were written inline at the call site.

This makes every `.sg` file implicitly executable: a module is both a
namespace for functions and an independently runnable unit. There is no
special `main` entry point to declare — the root scope **is** the entry point.

Module calls obey the same parallel rules as any other expression:

```seagrass
// run two modules concurrently
mod_a(), mod_b()
```

## BEAM target

Imports generate no runtime code. They are resolved at compile time and used
only to qualify call sites in the generated Erlang.

```seagrass
import send_invoice
send_invoice.run(id)
```

Compiles to:

```erlang
send_invoice:run(Id)
```

A direct module call `miomodulo()` compiles to:

```erlang
miomodulo:main([])
```

where `main/1` is the generated entry-point function that wraps the module's
root-level statements.

## Rules

- One or more modules can appear on the same `import` line when separated by commas.
- Importing the same module twice is silently ignored (idempotent).
- Importing a module that does not exist is a compile-time error *(planned — v2)*.

## Status

| Feature | Status |
|---|---|
| `import name` parsed | ✅ implemented |
| `import a, b, c` parsed | ✅ implemented |
| Symbol resolution at call sites | ✅ implemented |
| Direct module call `module()` | 🔲 planned |
| Dot-path imports | 🔲 planned |
| Import validation (module exists) | 🔲 planned |
