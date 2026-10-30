# Installation and update guide

## Requirements

- Luanti 5.7 or newer.
- Enable this mod in the world configuration.
- `default` is recommended; `farming` and `elepower_papi` are optional.

## Linux Flatpak installation

1. Close Luanti.
2. Back up the world you intend to update.
3. Remove the old `smokyleaf_industry` folder from:

   `~/.var/app/org.luanti.luanti/.minetest/mods/`

4. Extract the new `smokyleaf_industry` directory into that `mods` folder. The resulting path must end in `mods/smokyleaf_industry/init.lua`.
5. Start Luanti and enable Smokeleaf Industry for the world.
6. Enter the world and check `debug.txt` for startup errors.

For non-Flatpak Linux installations, the mods directory is commonly `~/.minetest/mods/`. Windows and macOS use the user mods directory supplied by their Luanti installation.

## Existing worlds

Version 1.0.6 includes one-time migration LBMs for older crops and Grow Pots. Back up your world and test on a copy first. Keep the mod enabled while the migration runs; do not remove it immediately after entering the world.

## Controls

- Plant seeds on dirt, farmland, supported soil, or a soil-filled Grow Pot.
- Right-click crops with fertilizers or bone meal.
- Use the Plant Analyzer on a crop or Grow Pot.
- Shear mature field hemp three times for leaves; the fourth shear harvests the crop.
- Right-click a mature Grow Pot crop to harvest without removing the planted crop.
- Sneak + right-click an empty Grow Pot to remove its soil.
- Right-click a Grow Light to toggle it.
- Right-click a Reflector with an HPS or Dual Arc lamp to install it; empty-hand right-click removes a partially used lamp.

## Elepower

When Elepower PAPI is installed, the existing Processing Machine and Grow Lights use Elepower power. The Reflector uses replaceable lamps instead. Without Elepower PAPI, the mod still loads and Grow Lights use their standalone toggle mode.

## Troubleshooting

If the mod fails to load, provide the complete error and the relevant `debug.txt` section. Do not install this version over an old folder by merging files; replace the folder after making a backup.
