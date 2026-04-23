# Arrays

Ordered, zero-indexed collections of values.

## Syntax

```
[element1, element2, ...]
```

## Description

Arrays hold an ordered sequence of elements. Elements can be of any type and
do not need to be homogeneous.

```seagrass
numbers = [1, 2, 3]
names   = ["alice", "bob", "carol"]
mixed   = [1, "two", 3.0]
empty   = []
```

## Concatenation

The `+` operator concatenates two arrays into a new one. Neither original is
modified (variables are immutable).

```seagrass
invoice_errors = send_invoice()
email_errors   = send_email()

all_errors = invoice_errors + email_errors
// all_errors has all elements of invoice_errors followed by email_errors
```

## Measuring size

The `sizeof(...)` operator returns the number of elements in an array (and in
general measures the "size" of various types — more cases to be defined).
Arrays do **not** expose a `.length()` method or any other dot-methods.

```seagrass
n = sizeof(errors)
io.print("$d errors found" << n)
```

`sizeof` is a language-level operator, not a function call. It works on
arrays, strings, and other types that have a notion of size.

## Other operations

| Operation | Syntax | Description |
|---|---|---|
| Concatenation | `a + b` | New array with elements of `a` then `b` |
| Size | `sizeof(a)` | Number of elements |
| Map | `a.map(f)` | Apply `f` to each element, return new array |
| Filter | `a.filter(p)` | Keep elements where predicate `p` is true |
| Reduce | `a.reduce(f, init)` | Fold `f` over elements, starting with `init` |

## BEAM target

Arrays map to Erlang lists. Concatenation maps to `lists:append/2` (`++`):

```seagrass
a + b
```

Compiles to:

```erlang
A ++ B
```

## Status

| Feature | Status |
|---|---|
| Array literal `[...]` | 🔲 planned |
| Concatenation `+` | 🔲 planned |
| `sizeof(a)` | 🔲 planned |
| `.map()`, `.filter()`, `.reduce()` | 🔲 planned |
| Range literal `1..10` | 🔲 planned |
