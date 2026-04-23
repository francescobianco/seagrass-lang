# Toolchain

The Seagrass toolchain is a single command: `sg`.

## Commands

### Run a file

```bash
sg run <file.sg>
```

Compiles `file.sg` to a temporary `.beam` and executes it immediately.
The compiled artifact is discarded after execution.

### Syntax check

```bash
sg check <file.sg>
```

Parses and validates `file.sg` without producing any output file.
Exits with code `0` if the file is valid, `1` otherwise.
Useful in CI pipelines and editor integrations.

### Build

```bash
sg build <file.sg>
sg build <file.sg> -o <outdir>
```

Compiles `file.sg` to a `.beam` file. By default the output is written next
to the source file. Use `-o <dir>` to write to a specific directory.

Prints the path of the produced `.beam` on success.

---

## Developer commands

These commands are not part of the standard workflow but are useful during
language development and debugging.

```bash
sg inspect <file.sg>
```

Prints the full AST and the generated Erlang source for `file.sg`.

---

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | Error (syntax, compile, file not found, …) |
