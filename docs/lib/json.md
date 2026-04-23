# json

JSON encoding and decoding helpers.

```seagrass
import json
```

## Functions

### `json.encode(value)`

Serialize an Erlang/Seagrass value to a JSON string.

```seagrass
payload = json.encode("hello")
io.print(payload)
```

Supported values include strings, numbers, booleans, `null`, arrays, and maps.

**BEAM target:** `json:encode(Value)`

### `json.decode(text)`

Parse a JSON string into an Erlang/Seagrass value.

```seagrass
value = json.decode("{\"ok\":true}")
```

Objects decode to maps, arrays to lists, strings to strings, and numbers to
integers or floats.

**BEAM target:** `json:decode(Text)`

## Status

| Feature | Status |
|---|---|
| `json.encode` | ✅ implemented |
| `json.decode` | ✅ implemented |
