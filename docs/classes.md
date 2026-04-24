---
title: Classes
layout: default
parent: Home
nav_order: 100
---

# Classes

Blueprints for creating objects with shared structure and behaviour.

## Syntax

```
class <Name> {
    <field declarations>
    <method definitions>
}
```

## Description

A `class` groups data fields and the functions that operate on them.
An instance of a class is called an **object**.

```seagrass
class Invoice {
    function run(order_id) {
        // create and send an invoice for order_id
        return result
    }

    function validate(order_id) {
        // return list of validation errors
        return errors
    }
}
```

## Fields

Fields hold the state of an object. They are declared inside the class body
and accessed with `self.<field>` inside methods.

```seagrass
class Counter {
    count = 0

    function increment() {
        self.count = self.count + 1
    }

    function value() {
        return self.count
    }
}
```

## Instantiation

An object is created with `new`:

```seagrass
c = new Counter()
c.increment()
c.increment()
io.print(c.value())   // 2
```

## Inheritance (planned)

```seagrass
class SpecialInvoice extends Invoice {
    function run(order_id) {
        // override
    }
}
```

## BEAM target

Each class compiles to an Erlang module backed by a `gen_server` (when the
class has mutable state) or a plain module (when stateless).

Stateless class:

```seagrass
class MathHelper {
    function square(x) { return x * x }
}
```

Compiles to a plain Erlang module:

```erlang
-module(math_helper).
-export([square/1]).
square(X) -> X * X.
```

Stateful class compiles to a `gen_server`, where the state record holds the
fields and each method becomes a `handle_call` clause.

## Status

| Feature | Status |
|---|---|
| `class Name { }` definition | 🔲 planned |
| Field declarations | 🔲 planned |
| Method definitions | 🔲 planned |
| `new Name()` instantiation | 🔲 planned |
| `self` reference | 🔲 planned |
| Inheritance with `extends` | 🔲 planned |
