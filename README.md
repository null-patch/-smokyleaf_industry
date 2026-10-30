# Smokeleaf Industries — Luanti

A Luanti adaptation of Smokeleaf Industries. Version **1.0.6** restores the original Forge cultivation progression and its core plant-care mechanics while retaining the existing Luanti processing blocks, Drying Rack, GUI, and Elepower integration.

This is an independent Lua implementation. It does not bundle the original Forge code or its assets.

## Cultivation in v1.0.6

### Original growth cycles

- **Named weed strains:** 11 ages (0–10). The plant becomes two blocks tall at age 7; the final four ages use the tall-plant form.
- **Hemp:** 11 ages (0–10), becomes tall at age 7, and has the original **3.5× natural-growth-speed multiplier**.
- **Tobacco:** 7 ages (0–6), following the original vanilla CropBlock-style cycle.
- The natural growth check uses the Forge formula `nextInt(floor(25 / growthSpeed) + 1) == 0`, with Minecraft's default random-tick rate approximated by a server-side Luanti ABM. Actual wall-clock timing can vary with server load and Luanti's ABM scheduling.
- Weed and hemp natural growth require light level 11; tobacco requires light level 9.
- The original surrounding-soil and crop-spacing growth-speed factors are applied. Dirt/grass planting remains supported for compatibility with the earlier Luanti port; farmland and supported farming soils provide the proper soil contribution.

### Strains and genetics

The 25 original named strain presets are included:

White Widow, Bubble Kush, Lemon Haze, Sour Diesel, Blue Ice, Bubblegum, Purple Haze, OG Kush, Jack Herer, Gary Peyton, Amnesia Haze, AK-47, Ghost Train, Grape Ape, Cotton Candy, Banana Kush, Carbon Fiber, Birthday Cake, Blue Cookies, Afghani, Moonbow, Lava Cake, Jelly Rancher, and Pink Kush.

Each strain has its original THC, CBD, N/P/K target, and preset color data. Newly planted strain crops begin with N/P/K at zero. Bud quality for named weed strains is calculated from the difference between current nutrients and the strain target:

- Exact N/P/K match: THC and CBD are doubled (capped at 100); harvest yield is ×3.
- All three nutrients within ±3 of target, but not all exact: harvest yield is ×2.
- Any nutrient more than 3 points from target: base yield is ×1.
- Off-target THC/CBD is reduced using the original 10%-per-total-nutrient-point formula, with a floor of half the base genetic value (minimum 1).

### Fertilizers

All 17 original fertilizer types are added: Worm Castings, Compost, Mycorrhizae, Dolomite Lime, Blood Meal, Phosphorus Feed, Bat Guano, Kelp Meal, Wood Ash, Bloom Booster, Fruit Finisher, Nitrogen Boost, Potash Boost, Balanced Boost, Phosphorus Reducer, Potassium Reducer, and Fish Emulsion.

Fertilizers modify crop N/P/K directly, clamp each value to 0–100, and cannot be applied to mature crops. Their item descriptions show their nutrient changes. Recipes use available Luanti Game materials and are registered only when the required ingredients exist.

### Plant Analyzer

Craft the Plant Analyzer and right-click a weed, hemp, tobacco crop, or Grow Pot to view its growth age, progress, THC/CBD, current N/P/K, target N/P/K, expected bud multiplier, and pH value.

### Grow Pot

1. Right-click the Grow Pot with a supported soil node item to insert soil.
2. Plant weed or hemp seeds directly on the pot. Tobacco is not accepted in the Grow Pot, matching the original block behaviour.
3. With light level 12 or higher, crops complete their cycle in **60 seconds on farmland** or **90 seconds on other inserted soils**.
4. Fertilizer and bone meal can be applied by right-clicking the pot or its crop. Bone meal advances the crop by a random 2–5 ages.
5. Right-click a mature Grow Pot crop (or the pot) to harvest it; the planted crop remains and restarts at age 0. Sneak + right-click the empty pot to remove its soil.

### Hemp and lighting

- Fully grown field hemp can be sheared three times for individual Hemp Leaves; the fourth shear harvests the plant. Hemp Leaf and Hemp Fiber are registered harvest items (the original plural `hemp_fibers` ID aliases to the port's existing `hemp_fiber` item).
- LED and HPS Grow Lights accelerate weed/hemp crops in a 3×3 area up to five blocks below. They make two growth attempts every 100 game ticks (5 seconds), using the original per-attempt growth formula and vertical line-of-sight check. The LED emits light level 15, matching the Forge LED block.
- Reflectors are ceiling-mounted. Insert an HPS lamp (15 minutes) or Dual Arc lamp (45 minutes). A working reflector emits light level 15 and makes one crop-growth attempt every 100 game ticks. Partially used lamps retain their remaining life when removed.
- With Elepower PAPI installed, LED/HPS Grow Lights remain disabled until enabled and supplied with Elepower energy (8 EU/s for LED, 16 EU/s for HPS). Without Elepower, they use their standalone ON/OFF behaviour. Reflectors use replaceable lamps, not Elepower.

## Installation

1. Back up your world.
2. Remove the previous `smokyleaf_industry` mod directory before extracting this release. Do not merge old and new files.
3. Extract the `smokyleaf_industry` directory into your Luanti mods directory.
4. Enable the mod for your world and restart Luanti.
5. Check `debug.txt` if the mod does not load.

For Flatpak Luanti on Linux, the usual per-user mods directory is:

```text
~/.var/app/org.luanti.luanti/.minetest/mods/
```

Other installations may use `~/.minetest/mods/` or a world-specific `worldmods` directory.

## Dependencies

- Luanti 5.7 or newer.
- `default` is recommended for the supplied recipes and item textures.
- `farming` is optional; common farming soil nodes are recognised when present.
- `elepower_papi` is optional and enables Elepower integration for the existing processing machine and Grow Lights.

## Compatibility and migration

- The release includes one-time LBMs for older crops and Grow Pots. Previously mature stage-8 weed/hemp crops are migrated to the new mature age; prior tobacco stage 8 maps to the original mature tobacco age.
- Older placeholder strain IDs are aliased to the closest matching original preset where a reasonable mapping exists.
- Keep a backup before updating. As with any crop-node migration, test the update on a copy of an existing world first.

## Controls summary

| Action | Control |
|---|---|
| Plant seeds | Right-click dirt/farmland or a soil-filled Grow Pot |
| Apply fertilizer | Right-click a crop with fertilizer |
| Use bone meal | Right-click a crop with bone meal |
| Analyze a plant | Right-click a crop or Grow Pot with Plant Analyzer |
| Shear hemp | Right-click mature field hemp with shears (three leaf cuts, then harvest) |
| Harvest Grow Pot | Right-click a mature pot crop or its pot |
| Remove Grow Pot soil | Sneak + right-click an empty Grow Pot |
| Toggle Grow Light | Right-click the light |
| Insert/remove Reflector lamp | Right-click the Reflector with a lamp / empty hand |

## Validation status

The release package is checked for Lua syntax using the available LuaTeX Lua parser, and the cultivation module is loaded with a mocked Luanti registration API to validate registration order and definitions. This environment does not include a running Luanti server, so real-world crop rendering, multiplayer, Elepower network transfer, and server-tick timing still require in-game testing.

## Credits

- Original gameplay reference: [Micaxs / Smokeleaf Industries](https://github.com/Micaxs/smokeleafindustries)
- Luanti adaptation: independent Lua implementation for Luanti.

See `LICENSE` for this port's licence terms.
