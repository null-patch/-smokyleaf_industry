# Development Notes

## Version 1.0.6 layout

- `init.lua` registers the base mod, strain seed/bud items, 11-state weed/hemp crop nodes, 7-state tobacco crop nodes, existing machinery, Drying Rack, Processing Machine, and Grow Lights.
- `cultivation.lua` contains the cultivation implementation: crop metadata and migration, field-growth ABMs, NPK calculations, fertilizers, Plant Analyzer, Grow Pot cycle, hemp shearing, grow-light acceleration, and Reflector/lamp lifecycle.
- `mod.conf` declares the Luanti version requirement and optional Elepower PAPI dependency.
- `textures/` contains the original Luanti port artwork plus the v1.0.6 cultivation icons.

## Crop state model

Only the bottom half of a two-block weed/hemp crop stores persistent metadata. The upper half is a visual support node. A bottom crop stores:

- `cultivation_schema`: current metadata schema (`2`).
- `growth_age`: weed/hemp age `0..10`, tobacco age `0..6`.
- `crop_family`, `strain_id`, `thc`, `cbd`, and `ph`.
- `nitrogen`, `phosphorus`, and `potassium`.
- `hemp_shear_count` for mature field hemp.
- `growpot`, `growpot_soil`, and `pot_growth_progress` for Grow Pot plants.

The v1.0.6 LBM converts prior stage-8 weed/hemp plants to the new mature age and creates their upper half. Prior tobacco stage 8 is remapped to the new mature tobacco node.

## Natural growth model

The Forge crop random-growth probability is retained:

`random(0, floor(25 / growthSpeed)) == 0`

Weed/hemp need light level 11; tobacco needs light level 9. Hemp receives a 3.5x natural growth-speed multiplier. Growth speed uses a Minecraft CropBlock-style soil contribution and same-family spacing penalty.

Luanti does not expose Minecraft's per-section random block tick scheduler. The port approximates its default randomTickSpeed=3 frequency using a one-second ABM with a 1-in-68 check per loaded crop node, then performs the original per-random-tick probability check. Server load and ABM scheduling can affect actual wall-clock timing.

Weed/hemp use ages 0–10 and become two blocks tall at age 7. Tobacco remains a single-block, 0–6 crop.

## NPK and strain genetics

`init.lua` exposes the original 25 strain presets through `smokyleaf_industry.strains`. Each preset contains THC, CBD, N/P/K targets, and tint/effect metadata. New named-strain crops start at N/P/K zero.

For bud-bearing named strains:

- Exact N/P/K target: THC and CBD double (maximum 100), yield x3.
- All nutrients within ±3 but not all exact: yield x2.
- Any nutrient more than 3 points off: yield x1.
- Off-target potency is reduced by rounded 10% per total nutrient point of difference, with a floor of half the base value (minimum 1).

The 17 fertilizer item definitions and their original N/P/K deltas are in `cultivation.lua`. Values clamp to 0–100. Tobacco has no NPK system in the Forge reference and therefore cannot receive these fertilizers.

## Grow Pot and lighting

The Grow Pot stores its inserted soil name and grows weed/hemp crops in a dedicated one-second ABM: a complete 10-age cycle takes 60 seconds on farmland and 90 seconds on other accepted soil, provided light level is at least 12. Bone meal advances 2–5 ages. Fertilizers affect the planted crop. Harvesting resets the crop to age zero while retaining the plant; sneak-right-click removes the crop and returns a seed. The pot can export harvest products to a recognised inventory below it, otherwise the crop remains ready for manual harvest.

Grow Lights search a 3x3 area up to five nodes below, require a clear vertical line of sight, and attempt two crop growth rolls every 100 game ticks. Reflectors accept HPS or Dual Arc lamps, emit light level 15, and attempt one growth roll every 100 game ticks. HPS and Dual Arc lamp lifetimes are 18,000 and 54,000 game ticks respectively.

When Elepower PAPI is installed, the existing Grow Lights use Elepower's machine registration and consume their configured usage from their local buffer. Without Elepower, their standalone toggle behaviour remains available. Reflectors use replaceable lamp items and do not require Elepower.

## External API

`smokyleaf_industry.get_crop_stats(pos)` returns a table containing family, strain, age, maximum age, THC/CBD, current N/P/K, optimal N/P/K, expected bud count, NPK state, Grow Pot membership, and pH. It returns `nil` for non-crop nodes.

## Local checks

The release was checked with:

1. Lua syntax parsing for `init.lua` and `cultivation.lua`.
2. A mocked Luanti registration load to validate item/node/ABM/LBM registration order.
3. A mocked behaviour harness for strain NPK/potency/yield, natural weed and hemp growth, tall-plant formation, 60/90-second Grow Pot cycles, tobacco ages, bone meal, fertilizer deltas, grow-light acceleration, and Plant Analyzer interactions.
4. PNG decoding/dimension validation and literal texture-reference checks.

These checks are not a substitute for launching the target Luanti game. Rendering, multiplayer behaviour, actual Elepower network transfer, and wall-clock tick behaviour must still be verified in-game.
