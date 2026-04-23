# Standard Library

The Seagrass standard library is written in Seagrass itself. Each module is a
`.sg` file under `lib/` and is available without installing anything extra.

## Modules

| Module | File | Description |
|---|---|---|
| `io` | [io.md](io.md) | Console I/O and file system access |
| `json` | [json.md](json.md) | JSON encoding and decoding |
| `xml` | [xml.md](xml.md) | XML parsing and serialization |
| `csv` | [csv.md](csv.md) | CSV parsing and serialization |

## How the stdlib works

Standard library modules are plain `.sg` files. There is nothing special about
them: they use the same syntax as user code and compile to `.beam` through the
same pipeline.

The only difference is that stdlib modules can reference **built-in objects**
— runtime-injected values prefixed with double underscores:

| Object | Description |
|---|---|
| `__STDOUT__` | Standard output stream |
| `__STDIN__` | Standard input stream |
| `__STDERR__` | Standard error stream |
| `__FS__` | File system handle |

These objects are provided by the BEAM runtime and are never visible in user
code directly; they exist only inside stdlib implementations.

## Using a stdlib module

```seagrass
import io

io.print("hello")
name = io.ask("Your name: ")
io.file("log.txt").append("visited")
```

No installation or configuration needed — the compiler resolves `io` to
`lib/io.sg` automatically.
