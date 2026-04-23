# Seagrass Language — Documentation

Seagrass is a language that compiles to BEAM (the Erlang virtual machine).
Its defining characteristic is that **parallelism and sequentiality live in
the same syntax**: a newline separates sequential steps, a comma on the same
line runs them in parallel as real BEAM processes.

```seagrass
io.print("start")                              // sequential

io.print("Hello"), io.print("World!")          // parallel — two BEAM processes

io.print("end")                                // sequential — waits for both
```

---

## Language Reference

### Core execution model

| Concept | Syntax | Description |
|---|---|---|
| Sequential step | `expr` on its own line | Runs after the previous step completes |
| Parallel group | `expr, expr` on the same line | All expressions start simultaneously; the line completes when all finish |
| Statement terminator | newline or `;` | Both are equivalent |
| Module invocation | `module()` | Executes the root-level statements of `module.sg` |

### Language features

| Feature | File | Status |
|---|---|---|
| **Import system** | [import-system.md](import-system.md) | ✅ parsing done |
| **Variables** | [variables.md](variables.md) | 🔲 planned |
| **Arrays** | [arrays.md](arrays.md) | 🔲 planned |
| **sizeof operator** | [sizeof.md](sizeof.md) | 🔲 planned |
| **For loop** | [for-loop.md](for-loop.md) | 🔲 planned |
| **String interpolation** | [string-interpolation.md](string-interpolation.md) | 🔲 planned |
| **Functions** | [functions.md](functions.md) | 🔲 planned |
| **Classes** | [classes.md](classes.md) | 🔲 planned |
| **Objects** | [objects.md](objects.md) | 🔲 planned |

---

## Compiler & Tooling

### Building

```bash
./rebar3 escriptize          # build the sgc binary
```

### CLI commands

```bash
sgc run     file.sg          # compile and execute
sgc compile file.sg -o dir   # produce standalone .beam
sgc check   file.sg          # parse and validate only
sgc inspect file.sg          # print AST + generated Erlang
```

### Compiler pipeline

```
source.sg
    │
    ▼
sg_lexer   (Leex)       tokenises; newline and ; → sequential, comma → parallel
    │
    ▼
sg_parser  (Yecc LALR1) builds AST; comma at stmt level ≠ comma inside (...)
    │
    ▼
sg_codegen              AST → Erlang source; parallel blocks → inline sg_par/1
    │
    ▼
compile:file/1          Erlang → .beam, runs on OTP standard runtime
```

### Parallel execution model

Every parallel group (`a, b, c` on the same line) compiles to
`spawn_monitor`-based concurrent execution. Each expression becomes a BEAM
process. The line completes only after all processes finish normally; a crash
in any one propagates to the caller.

No external runtime library is required — the parallel helper is inlined into
each generated module.

---

## Standard library

The stdlib is written in Seagrass. Full reference: [docs/lib/](lib/index.md).
Key built-in module: `io`.

```seagrass
// lib/io.sg
function print(message) {
    __STDOUT__.write(message)
}
```

Built-in objects (`__STDOUT__`, `__STDERR__`, `__STDIN__`) are injected by
the runtime without an explicit import.

---

## Examples

| Example | Description |
|---|---|
| `examples/hello-world/hello-world.sg` | Sequential + parallel output |
| `examples/basic-workflow/basic-workflow.sg` | Parallel calls, arrays, for loop, string interpolation |

---

## Design decisions (open)

These points from `IDEA.md` are still to be decided:

1. **Syntax style** — brace blocks `{ }` vs `do/end` vs indentation-significant
2. **Types** — fully dynamic (Erlang-style) vs optional dialyzer annotations vs static
3. **State passing** — explicit between steps vs shared process dictionary
4. **Error handling** — `on_failure` saga pattern vs inline `try/catch`
5. **Interop** — how to call raw Erlang/Elixir from Seagrass
6. **Advanced concurrency** — `wait_for` with timeout, cross-instance correlation
7. **Distribution** — local only vs multi-node BEAM cluster
