# Writing Screen JSON

A `CosmosScreen` is a JSON object with four top-level keys:

- `id` – a stable identifier for the screen.
- `title_key` – an optional key resolved through localization.
- `layout` – a ``CosmosLayout`` describing the root container.
- `components` – an array of ``CosmosComponent`` envelopes.

## Example

```json
{
    "id": "welcome",
    "title_key": "welcome.title",
    "layout": {
        "root": "vStack",
        "spacing": "medium",
        "padding": "large",
        "alignment": "center"
    },
    "components": [
        { "text": { "content_key": "welcome.headline" } },
        { "text": { "content_key": "welcome.body" } },
        { "spacer": {} },
        {
            "button": {
                "title_key": "welcome.continue",
                "action": { "id": "continue" }
            }
        }
    ]
}
```

## Component envelopes

Each component is a single-key object. The key selects the component type; the
value is the model:

| Key | Model |
| --- | --- |
| `text` | ``CosmosTextModel`` |
| `button` | ``CosmosButtonModel`` |
| `icon` | ``CosmosIconModel`` |
| `divider` | Empty |
| `spacer` | Empty |
| `v_stack` | ``CosmosStackLayout`` |
| `h_stack` | ``CosmosStackLayout`` |
| `z_stack` | ``CosmosStackLayout`` |

Keys use snake_case because the loader configures the decoder with
`convertFromSnakeCase`.

## Encoding a screen

You can also encode a ``CosmosScreen`` back to JSON for debugging or server-side
authoring tools:

```swift
let loader = CosmosScreenLoader()
let json = try loader.jsonString(for: screen)
```
