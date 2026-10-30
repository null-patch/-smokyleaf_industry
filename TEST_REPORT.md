# v1.0.6 validation report

## Passed

- Lua syntax parsing: `init.lua`, `cultivation.lua`.
- Mocked Luanti module registration: expected 25 named strain definitions, the hemp/tobacco stages, upper crop halves, crop ABMs/LBMs, and cultivation items load without registration errors.
- Confirmed the Hemp Leaf item referenced by Hemp shearing and mature crop harvest is registered with its own texture; `hemp_fibers` remains an alias to the established `hemp_fiber` item ID.
- Corrected Grow Pot seed placement so existing crops cannot be overwritten even though Luanti crop nodes are `buildable_to`; Grow Pot field-placement now preserves the original soil pH default. Creative players no longer consume seeds.
- Mocked cultivation behaviour: original NPK/potency/yield rules, field weed natural-growth roll, hemp 3.5x growth multiplier, age-7 tall form, Grow Pot 60-second farmland cycle, Grow Pot 90-second soil cycle, 2–5 age bone meal, original fertilizer deltas, seven-age tobacco cycle, Grow Light crop acceleration, Plant Analyzer on field crop and Grow Pot.
- All 81 packaged PNG textures decoded successfully.
- All literal local PNG references resolve. The three generated grow-light texture suffixes (`_off`, `_on`, `_side`) were checked against the registered LED/HPS texture names.
- ZIP archive integrity checked before release.

## Not verified in this environment

No running Luanti server/client or test world was available. Actual world rendering, player inventory interaction, crop ABM timing under a live server, multiplayer protection, existing-world migration, and Elepower power-network transfer still require in-game testing. The one-second ABM approximation cannot guarantee Minecraft-identical wall-clock tick distribution under all server loads.
