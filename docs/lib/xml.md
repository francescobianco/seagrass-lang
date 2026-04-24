---
title: xml
layout: default
parent: Standard Library
nav_order: 4
---

# xml

XML parsing and serialization helpers.

```seagrass
import xml
```

## Functions

### `xml.parse(text)`

Parse XML text using Erlang's `xmerl`.

```seagrass
doc = xml.parse("<root><item>ok</item></root>")
```

Returns an `xmerl` document term.

**BEAM target:** `xml:parse(Text)`

### `xml.stringify(node)`

Serialize an XML node or simple-form tuple to XML text.

```seagrass
text = xml.stringify({"root", [], ["ok"]})
```

If `node` is already a string or binary, it is returned as text.

**BEAM target:** `xml:stringify(Node)`

## Status

| Feature | Status |
|---|---|
| `xml.parse` | ✅ implemented |
| `xml.stringify` | ✅ implemented |
