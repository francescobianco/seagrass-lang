WebStorm setup for Seagrass files.

This project ships a local TextMate bundle under `.idea/textmate/Seagrass`.

Expected behavior after reopening the project:

- `*.sg` files are recognized as Seagrass/TextMate-backed files
- line comments `//` and `#` are highlighted
- block comments `/* ... */` are highlighted
- strings, numbers, keywords, module calls, and type-like identifiers are highlighted

If WebStorm does not pick it up automatically, ensure the TextMate Bundles
plugin/support is enabled and reopen the project.
