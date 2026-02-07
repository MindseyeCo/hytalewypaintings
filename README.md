# Wyvern Paintings

Author: **WyvernScale**

`Wyvern Paintings` is a Hytale mod that adds a wall-mounted painting block you can right-click to set an image path. The painting's front face updates to show the selected image.

## Features

- New placeable item/block: `Wyvern Painting`
- Wall-only placement with backing validation
- Right-click interaction opens an image path dialog
- Runtime texture updates for the painting front
- Persistent storage of painting image paths per world
- Server-to-client sync for multiplayer compatibility

## How it works

1. Place the painting on a wall.
2. Right-click the painting.
3. Enter an image path, for example: `assets/textures/custom/my_art.png`.
4. Press **Save** to apply.
5. Use **Clear** to reset to default.

## Package structure

- `mod.json` – mod metadata and entrypoints.
- `scripts/server/main.lua` – placement/interact logic, validation, sync.
- `scripts/server/painting_storage.lua` – world persistence for painting state.
- `scripts/client/main.lua` – applies synced runtime textures.
- `scripts/client/ui/image_path_dialog.lua` – image path UI.
- `assets/blocks/wyvern_painting.block.json` – block definition.
- `assets/models/block/wyvern_painting.model.json` – model with runtime front texture override.
- `assets/items/wyvern_painting.item.json` – item definition.
- `assets/recipes/wyvern_painting.recipe.json` – crafting recipe.

## Notes

- Image paths must be accessible to connected clients.
- If the path is invalid, the engine will render fallback/empty texture behavior.
- Maximum path length is capped to prevent abuse.
- This mod intentionally ships with no binary texture files; it uses engine/base-game texture IDs for defaults.
