# Smokeleaf Industries - Luanti Mod

A Luanti (formerly Minetest) adaptation of Smokeleaf Industries, inspired by the original Minecraft NeoForge mod. This release includes 25 strain crops, seed planting, Grow Pot planting, ceiling-mounted ON/OFF grow lights, drying-rack processing, and a basic machine GUI. It is a feature-limited port, not a complete conversion of every Forge machine or advanced power/strain subsystem.

## Features

### Core Gameplay
- **25 Unique Weed Strains**: Each with unique growth times, potency levels, effects, and yield characteristics
  - Indica, Sativa, and Hybrid varieties
  - Realistic growth mechanics with varied maturation times
  - Custom effects system

- **Plant Growth System**
  - 8-stage growth progression for all plants
  - Dynamic growth based on light levels
  - Hemp and Tobacco cultivation alongside weed strains
  - ABM (Active Block Modifier) based natural growth cycles

- **Crafting & Processing**
  - Dry and process weed buds into smokable items
  - Create Joints and Blunts from dried buds
  - Extract hemp fiber from mature hemp plants
  - Craft rope from hemp fiber
  - Advanced hash production from multiple buds

- **Infrastructure Blocks**
  - LED and HPS Grow Lights for optimal cultivation
  - Grow Pots for indoor growing
  - Drying Racks for post-harvest processing
  - Processing Machine with an input/output GUI for drying buds and processing supported recipes

### Items & Consumables
- Dried Buds (all strains)
- Joints (basic rolling)
- Blunts (tobacco-wrapped)
- Hemp Oil and Hash
- Glass Bong
- Grinder
- Seeds for all strains

## Installation

1. Download the mod folder
2. Place it in your Luanti mods directory:
   - Linux: `~/.minetest/mods/`
   - Windows: `%APPDATA%\Minetest\mods\`
   - macOS: `~/Library/Application Support/Minetest/mods/`
3. Enable the mod in your world settings
4. Create a new world or add to existing world

## Weed Strains Reference

### Indica Strains (Fast Growing, Strong Effects)
- **Purple Kush** - Growth: 80 min | Potency: 0.9
- **Northern Lights** - Growth: 75 min | Potency: 0.85
- **Grandmaster Flash** - Growth: 70 min | Potency: 0.8
- **Strawberry Cough** - Growth: 85 min | Potency: 0.75
- **Critical Mass** - Growth: 65 min | Potency: 0.95 (Fastest)

### Sativa Strains (Slow Growing, Uplifting)
- **Sour Diesel** - Growth: 100 min | Potency: 0.8
- **Jack Herer** - Growth: 95 min | Potency: 0.85
- **Green Crack** - Growth: 92 min | Potency: 0.75
- **Pineapple Express** - Growth: 105 min | Potency: 0.8 (Slowest)
- **Durban Poison** - Growth: 98 min | Potency: 0.7

### Hybrid Strains (Balanced)
- **OG Kush** - Growth: 85 min | Potency: 0.9
- **Blue Dream** - Growth: 90 min | Potency: 0.8
- **Girl Scout Cookies** - Growth: 88 min | Potency: 0.88
- **Gorilla Glue** - Growth: 82 min | Potency: 0.95
- **White Widow** - Growth: 87 min | Potency: 0.85

### Specialty Strains
- **Chemdawg** - Growth: 86 min | Potency: 0.9
- **AK-47** - Growth: 79 min | Potency: 0.82
- **Amnesia Haze** - Growth: 108 min | Potency: 0.78
- **Super Lemon Haze** - Growth: 102 min | Potency: 0.76
- **Trainwreck** - Growth: 81 min | Potency: 0.88
- **Skywalker OG** - Growth: 84 min | Potency: 0.92
- **Bruce Banner** - Growth: 83 min | Potency: 0.91
- **Wedding Cake** - Growth: 89 min | Potency: 0.93
- **Midnight Express** - Growth: 76 min | Potency: 0.87
- **Cherry Pie** - Growth: 91 min | Potency: 0.84

## Basic Progression

1. **Obtain Seeds** - Craft or find weed seeds for your chosen strain
2. **Plant** - Place seeds on farmland, dirt, or directly on top of a Grow Pot with adequate lighting
3. **Grow** - Wait for plants to mature through 8 growth stages
4. **Harvest** - Break mature plants to collect buds
5. **Dry and process** - Right-click the Drying Rack with an empty hand to open its 12-slot GUI. Place fresh strain buds or tobacco leaves into slots and wait, then collect dried items. The Processing Machine has a separate 3×3 input grid and output slots. With Elepower installed, connect it to an Elepower generator/network; each successful process consumes 64 EU.
6. **Craft** - Create Joints, Blunts, or Hash for consumption
7. **Smoke** - Right-click smoking items to activate effects

## Growth Requirements

- **Light Level**: Natural growth requires at least light level 13; active grow lights also periodically accelerate crops directly beneath them
- **Soil**: Farmland, dirt, or grass blocks
- **Time**: Varies by strain (65-108 minutes per stage)
- **Water**: Available automatically near water blocks

## Lighting Options

- **LED Grow Light** - Mount directly beneath a solid ceiling, then right-click to enable; with Elepower installed, connect it to a power network. Active light level 12 and periodic crop-growth acceleration up to five blocks below
- **HPS Grow Light** - Mount directly beneath a solid ceiling, then right-click to enable; with Elepower installed, connect it to a power network. Active light level 14 and the same crop-growth acceleration
- **Natural Sunlight** - Free, requires outdoor farming

## Tips for Success

1. **Plant in organized rows** for efficient harvesting
2. **Use grow lights** to speed up indoor farming
3. **Separate strains** to avoid genetic mixing
4. **Build a drying area** near your farm for quick processing
5. **Experimental farming** - Try different strain combinations
6. **Consider yield** - Higher yield strains require more resources

## Crafting Recipes

### Joints
```
Dried Buds (any strain) + Paper → Joint
```

### Blunts
```
Dried Buds (any strain) + Tobacco Leaves → Blunt
```

### Hash
```
3x3 grid of Buds (any strain) → Hash
```

### Hemp Rope
```
3x Hemp Fiber → Hemp Rope
```

### Dried Buds
Processing mature plants yields dried buds ready for smoking

## File Structure

```
smokeleaf_industries/
├── init.lua                 # Main mod file with all registrations
├── mod.conf                 # Mod metadata
├── README.md               # This file
├── LICENSE                 # Mod license
└── textures/
    ├── blocks/             # Block textures
    ├── items/              # Item textures
    └── [texture files]     # Individual PNG files
```

## Texture Requirements

The mod requires the following textures (PNG format, 16x16):
- Weed plant stages (8 variants)
- Hemp plant stages (8 variants)
- Tobacco plant stages (8 variants)
- Bud and dried bud items
- All 25 strain seed items
- Infrastructure blocks (lights, racks, machines)
- Smoking items (joint, blunt)
- Hemp materials (fiber, rope, oil)
- Tobacco leaves

See `textures/README.md` for texture specifications.

## API Functions

### Accessing Strain Information
```lua
local strain = smokeleaf_industries.get_strain_info("purple_kush")
-- Returns: {name, title, color, growth_time, potency, effects, yield_multiplier}

local all_strains = smokeleaf_industries.get_all_strains()
-- Returns: Array of all strain tables
```

### Helper Functions
```lua
smokeleaf_industries.is_plant_mature(nodename)
-- Check if plant node is at final growth stage

smokeleaf_industries.get_next_growth_stage(nodename)
-- Get the next growth stage number for a plant

smokeleaf_industries.apply_smoking_effects(player, strain_name)
-- Apply visual/gameplay effects when smoking
```

## Gameplay Effects

When consuming smoked products:
- **Relaxation strains** - Slower movement, reduced damage
- **Energy strains** - Increased movement speed, faster mining
- **Focus strains** - Enhanced night vision effect
- **Sleep strains** - Effect duration longer, movement reduced
- **Creativity strains** - Special visual particle effects

## Multiplayer Considerations

- Mods work on servers with automatic client-side synchronization
- Plant growth is server-controlled
- Inventory items are managed per player
- Smoking effects apply only to consuming player

## Compatibility

- **Minimum Luanti Version**: 5.7.0
- **Optional Dependencies**: default, farming
- **Conflicts**: None known

## Performance Notes

- ABM-based growth is optimized for reasonable load
- 25 strains × 8 stages = 200 node registrations
- Light-based growth checks reduce unnecessary calculations
- Recommended for 100+ TPS server performance

## Expanding the Mod

### Adding New Strains
Edit the `weed_strains` table in `init.lua`:
```lua
{
    name = "my_strain",
    title = S("My Strain"),
    color = 0xFFFFFF,
    growth_time = 80,
    potency = 0.85,
    effects = {"relaxation", "happiness"},
    yield_multiplier = 1.1
}
```

### Adding New Crafting Recipes
Use Luanti's `minetest.register_craft()` in init.lua

### Custom Textures
Create 16x16 PNG files and place in `textures/` directory

## Known Limitations

- Villager traders not yet implemented (future update)
- RF/FE power system simplified for Luanti
- Some Minecraft-specific effects adapted for Luanti mechanics
- Bong smoking animation is simplified

## Future Updates

- [ ] Villager trader integration
- [ ] More advanced machine crafting system
- [ ] Genetic breeding system
- [ ] Disease and pest management
- [ ] Seasons integration
- [ ] Custom potion effects
- [ ] Mod storage for persistent farm data

## Credits

**Original Minecraft Mod**: Micaxs - SmokeleafIndustries
**Luanti Port**: Community Contribution
**Translators**: Community volunteers

## License

This mod is released under the MIT License. See LICENSE file for details.

## Support & Contributions

- Report bugs on GitHub Issues
- Suggest features via Discussions
- Submit textures and improvements via Pull Requests
- Translations welcome on translation platforms

## FAQ

**Q: Can I use this on a multiplayer server?**
A: Yes! Install on your server and it works for all players.

**Q: How fast do plants grow?**
A: Depends on strain. Fastest (Critical Mass) grows in ~65 minutes, slowest (Amnesia Haze) in ~108 minutes.

**Q: Can I trade with villagers?**
A: Villager system coming in next update. Currently craftable items only.

**Q: Do the effects actually do anything?**
A: Effects are registered in player metadata. Can be expanded with potion effects or physics modifications.

**Q: Can I automate the farming?**
A: Yes! Use Luanti's mechanical systems (hopper-like nodes) if compatible mods exist.

**Q: Is this balanced for survival?**
A: Yes, with progression from seeds → harvesting → crafting → consumption.

---

**Last Updated**: October 2026
**Version**: 1.0.3
**Status**: Updated port; in-game validation recommended


## Grow Light and Drying Rack behavior (v1.0.4)

- Right-click an LED or HPS Grow Light to switch it ON/OFF. OFF lights emit no light; ON lights use their on-state texture. Active lights periodically attempt to accelerate compatible weed, hemp, and tobacco crops in a 3x3 area up to five nodes beneath the lamp; opaque blocks in the crop column prevent acceleration.
- Right-click the Drying Rack with an empty hand to open its 12-slot interface. It accepts fresh strain buds and tobacco leaves, one item per slot. Buds dry in about 60 seconds; tobacco leaves dry in about 15 seconds. Remove completed items from their slots.
- The Grow Pot remains a plantable surface: use seeds on the top of the pot to place the crop in the space above it.
- This release completes the GUI, rack-drying, and grow-light behavior represented by these current Lua blocks. It is not a full one-to-one port of every separate Forge machine and advanced power/strain subsystem in the original Java mod.


## Elepower power support (v1.0.4)

Elepower is optional. When `elepower_papi` is enabled, connect the Processing Machine and an enabled grow light to an Elepower power network using Elepower power conduits and a generator/storage node. The Processing Machine uses 64 EU per successful process. LED lights use 8 EU/s and HPS lights use 16 EU/s while enabled. Right-click a light to request power; it will switch off automatically if its buffer runs out, then resume after power is restored. The Drying Rack remains passive and does not need electricity. Without Elepower, the Processing Machine and lights work without a power network as before.
