---
title: Branching
layout: default
parent: Home
nav_order: 30
---

# Branching

Seagrass supports compound branching using `,` for parallel execution and
`{ ... }` to group a nested sub-program.

## Rules

- A `{ ... }` block contains ordinary Seagrass statements.
- Inside a block, newlines and `;` remain sequential separators.
- A comma `,` runs expressions in parallel at the same nesting level.
- A parallel branch can be either a single call or a nested block.

## Examples

```seagrass
call1(), {
    call2()
    call3()
}
```

`call1()` runs in parallel with the sequence `call2()` then `call3()`.

```seagrass
{
    call1a()
    call1b()
}, {
    call2()
    call3()
}
```

The two blocks start in parallel; inside each block the calls remain
sequential.

```seagrass
call1(), {
    { call2(); call3() }, {
        call4();
    }
}
```

The second branch is a block that itself contains a parallel split between two
sub-branches: the first is a sequence of two calls, the second is a single
call.
