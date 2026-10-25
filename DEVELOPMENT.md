# Smokeleaf Industries - Development Guide

Technical documentation for developers, contributors, and maintainers.

## Project Structure

```
smokeleaf_industries/
├── init.lua                 # Main mod - all game logic
├── mod.conf                 # Mod metadata and dependencies
├── LICENSE                  # MIT License
├── README.md               # User documentation
├── INSTALL.md              # Installation guide
├── CHANGELOG.md            # Version history
├── DEVELOPMENT.md          # This file
├── .gitignore              # Git ignore rules
├── generate_textures.py    # Texture generator utility
└── textures/
    ├── README.md           # Texture specifications
    └── [PNG texture files] # Game assets (70+ images)
```

## Code Architecture

### init.lua Organization

```lua
-- Lines 1-10: Header and module initialization
local S = minetest.get_translator("smokeleaf_industries")
smokeleaf_industries = {}

-- Lines 12-30: Constants
local PLANT_GROWTH_STAGES = 8
local GROWTH_CHANCE = 3

-- Lines 32-200: Strain Definitions
local weed_strains = { ... }
smokeleaf_industries.strains = {}

-- Lines 202-250: Item Registration
minetest.register_craftitem(...)
minetest.register_craftitem(...)

-- Lines 252-350: Node Registration (Plant Nodes)
for _, strain in ipairs(weed_strains) do
    for stage = 1, PLANT_GROWTH_STAGES do
        minetest.register_node(...)
    end
end

-- Lines 352-450: Block Registration (Infrastructure)
minetest.register_node("smokeleaf_industries:grow_pot", {...})

-- Lines 452-550: Crafting Recipes
minetest.register_craft({...})

-- Lines 552-700: ABMs (Active Block Modifiers)
minetest.register_abm({...})

-- Lines 702-750: Helper Functions
function smokeleaf_industries.get_strain_info(...) end

-- Lines 752-800: Initialization and Logging
minetest.log("action", "[Smokeleaf Industries] Mod loaded!")
```

## Key Systems

### 1. Strain Definition System

Each strain is a Lua table with:
```lua
{
    name = "strain_id",              -- Unique identifier
    title = S("Display Name"),        -- Localized display name
    color = 0xHEXCOLOR,             -- Hex color code
    growth_time = 80,               -- Minutes per stage
    potency = 0.85,                 -- Strength (0-1 scale)
    effects = {"effect1", "effect2"}, -- Available effects
    yield_multiplier = 1.1          -- Harvest amount
}
```

Access via: `smokeleaf_industries.strains[strain_name]`

### 2. Node Registration

**Plant Nodes** (per strain, per stage):
- Node name: `smokeleaf_industries:weed_[strain]_[stage]`
- Properties:
  - Drawtype: `plantlike` (2D sprite)
  - Sunlight propagates through
  - Walkable: false (can pass through)
  - Buildable to: true (can place liquid)
  - Groups: `flammable`, `plant`, `weed`/`hemp`/`tobacco`

**Infrastructure Nodes**:
- Grow Pot: Placeable container
- Grow Lights: Light sources with varying levels
- Drying Rack: Post-harvest processing
- Processing Machine: Advanced crafting

### 3. Growth System (ABM-Based)

**Active Block Modifiers**:
- Trigger conditions: Node type, neighbors, light level
- Interval: Tuned per plant (65-108 minutes base)
- Chance: 1 in X cycles (efficiency factor)
- Action: Advance growth stage if conditions met

**Growth Requirements**:
1. Node exists at correct stage
2. Neighbor has soil/dirt/grass
3. Light level ≥ 13
4. Random chance passes

**Example**:
```lua
minetest.register_abm({
    nodenames = {"smokeleaf_industries:weed_purple_kush_1"},
    neighbors = {"group:soil"},
    interval = 800,  -- Check every ~13 minutes
    chance = 3,      -- 1 in 3 chance per check
    action = function(pos, node)
        if minetest.get_node_light(pos) >= 13 then
            minetest.set_node(pos, {name = "smokeleaf_industries:weed_purple_kush_2"})
        end
    end,
})
```

### 4. Crafting Recipe System

**Item-to-Item Recipes**:
```lua
minetest.register_craft({
    output = "smokeleaf_industries:joint",
    recipe = {
        {"smokeleaf_industries:dried_buds_purple_kush", "default:paper"},
    }
})
```

**Bulk Recipes** (3×3 grid):
```lua
minetest.register_craft({
    output = "smokeleaf_industries:hash 1",
    recipe = {
        {"buds", "buds", "buds"},
        {"buds", "buds", "buds"},
        {"buds", "buds", "buds"},
    }
})
```

### 5. Effects System

Currently metadata-based:
```lua
local meta = player:get_meta()
meta:set_int("smokeleaf_potency", 85)
meta:set_int("smokeleaf_effects_time", 300)
```

Future: Integrate with potion effects or physics modifications.

## Adding New Features

### Add New Strain

1. **Edit init.lua** (~line 30):
```lua
{
    name = "my_strain",
    title = S("My Strain"),
    color = 0xFFFFFF,
    growth_time = 85,
    potency = 0.85,
    effects = {"relaxation", "happiness"},
    yield_multiplier = 1.1
}
```

2. **Create textures** (8 growth stages):
   - `smokeleaf_industries_weed_1.png` to `_8.png`
   - Place in `textures/` directory

3. **Automatic registration**:
   - Plants, items, recipes auto-generated from strain data
   - No manual node/item registration needed

4. **Test**:
   - Load Luanti
   - `/give @s smokeleaf_industries:seeds_my_strain 1`
   - Plant and verify growth

### Add New Crafting Recipe

1. **Edit init.lua** (~line 470):
```lua
minetest.register_craft({
    output = "smokeleaf_industries:new_item 1",
    recipe = {
        {"smokeleaf_industries:ingredient_1", "smokeleaf_industries:ingredient_2"},
        {"smokeleaf_industries:ingredient_3", "smokeleaf_industries:ingredient_4"},
    }
})
```

2. **Test**:
   - Craft in creative mode
   - Verify output appears correctly

### Add New Block Type

1. **Register node** (~line 350):
```lua
minetest.register_node("smokeleaf_industries:my_block", {
    description = S("My Block"),
    tiles = {
        "smokeleaf_industries_my_block_top.png",
        "smokeleaf_industries_my_block_bottom.png",
        "smokeleaf_industries_my_block_side.png",
    },
    paramtype2 = "facedir",
    groups = {snappy = 2, choppy = 2},
    sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})
```

2. **Create textures** (3 variants):
   - Top, bottom, side/front

3. **Add crafting recipe** if needed

### Adjust Growth Speed

1. **Global multiplier** (~line 16):
```lua
local GROWTH_CHANCE = 3  -- Higher = slower (1 in X)
```

2. **Per-strain in ABM** (~line 600):
```lua
interval = strain.growth_time * 10,  -- Multiply by factor
```

3. **Test**:
   - Plant seeds
   - Monitor growth progression
   - Adjust interval values until satisfied

## API Reference

### Public Functions

#### smokeleaf_industries.get_strain_info(strain_name)
Returns strain table for given name.
```lua
local strain = smokeleaf_industries.get_strain_info("purple_kush")
-- strain.potency = 0.9
-- strain.effects = {"relaxation", "sleep"}
```

#### smokeleaf_industries.get_all_strains()
Returns array of all strain tables.
```lua
local strains = smokeleaf_industries.get_all_strains()
-- returns table with 25 entries
```

#### smokeleaf_industries.is_plant_mature(nodename)
Check if plant node is at final stage.
```lua
if smokeleaf_industries.is_plant_mature(node.name) then
    -- Harvest buds
end
```

#### smokeleaf_industries.get_next_growth_stage(nodename)
Get next stage number for progression.
```lua
local next = smokeleaf_industries.get_next_growth_stage("weed_purple_kush_5")
-- next = 6
```

#### smokeleaf_industries.apply_smoking_effects(player, strain_name)
Apply effects when player consumes item.
```lua
smokeleaf_industries.apply_smoking_effects(player, "purple_kush")
-- Applies potency and effects to player
```

### Lua API Integration Points

**Other mods can:**
- Depend on smokeleaf_industries in their mod.conf
- Call public functions to check plant status
- Register on_use callbacks for custom items
- Hook into smoking system for effects
- Create new farming systems that integrate

**Example integration**:
```lua
-- In another mod's init.lua
depends = smokeleaf_industries

minetest.register_craftitem("my_mod:pipe", {
    on_use = function(itemstack, user, pointed_thing)
        smokeleaf_industries.apply_smoking_effects(user, "blue_dream")
        return itemstack
    end,
})
```

## Localization (i18n)

### Adding Translations

1. **Mark strings with S()**:
```lua
description = S("Purple Kush"),  -- Translatable
```

2. **Create translation file**:
   - `locale/en.txt` (English - base language)
   - `locale/fr.txt` (French)
   - `locale/de.txt` (German)
   - etc.

3. **Format** (`locale/fr.txt`):
```
Purple Kush=Mauvaise Pourpre
Joint=Article Commun
Hash=Haché
```

4. **Luanti loads automatically** for player locale

## Testing Checklist

### Unit Tests
- [ ] Each strain registers correctly
- [ ] All items appear in inventory
- [ ] All blocks placeable
- [ ] All crafting recipes work
- [ ] Plant growth progresses correctly

### Integration Tests
- [ ] Plants grow under natural light
- [ ] Plants grow under LED lights
- [ ] Plants grow under HPS lights
- [ ] Drying and processing works
- [ ] Smoking items produce effects
- [ ] Effects apply to correct players

### Performance Tests
- [ ] ABMs don't spam logs
- [ ] No FPS drops with many plants
- [ ] Server handles 100+ plants efficiently
- [ ] Multiplayer sync works correctly
- [ ] No memory leaks over time

### Compatibility Tests
- [ ] Works with vanilla Luanti
- [ ] Works with "default" mod enabled
- [ ] Works with "farming" mod enabled
- [ ] Works in singleplayer
- [ ] Works on dedicated server
- [ ] Works with other mods loaded

## Building & Packaging

### For ContentDB

1. **Verify structure**:
```bash
ls smokeleaf_industries/
# init.lua mod.conf LICENSE README.md INSTALL.md
```

2. **Remove unnecessary files**:
```bash
rm -f smokeleaf_industries/.gitignore
rm -f smokeleaf_industries/generate_textures.py
rm -f smokeleaf_industries/DEVELOPMENT.md
```

3. **Create ZIP**:
```bash
zip -r smokeleaf_industries.zip smokeleaf_industries/
```

4. **Upload to ContentDB**:
   - Go to https://content.luanti.org/
   - Create account / login
   - Upload ZIP file
   - Fill metadata form
   - Submit for review

### Release Checklist

- [ ] Version bumped in mod.conf
- [ ] CHANGELOG.md updated
- [ ] README.md current
- [ ] All textures present
- [ ] All recipes tested
- [ ] No debug output in code
- [ ] Code formatted consistently
- [ ] Comments added for complex logic

## Git Workflow

### Initial Setup
```bash
git init
git add .
git commit -m "Initial commit: Smokeleaf Industries 1.0.0"
```

### Development Branch
```bash
git checkout -b feature/new-strain
# ... make changes ...
git add .
git commit -m "Add new strain: my_strain"
git push origin feature/new-strain
```

### Release
```bash
git checkout main
git merge feature/new-strain
git tag v1.1.0
git push origin main --tags
```

## Common Issues & Solutions

### Strains Not Registering
- Check YAML syntax in strain table
- Verify all required fields present
- Look for typos in strain name
- Check debug.txt for Lua errors

### Plants Not Growing
- Verify ABM interval is reasonable
- Check light level >= 13
- Confirm soil neighbors exist
- Test with HPS light directly above plant

### Textures Not Loading
- Run `generate_textures.py` to create placeholders
- Check file names match exactly
- Verify PNG format (not JPG)
- Restart Luanti completely

### Crafting Not Working
- Check recipe output item exists
- Verify ingredient items registered
- Test in creative mode first
- Look for duplicate recipe registrations

### Server Lag
- Increase ABM interval values
- Reduce active_block_range in minetest.conf
- Disable other heavy mods
- Monitor server logs for errors

## Performance Profiling

### Finding Slow Code
```lua
local start_time = minetest.get_us_time()
-- ... code to test ...
local elapsed = (minetest.get_us_time() - start_time) / 1000000
minetest.log("action", "Elapsed: " .. elapsed .. " seconds")
```

### Optimizing ABMs
- Increase interval (less frequent checks)
- Add specific neighbor requirements
- Use group checks instead of individual nodes
- Limit nodenames list size

### Optimizing Item Counts
- 25 strains × 8 stages × 3 items = 600 items
- Reduce using texture variants instead
- Consider using item metadata for variations
- Batch registration if possible

## Contributing Guidelines

### Code Style

1. **Lua formatting**:
   - 4-space indentation
   - Consistent variable naming
   - Comments for complex logic
   - No trailing whitespace

2. **Naming conventions**:
   - Variables: `snake_case`
   - Functions: `snake_case`
   - Nodes: `smokeleaf_industries:item_name`
   - Groups: `group_name` (lowercase)

3. **Comments**:
   ```lua
   -- Section headers
   
   -- Description of what happens next
   local variable = value
   ```

### Pull Request Process

1. Fork repository
2. Create feature branch
3. Make changes with clear commits
4. Test thoroughly
5. Update CHANGELOG.md
6. Submit PR with description

### Reporting Issues

Include:
- Luanti version
- Operating system
- Steps to reproduce
- debug.txt contents
- Screenshots if relevant

## Future Development

### Planned Features
- [ ] Villager traders
- [ ] Genetic breeding
- [ ] Disease mechanics
- [ ] Greenhouse system
- [ ] Automation integration

### Long-term Vision
- Complete economic system
- Player progression/skills
- Multiplayer trading
- Territory/land system
- Full GUI-based machines

### Technology Goals
- Transition to node storage for data
- Implement custom effects system
- Add particle/visual effects
- Create modpack bundle
- Build community texture packs

## References

### Luanti Documentation
- https://docs.luanti.org/
- https://api.luanti.org/
- https://github.com/luanti-org/luanti/wiki

### Lua
- https://www.lua.org/manual/5.1/
- Programming in Lua book

### ContentDB
- https://content.luanti.org/
- https://contentdb.github.io/

---

**Last Updated**: October 2026
**Document Version**: 1.0
**Status**: Complete
