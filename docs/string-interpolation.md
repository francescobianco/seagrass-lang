---
title: String Interpolation
layout: default
parent: Home
nav_order: 70
---

# String Interpolation

Embed values inside a string using the `<<` operator.

## Syntax

```
"text with $placeholder" << value1, value2, ...
```

## Description

The `<<` operator formats a string by replacing `$`-prefixed placeholders
with the values listed after `<<`. Values are matched to placeholders
left-to-right in the order they appear.

```seagrass
io.print("hello, $s!" << username)
io.print("item $d of $d" << current, total)
```

## Placeholders

| Placeholder | Type | Description |
|---|---|---|
| `$s` | string | Inserted as text |
| `$d` | integer | Inserted as a decimal number |
| `$f` | float | Inserted as a floating-point number |
| `$p` | any | Debug representation (like Erlang's `~p`) |

To include a literal `$` in the string, write `$$`:

```seagrass
"price: $$d" << amount   // → "price: $42"
```

## String on the left can be indirect

The format string can come from a variable:

```seagrass
template = "dear $s, your order $d is ready"
message  = template << customer_name, order_id
```

This makes it easy to define reusable templates.

## BEAM target

```seagrass
"item $d: $s" << index, label
```

Compiles to:

```erlang
io_lib:format("item ~w: ~s", [Index, Label])
```

The result is a Seagrass string (Erlang `iodata` / binary on BEAM).

Placeholder-to-format mapping:

| Seagrass | Erlang `io_lib:format` |
|---|---|
| `$s` | `~s` |
| `$d` | `~w` |
| `$f` | `~f` |
| `$p` | `~p` |

## Status

| Feature | Status |
|---|---|
| `"..." << val` operator | 🔲 planned |
| `$s`, `$d`, `$f`, `$p` placeholders | 🔲 planned |
| Indirect format string (variable on left) | 🔲 planned |
| `$$` escape | 🔲 planned |
