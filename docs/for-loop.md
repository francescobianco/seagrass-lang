---
title: For Loop
layout: default
parent: Home
nav_order: 90
---

# For Loop

Iterate over a collection.

## Syntax

```
for (<item> in <collection>) {
    <body>
}

for (<item> in <collection> by <counter>) {
    <body>
}
```

## Description

The `for` loop iterates over every element in `collection`, binding each
element to `item` for the duration of the loop body.

```seagrass
for (error in errors) {
    io.print(error)
}
```

## The `by` modifier

`by <counter>` introduces a second variable that holds the current iteration
index, starting at `0` and incrementing by `1` on each step.

```seagrass
for (error in errors by index) {
    io.print(index)   // 0, 1, 2, ...
    io.print(error)
}
```

Useful when you need both the value and its position. The collection
expression is evaluated once before the loop starts.

Example from `basic-workflow.sg`:

```seagrass
for (error in invoice_errors + email_errors by index) {
    io.print("- $d. $s" << index+1, error)
}
```

Here `invoice_errors + email_errors` is concatenated first, then the loop
iterates over the combined list. `index+1` converts the 0-based counter to a
1-based display number.

## Loop body

The body uses `{ }` braces. Inside them, the usual sequential/parallel rules
apply: lines are sequential, and comma on the same line means parallel.

```seagrass
for (item in items) {
    step_a(item)
    step_b(item), step_c(item)   // step_b and step_c run in parallel
    step_d(item)
}
```

## BEAM target

Without `by`:

```seagrass
for (x in items) { f(x) }
```

Compiles to:

```erlang
lists:foreach(fun(X) -> f(X) end, Items)
```

With `by`:

```seagrass
for (x in items by i) { f(x, i) }
```

Compiles to a generated tail-recursive helper:

```erlang
sg_for(Items, 0, fun(X, I) -> f(X, I) end).

sg_for([], _, _) -> ok;
sg_for([H|T], I, F) -> F(H, I), sg_for(T, I+1, F).
```

## Status

| Feature | Status |
|---|---|
| `for (x in coll)` | 🔲 planned |
| `by <counter>` modifier | 🔲 planned |
| Parallel body lines | 🔲 planned |
| Range iteration `1..n` | 🔲 planned |
