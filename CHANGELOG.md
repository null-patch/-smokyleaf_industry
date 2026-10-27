# Changelog

## 1.0.4
- Fixed Processing Machine and Drying Rack formspec element ordering and inventory screen sizing so the GUI is not collapsed into a thin line.
- Added optional Elepower PAPI integration for the Processing Machine and both grow lights.
- Processing Machine consumes 64 EU per successful process and displays its stored power.
- LED and HPS lights consume 8 EU/s and 16 EU/s, respectively, while enabled; they remain off until powered when Elepower is installed.
- Added new v1.0.4 migration IDs to refresh formspecs on existing blocks without resetting their inventories.
- Kept the Drying Rack unpowered to preserve its passive-drying behaviour from the Forge source.


## 1.0.3 - GUI clarity, recipe parity, and crop-growth fixes

- Rebuilt the Processing Machine screen with visible inventory-slot backplates, high-contrast panels, readable recipe hints, and input/output cycling.
- Added a 12-slot Drying Rack GUI, filtered inventory access, persistent contents, automatic bud/tobacco drying, and item drops when the rack is broken.
- Added dried tobacco leaves; drying durations match the original recipe values (about 60 seconds for generic buds and 15 seconds for tobacco leaves).
- Added ceiling mounting, ON/OFF variants, separate light levels/textures, protection checks, and periodic crop acceleration to LED/HPS lights.
- Matched the original Forge 3x3 joint/blunt ingredient patterns in the Processing Machine while retaining the port's simple compatibility recipes.
- Bumped migration IDs to v1.0.3 so previously initialized machines and racks receive the updated formspecs.
- Fixed Lua loop-capture issues that could cause seeds or growth callbacks to use the wrong strain/stage.
- Added migration LBMs for machines and racks already placed in existing worlds.
- Added Grow Pot to the soil group and retained planting seeds directly on top of it.

## 1.0.1 - Seed placement and texture fixes

- Fixed seed placement on dirt, grass, farmland, common farming soil nodes, and Grow Pot.
- Corrected block face textures for Grow Pot, Drying Rack, grow lights, and Processing Machine.
- Added the initial Processing Machine formspec and recipe handler.

## 1.0.0 - Initial Luanti port

- Added strain crops, seeds, hemp and tobacco cultivation, base items, blocks, and crafting recipes.
- Added initial grow light, Grow Pot, Drying Rack, and Processing Machine support.

> Scope note: the Lua mod does not yet reproduce every separate machine and advanced subsystem in the original NeoForge source.
