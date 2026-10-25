# Smokeleaf Industries - Installation Guide

Complete step-by-step guide to install and setup Smokeleaf Industries mod for Luanti.

## Prerequisites

- **Luanti** (formerly Minetest) version 5.7.0 or newer
- **Operating System**: Windows, macOS, Linux, or other Unix-like systems
- **Hard Drive Space**: ~50 MB for mod and textures
- **Optional**: Python 3.6+ for generating placeholder textures

## Quick Installation

### Method 1: From ContentDB (Recommended)

1. Open **Luanti**
2. Go to **Content** tab → **Browse Online Content**
3. Search for **"smokeleaf_industries"**
4. Click **Install**
5. Restart Luanti
6. Create new world and enable mod

### Method 2: Manual Installation

#### Step 1: Locate Your Mods Folder

**Windows:**
```
C:\Users\[YourUsername]\AppData\Roaming\Minetest\mods
```
or
```
%APPDATA%\Minetest\mods
```

**macOS:**
```
~/Library/Application Support/Minetest/mods
```

**Linux:**
```
~/.minetest/mods
```

**FreeBSD/OpenBSD:**
```
~/.minetest/mods
```

#### Step 2: Copy Mod Folder

1. Download or clone the `smokeleaf_industries` folder
2. Copy it to your mods directory
3. Ensure folder structure is: `mods/smokeleaf_industries/init.lua`

#### Step 3: Generate Textures (Optional but Recommended)

If textures are missing, generate placeholders:

```bash
cd smokeleaf_industries
python3 generate_textures.py
```

**Requirements for texture generation:**
```bash
pip install Pillow
```

#### Step 4: Enable in World

1. Open **Luanti**
2. **Select World** → **World Options** (gear icon)
3. **Mods** tab
4. Find **Smokeleaf Industries** in the list
5. Click checkbox to **enable**
6. Close and play!

## Verification

After installation, verify the mod loaded:

1. Load your world
2. Open **Chat** (T key by default)
3. Type: `/help`
4. Look for smokeleaf_industries commands

Or check server logs:
```
[ACTION] [Smokeleaf Industries] Mod loaded successfully!
[ACTION] [Smokeleaf Industries] 25 weed strains registered
```

## Texture Setup

### Option A: Auto-Generate (Easiest)

```bash
cd smokeleaf_industries
python3 generate_textures.py
```

This creates all 70+ placeholder textures automatically.

**Requirements:**
```bash
# Windows
pip install Pillow

# macOS
pip3 install Pillow

# Linux
sudo apt-get install python3-pil  # Debian/Ubuntu
sudo pacman -S python-pillow      # Arch
```

### Option B: Create Custom Textures

1. Read `textures/README.md` for specifications
2. Create 16x16 PNG files
3. Place in `textures/` folder
4. Naming convention: `smokeleaf_industries_[type]_[variant].png`

### Option C: Use Community Textures

Community members may share texture packs:
1. Download texture pack folder
2. Place in mod's `textures/` directory
3. Overwrite default placeholder textures

## Multiplayer Server Setup

### For Server Administrators

1. Copy `smokeleaf_industries` folder to server mods directory:
```
[server]/mods/smokeleaf_industries/
```

2. Edit `minetest.conf`:
```conf
# Add if not present
secure.trusted_mods = smokeleaf_industries
```

3. Restart server

4. Clients can play with or without mod (mod provides content)

### For Server Players

- Mod content will auto-download from server
- No manual installation needed
- Just join the server

## Troubleshooting

### Mod Not Appearing in Mods List

**Problem**: Smokeleaf Industries doesn't show in mods list

**Solutions**:
1. Check folder path is correct: `mods/smokeleaf_industries/`
2. Verify `mod.conf` exists in root folder
3. Check for typos in `mod.conf`
4. Restart Luanti completely
5. Try deleting `.minetest/cache` folder

### Missing Textures (Purple/Black Checkerboard)

**Problem**: Items and blocks show as purple-black checkered pattern

**Solutions**:
1. Run texture generator: `python3 generate_textures.py`
2. Verify `textures/` folder exists and has PNG files
3. Check file permissions (files should be readable)
4. Restart Luanti

### Mod Crashes on Load

**Problem**: Game crashes when world loads

**Solutions**:
1. Check Luanti version is 5.7.0+:
   - Menu → About Minetest → Note version
2. Check mod.conf dependencies are met:
   - `depends =` (no dependencies)
   - `optional_depends = default, farming`
3. Look in debug.txt for error:
   - Windows: `%APPDATA%\Minetest\debug.txt`
   - Linux: `~/.minetest/debug.txt`
4. Disable other mods to isolate issue
5. Report bug with debug.txt contents

### Game Very Slow / Lag

**Problem**: FPS drops significantly with mod enabled

**Solutions**:
1. Reduce ABM (plant growth) frequency:
   - Edit `init.lua` line ~250
   - Increase `interval` values
2. Use fewer plants in world
3. Disable other mods
4. Increase Luanti's `active_block_range`:
   - Edit minetest.conf:
   ```conf
   active_block_range = 2
   ```
5. Check available RAM (close other programs)

### "Unknown item" Error

**Problem**: Items show as "unknown item"

**Solutions**:
1. Disable all other mods temporarily
2. Delete `.minetest/cache` folder
3. Restart Luanti
4. Verify init.lua has no syntax errors:
   - Open with text editor
   - Check for mismatched quotes/brackets
5. Check Luanti console for error messages

## Advanced Configuration

### Adjusting Growth Speed

Edit `init.lua`:

```lua
-- Line ~20
local PLANT_GROWTH_STAGES = 8      -- Number of growth stages
local GROWTH_CHANCE = 3             -- 1 in X chance per cycle
local HEMP_GROWTH_SPEED_MULTIPLIER = 1.2  -- Faster hemp
```

Lower `GROWTH_CHANCE` = faster growth
Higher `GROWTH_CHANCE` = slower growth

### Custom Strain Parameters

Edit strain definition in `init.lua` (~line 30):

```lua
{
    name = "my_strain",
    title = S("My Custom Strain"),
    color = 0xFFFFFF,              -- Hex color
    growth_time = 80,              -- Minutes per stage
    potency = 0.85,                -- Effect strength (0-1)
    effects = {"relaxation"},      -- Effect types
    yield_multiplier = 1.1         -- Harvest amount
}
```

### Mod Dependencies

To make other mods depend on Smokeleaf:

```lua
-- In another mod's mod.conf
depends = smokeleaf_industries
```

Then access in Lua:
```lua
local strain = smokeleaf_industries.get_strain_info("purple_kush")
```

## Updating the Mod

### From Version X to Latest

1. Backup your world:
   ```
   Copy entire world folder to safe location
   ```

2. Remove old mod:
   ```
   Delete smokeleaf_industries/ folder
   ```

3. Install new version:
   ```
   Copy new smokeleaf_industries/ folder
   ```

4. Restart Luanti

5. Check changelog for breaking changes

**Important**: Worlds with plants will keep existing plants, but new features require playing with new mod version.

## Uninstalling

### Remove Completely

1. Delete `mods/smokeleaf_industries/` folder
2. Delete any world data (optional):
   ```
   This leaves world playable but without mod content
   ```

### Keep Game Worlds Intact

Remove mod but keep existing plants as decorative blocks:
1. Delete smokeleaf_industries folder
2. Existing plants in worlds remain as blocks
3. Crafting recipes no longer available

## Getting Help

### Support Resources

- **GitHub Issues**: https://github.com/smokeleaf_industries/issues
- **Luanti Forums**: https://github.com/minetest/minetest/discussions
- **ContentDB Comments**: Leave feedback on mod page
- **Community Discord**: Luanti modding communities

### Reporting Bugs

Include:
1. Luanti version
2. Operating system
3. Complete error from `debug.txt`
4. Steps to reproduce
5. Screenshot if applicable

### Contributing

- Submit texture improvements
- Translations
- Bug fixes via pull requests
- Feature suggestions via issues

## Next Steps

After installation:

1. **Read Documentation**: Open README.md
2. **Create World**: Start new world with mod enabled
3. **Find Seeds**: Search for weed/hemp/tobacco seeds
4. **Start Growing**: Plant and watch them grow!
5. **Craft Items**: Dry buds and make joints
6. **Explore**: Try different strains

## FAQ

**Q: Can I use this mod with other mods?**
A: Yes! No conflicts with default mods. Works with farming mods.

**Q: Does this work in survival?**
A: Yes! Full survival experience with progression.

**Q: Can I modify textures?**
A: Yes! Replace PNG files in textures/ folder.

**Q: Will it work on my server?**
A: Yes! Server-side mod, auto-downloads to clients.

**Q: Do I need anything else to play?**
A: No! Just Luanti 5.7.0+ and the mod.

**Q: Can I create my own strains?**
A: Yes! Edit weed_strains table in init.lua.

---

**Last Updated**: October 2026
**Installation Guide Version**: 1.0.0
**Compatible Versions**: Luanti 5.7.0+
