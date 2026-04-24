---
title: io
layout: default
parent: Standard Library
nav_order: 1
---

# io

Console input/output and file system access.

```seagrass
import io
```

---

## Functions

### `io.print(message)`

Write `message` to standard output followed by a newline.

```seagrass
io.print("hello, world")
io.print("count: $d" << count)
```

**BEAM target:** `io:format("~s~n", [Message])`

---

### `io.ask(prompt)`

Print `prompt` to standard output (no trailing newline), then block until the
user presses Enter. Returns the line the user typed, without the trailing
newline character.

```seagrass
name = io.ask("Your name: ")
io.print("hello, $s" << name)
```

Equivalent of Python's `input()`.

**BEAM target:**
```erlang
io:format("~s", [Prompt]),
{ok, Line} = io:get_line(""),
string:trim(Line, trailing, "\n")
```

---

### `io.file(path)`

Return a lazy **File** handle for the file at `path`. The file is not opened
on disk at this point — the OS call happens only when a method is invoked on
the handle.

```seagrass
f = io.file("data/log.txt")
f.append("new entry")
```

Returns a `File` object (see below).

---

## File object

`io.file(path)` returns an instance of `File`. All methods are lazy: the file
is opened, used, and closed within each call.

### `file.append(text)`

Append `text` as a new line to the file. Creates the file if it does not
exist; creates intermediate directories if needed.

```seagrass
io.file("log.txt").append("2026-04-24 started")
```

**BEAM target:** `file:write_file(Path, [Text, "\n"], [append])`

---

### `file.write(text)`

Overwrite the file with `text`. Creates the file if it does not exist.

```seagrass
io.file("output.txt").write("final result")
```

**BEAM target:** `file:write_file(Path, Text)`

---

### `file.read()`

Read the entire file and return it as a string.

```seagrass
content = io.file("config.txt").read()
```

**BEAM target:** `{ok, Bin} = file:read_file(Path), binary_to_list(Bin)`

---

### `file.read_lines()`

Read the file and return an array of lines (newlines stripped).

```seagrass
for (line in io.file("data.csv").read_lines()) {
    process(line)
}
```

**BEAM target:** `string:split(Content, "\n", all)`

---

### `file.exists()`

Return `true` if the file exists on disk, `false` otherwise.

```seagrass
if io.file("lock").exists() {
    io.print("already running")
}
```

**BEAM target:** `filelib:is_regular(Path)`

---

### `file.delete()`

Delete the file. No-op if the file does not exist.

```seagrass
io.file("tmp.txt").delete()
```

**BEAM target:** `file:delete(Path)`

---

## Lazy open — rationale

`io.file(path)` returns a handle without touching the disk. This means:

- The path can be constructed or passed around before any I/O happens.
- Multiple method calls each open, use, and close the file independently —
  no handle is left open across statements.
- Parallel file operations are safe by default (each call owns its own
  file descriptor for the duration of the call).

```seagrass
// build the path first, open later
log = io.file("logs/$s.txt" << date)

// two appends run in parallel — each opens/closes independently
log.append("event A"), log.append("event B")
```

---

## Status

| Feature | Status |
|---|---|
| `io.print` | ✅ implemented (compiler built-in) |
| `io.ask` | 🔲 planned |
| `io.file` + `File` class | 🔲 planned |
