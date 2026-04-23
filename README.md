# Seagrass

Seagrass is a small language that compiles to BEAM and treats sequencing and
parallelism as first-class syntax.

The language was created to make workflow-style programs easier to read and
harder to accidentally serialize. In Seagrass, a newline means "do this after
the previous step", while a comma means "run these branches in parallel". That
gives the source code a shape that matches the execution model.

## Why it exists

Seagrass was designed around a simple idea: business and automation flows are
usually described as ordered steps with occasional forks and joins, but general
purpose languages tend to hide that structure inside libraries, callbacks, job
queues, or ad-hoc process orchestration.

Seagrass makes that structure explicit:

- sequential steps are written on separate lines
- parallel branches are written on the same level with `,`
- grouped branches are written with `{ ... }`
- the result still compiles to regular Erlang/BEAM artifacts

The goal is not to replace Erlang or Elixir. The goal is to offer a smaller
language whose syntax is optimized for orchestration, parallel branching, and
clear execution flow.

## Example

```seagrass
import io

io.print("start")

io.print("left"), {
    io.print("right-1")
    io.print("right-2")
}

io.print("end")
```

In that program, `io.print("left")` runs in parallel with the block on the
right. Inside the block, `right-1` and `right-2` run sequentially.

## Comment syntax

Seagrass supports three comment styles:

```seagrass
// line comment
# line comment
/* block comment */
```

Block comments may span multiple lines.

## Toolchain

```bash
make dev-ubuntu   # bootstrap a Ubuntu development environment
make build        # compile the project
make install      # install sg in ~/.local/bin
```

## Current direction

The current implementation focuses on:

- module imports
- sequential execution
- parallel branching
- grouped nested branches
- code generation to Erlang

More language features described under `docs/` are planned, but not all are
implemented yet.
