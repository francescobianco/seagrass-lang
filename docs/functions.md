# Functions

Reusable blocks of code that accept parameters and return a value.

## Syntax

```
function <name>(<param1>, <param2>, ...) {
    <body>
    return <value>
}
```

## Description

Functions are defined with the `function` keyword, a name, a parameter list
in parentheses, and a body inside braces. The `return` statement exits the
function and produces its value.

```seagrass
function add(a, b) {
    return a + b
}

function greet(name) {
    return "hello, $s" << name
}
```

A function with no parameters uses empty parentheses:

```seagrass
function now() {
    return time.unix()
}
```

## Calling a function

A function defined in the current file is called directly by name:

```seagrass
result = add(1, 2)
```

A function in an imported module is called with the module prefix:

```seagrass
import my_utils
x = my_utils.compute(data)
```

## The standard library uses functions

`lib/io.sg` defines the `print` function that `io.print(...)` calls:

```seagrass
function print(message) {
    __STDOUT__.write(message)
}
```

`__STDOUT__` is a built-in stream object. This shows that standard-library
modules are plain Seagrass files — no special compiler support is needed.

## Return value

Every function returns a value. If `return` is omitted, the function returns
the value of its last expression (like Erlang functions, which always
return the last expression).

```seagrass
function double(x) {
    x * 2   // implicit return
}
```

## BEAM target

A Seagrass function compiles to an Erlang function in the same module:

```seagrass
function add(a, b) {
    return a + b
}
```

Compiles to:

```erlang
add(A, B) ->
    A + B.
```

## Status

| Feature | Status |
|---|---|
| `function` definition | 🔲 planned |
| `return` statement | 🔲 planned |
| Implicit return (last expression) | 🔲 planned |
| Higher-order functions (passing functions) | 🔲 planned |
| Recursive functions | 🔲 planned |
