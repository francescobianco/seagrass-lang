# Variables

Bind a name to a value.

## Syntax

```
<name> = <expression>
```

## Description

A variable is declared by writing its name, an `=` sign, and an expression.
There is no `let`, `var`, or `const` keyword.

```seagrass
x = 42
name = "mario"
result = my_module.compute()
```

Variables are **immutable**: once bound, their value never changes. To work
with an updated value, bind a new name.

```seagrass
x = 1
y = x + 1   // y is 2, x is still 1
```

## Types

Seagrass is dynamically typed. The type of a variable is determined at runtime
by its value — no type annotation is required.

Optional type annotations are planned for a future version.

## Parallel assignment

When multiple assignments appear on the **same line** separated by commas,
each right-hand expression runs in a **separate BEAM process**. The line
completes only after all processes have finished.

```seagrass
invoice_errors = send_invoice(), email_errors = send_email()
```

`send_invoice()` and `send_email()` execute concurrently. Both `invoice_errors`
and `email_errors` are bound when the slower of the two completes.

This is useful for I/O-bound operations (HTTP calls, database queries, file
reads) that do not depend on each other.

## BEAM target

A single assignment:

```seagrass
result = my_module.compute()
```

Compiles to a regular Erlang variable binding:

```erlang
Result = my_module:compute()
```

Parallel assignment:

```seagrass
a = f(), b = g()
```

Compiles to:

```erlang
[A, B] = sg_par_bind([fun() -> f() end, fun() -> g() end])
```

where `sg_par_bind` spawns both functions, waits for both results in order,
and returns them as a list.

## Status

| Feature | Status |
|---|---|
| Single assignment | 🔲 planned |
| Parallel assignment | 🔲 planned |
| Immutability enforcement | 🔲 planned |
