---
title: sizeof
layout: default
parent: Home
nav_order: 60
---

# sizeof

Measure the size of a value.

## Syntax

```
sizeof(<expression>)
```

## Description

`sizeof` is a built-in language operator that returns an integer representing
the "size" of a value. What "size" means depends on the type:

| Type | Returns |
|---|---|
| Array | Number of elements |
| String | Number of characters |
| *(more types to be defined)* | |

```seagrass
sizeof([1, 2, 3])       // → 3
sizeof("hello")         // → 5
sizeof([])              // → 0
```

`sizeof` is an **operator**, not a method. Arrays and strings do not expose a
`.length()` or `.size()` method — `sizeof(x)` is the single canonical way to
measure any value.

## Examples

```seagrass
errors = invoice_errors + email_errors
io.print("$d total errors" << sizeof(errors))
```

```seagrass
name = io.ask("Name: ")
if sizeof(name) == 0 {
    io.print("name cannot be empty")
}
```

## BEAM target

```seagrass
sizeof(x)
```

Compiles to:

```erlang
length(X)        %% for arrays (Erlang lists)
string:length(X) %% for strings
```

The compiler selects the correct Erlang call based on the static type of the
expression, or emits a runtime dispatch when the type is not known at compile
time.

## Status

| Feature | Status |
|---|---|
| `sizeof` on arrays | 🔲 planned |
| `sizeof` on strings | 🔲 planned |
