---
title: csv
layout: default
parent: Standard Library
nav_order: 5
---

# csv

CSV parsing and serialization helpers.

```seagrass
import csv
```

## Functions

### `csv.parse(text)`

Parse CSV text into rows.

```seagrass
rows = csv.parse("name,age\nAda,37")
```

Returns a list of rows, where each row is a list of fields.

**BEAM target:** `csv:parse(Text)`

### `csv.stringify(rows)`

Serialize rows to CSV text.

```seagrass
text = csv.stringify([["name", "age"], ["Ada", "37"]])
```

Fields containing commas, quotes, or line breaks are quoted automatically.

**BEAM target:** `csv:stringify(Rows)`

## Status

| Feature | Status |
|---|---|
| `csv.parse` | ✅ implemented |
| `csv.stringify` | ✅ implemented |
