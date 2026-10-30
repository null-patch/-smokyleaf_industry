# Changelog

## 1.0.6 — Original-style cultivation

- Replaced fabricated per-strain growth timers with the original 11-age weed/hemp cycle and 7-age tobacco cycle.
- Added the original two-block-tall weed/hemp form beginning at age 7.
- Restored the original crop random-growth probability formula, soil/spacing growth-speed calculation, tobacco light threshold, and 3.5× natural hemp growth multiplier.
- Added all 25 original strain presets with THC, CBD, N/P/K targets, and strain tint data.
- Added the 17 original fertilizer items with their original N/P/K deltas, crop nutrient tracking, ±3 nutrient tolerance, potency adjustment, and harvest multipliers.
- Added a Plant Analyzer formspec showing plant age, progress, potency, NPK targets, yield multiplier, and pH.
- Restored Grow Pot soil insertion, direct seed planting, the 60-second farmland / 90-second other-soil growth cycle, fertilizer, bone meal (2–5 ages), mature harvesting without destroying the pot, and sneak-to-remove-soil behaviour.
- Added original-style hemp shearing progression: three leaf harvests followed by a full crop harvest.
- Added ceiling-mounted Reflectors with HPS and Dual Arc lamps, 15/45-minute lamp life, light level 15, and crop acceleration.
- Corrected Grow Light acceleration to use the active node variants, original crop search volume, line-of-sight check, 100-tick cycle, and per-attempt growth probability.
- Added new pixel-art icons/textures for fertilizer items, Plant Analyzer, Reflector, and replacement lamps.
- Added migration for older stage-8 crops and old tobacco stage-8 nodes; retained aliases for earlier placeholder strain IDs.
- Updated family-specific mature-stage helper functions.
- Registered the missing Hemp Leaf harvest/shearing item and its pixel-art texture; added the original plural `hemp_fibers` compatibility alias.
- Prevented seeds from replacing an existing Grow Pot crop, preserved creative-mode seed stacks, and kept Grow Pot field-planted crops at the original pH default.

## 1.0.5
- Fixed an Elepower PAPI startup crash caused by passing a custom string to `ele_active_node`; the grow lights now use Elepower's supported automatic `_active` variant naming.
- Kept grow-light ON/OFF state switching, active texture/light level, and power consumption linked to the registered active variant.
- Added a node alias for worlds that saved the older `_on` grow-light node name.

## 1.0.4
- Fixed Processing Machine and Drying Rack formspec element ordering and inventory screen sizing.
- Added optional Elepower PAPI integration for the Processing Machine and Grow Lights.
- Processing Machine consumes 64 EU per successful process; LED/HPS lights consume 8/16 EU per second while enabled.

## 1.0.3
- Added a 12-slot Drying Rack GUI, automatic drying, and persistent rack contents.
- Improved Processing Machine GUI clarity and added basic recipes.
- Added the initial powered grow-light implementation.

## 1.0.1
- Fixed seed placement on dirt, grass, farmland, common farming soils, and Grow Pot.
- Corrected block textures.

## 1.0.0
- Initial Luanti port with strain items, crops, hemp, tobacco, Grow Pot, Grow Lights, Drying Rack, and Processing Machine.
