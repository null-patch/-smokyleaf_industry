# Texture assets

All PNGs in this directory are original assets created for this Luanti port or carried forward from its earlier Luanti releases. The original Forge repository's artwork is not bundled here.

## Cultivation additions in v1.0.6

- `smokyleaf_industry_fertilizer_<name>.png` — 17 fertilizer item icons.
- `smokyleaf_industry_plant_analyzer.png` — Plant Analyzer item icon.
- `smokyleaf_industry_reflector.png` and `smokyleaf_industry_reflector_active.png` — inactive/active Reflector node textures.
- `smokyleaf_industry_hps_lamp.png` and `smokyleaf_industry_dual_arc_lamp.png` — replaceable lamp item icons.

Plant stage textures use the `smokyleaf_industry_weed_<1..8>.png`, `smokyleaf_industry_hemp_<1..8>.png`, and `smokyleaf_industry_tobacco_<1..8>.png` files. The Lua growth model has 11 weed/hemp ages and 7 tobacco ages; where the older art set does not contain a matching late-stage sprite, the final available plant texture is reused. Growth timing and harvest state are still tracked independently by node metadata.

To add a texture, save it as a PNG in this directory and use the exact filename in the node/item registration. Keep alpha transparency for plant and item sprites.
