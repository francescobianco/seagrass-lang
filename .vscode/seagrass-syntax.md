VS Code workspace support for Seagrass files.

This workspace uses a pragmatic fallback:

- `*.sg` files are associated with `javascript`

That gives immediate syntax coloring for:

- strings
- numbers
- braces and parentheses
- `function`, `class`, `return`, `import`
- `//` and `/* ... */` comments

Unlike the WebStorm `.idea/textmate/Seagrass` bundle, this is not a real
Seagrass grammar. It is only a lightweight fallback for editor highlighting.
