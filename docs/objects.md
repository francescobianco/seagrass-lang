# Objects

Instances of classes — values that combine state and behaviour.

## Description

An object is created from a class using `new`. It holds its own copy of the
class fields and exposes the class methods.

```seagrass
import Counter

c = new Counter()
c.increment()
c.increment()
io.print(c.value())   // 2
```

## Method calls

Methods are called with dot notation:

```
object.method(arg1, arg2)
```

This is the same syntax used for module-level functions:

```seagrass
io.print("hello")           // module function call
c.increment()               // object method call
```

The compiler distinguishes the two by knowing whether the left-hand name is
a class instance or an imported module.

## Built-in objects

Some objects are available without an `import` or `new`. They are injected
by the runtime and prefixed with double underscores.

| Object | Description |
|---|---|
| `__STDOUT__` | Standard output stream |
| `__STDERR__` | Standard error stream |
| `__STDIN__` | Standard input stream |

Example — `lib/io.sg` uses `__STDOUT__` directly:

```seagrass
function print(message) {
    __STDOUT__.write(message)
}
```

## Parallel method calls

Like any other call, method calls on the same line separated by commas run
in parallel:

```seagrass
result_a = obj_a.compute(), result_b = obj_b.compute()
```

Both `compute` calls execute concurrently on separate BEAM processes.

## BEAM target

A stateful object is a `gen_server` process. Method calls become
`gen_server:call/2` messages:

```seagrass
c.increment()
```

Compiles to:

```erlang
gen_server:call(C, increment)
```

Stateless objects (no mutable fields) are not processes — method calls
become direct Erlang function calls:

```erlang
counter:square(X)
```

## Status

| Feature | Status |
|---|---|
| Object instantiation `new Name()` | 🔲 planned |
| Method call `obj.method(args)` | 🔲 planned |
| Built-in objects (`__STDOUT__`, …) | 🔲 planned |
| Stateful objects as `gen_server` | 🔲 planned |
| Parallel method calls | 🔲 planned |
