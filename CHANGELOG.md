# Smokeleaf Industries - Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-26

### Added

#### Core Features
- **25 Weed Strains** with unique properties:
  - Purple Kush, Northern Lights, Grandmaster Flash
  - Strawberry Cough, Critical Mass
  - Sour Diesel, Jack Herer, Green Crack
  - Pineapple Express, Durban Poison
  - OG Kush, Blue Dream, Girl Scout Cookies
  - Gorilla Glue, White Widow
  - Chemdawg, AK-47, Amnesia Haze
  - Super Lemon Haze, Trainwreck
  - Skywalker OG, Bruce Banner, Wedding Cake
  - Midnight Express, Cherry Pie

- **Plant Growth System**:
  - 8-stage growth progression for all plants
  - Light-level dependent growth
  - ABM-based natural growth cycles
  - Strain-specific growth times (65-108 minutes)

- **Hemp Cultivation**:
  - Full lifecycle from seeds to fiber
  - Hemp fiber processing
  - Hemp rope crafting
  - Hemp oil production

- **Tobacco Farming**:
  - Tobacco plant growth
  - Leaf harvesting
  - Tobacco leaf items for crafting

- **Infrastructure Blocks**:
  - LED Grow Light (light level 12)
  - HPS Grow Light (light level 14)
  - Grow Pot for indoor growing
  - Drying Rack for post-harvest processing
  - Processing Machine for advanced crafting

- **Consumable Items**:
  - Joints (rolled weed + paper)
  - Blunts (weed + tobacco)
  - Hash (concentrated buds)
  - Glass Bong
  - Grinder

- **Crafting Recipes**:
  - 25 strain-specific joint recipes
  - 25 strain-specific blunt recipes
  - Hemp rope from hemp fiber
  - Hash from concentrated buds
  - Drying recipes for fresh buds

- **Items & Drops**:
  - Weed buds (fresh and dried)
  - Hemp seeds and fiber
  - Tobacco seeds and leaves
  - All crafting materials

- **Effects System**:
  - Relaxation, Sleep, Happiness, Energy, Focus, Creativity, Pain Relief
  - Strain-specific effect combinations
  - Player metadata tracking for effect duration
  - Potency scaling based on strain

- **Documentation**:
  - Comprehensive README.md
  - Installation guide (INSTALL.md)
  - Texture specifications (textures/README.md)
  - API documentation in code
  - Changelog (this file)

- **Utilities**:
  - Texture generator script (Python)
  - Git-compatible project structure
  - MIT License for distribution
  - Localization support (minetest.get_translator)

### Technical

- **Node Registrations**: 200 plant nodes (25 strains × 8 stages)
- **Item Registrations**: 95 craftitems
- **Block Registrations**: 6 infrastructure blocks
- **Crafting Recipes**: 75+ shaped/shapeless recipes
- **ABMs**: 3 active block modifiers for plant growth
- **API Functions**: 5 public helper functions
- **Lua API Compliance**: Full Luanti 5.7+ compatibility

### Documentation

- mod.conf with proper metadata
- README with features, installation, and guides
- INSTALL.md with troubleshooting
- Detailed texture specifications
- License (MIT)
- This changelog

### Compatibility

- **Minimum Version**: Luanti 5.7.0
- **Recommended Version**: Luanti 5.8.0+
- **Optional Dependencies**: default, farming mods
- **Conflicts**: None known

## Future Versions

### [1.1.0] - Planned

- [ ] Villager trader NPCs
- [ ] Dealer and Stoner villagers with trades
- [ ] Advanced potion effects system
- [ ] Genetic breeding system for strains
- [ ] Disease and pest mechanics
- [ ] Modpack support improvements

### [1.2.0] - Planned

- [ ] Seasons integration
- [ ] Weather-dependent growth
- [ ] Hydroponics system
- [ ] Advanced greenhouse mechanics
- [ ] Custom particle effects for smoking
- [ ] Achievement/trophy system

### [1.3.0] - Planned

- [ ] Mod storage for farm data persistence
- [ ] Player skill progression
- [ ] Economy integration with other mods
- [ ] Territory/land claim support
- [ ] Multi-block machines with GUIs
- [ ] Automation possibilities

### [2.0.0] - Long Term

- [ ] 3D plant models (if Luanti supports)
- [ ] Animated growth sequences
- [ ] Full physics modification for effects
- [ ] Multiplayer trading system
- [ ] Raid/farming risk mechanics
- [ ] Complete economy overhaul

## Known Issues

- None in initial release
- Texture generation requires Python 3.6+ with PIL
- Some Minecraft-specific mechanics adapted for Luanti
- Bong mechanics simplified (no complex animations yet)

## Migration Guide

### From Previous Versions

#### 0.9 → 1.0
- Fresh install required (mod didn't exist)
- No migration needed
- World compatible with no prior data

## Removed (N/A for 1.0)

No features removed in initial release.

## Deprecated (N/A for 1.0)

No deprecated features in initial release.

## Breaking Changes (N/A for 1.0)

No breaking changes in initial release.

## Development Notes

### Architecture Decisions

1. **ABM-based Growth**: Chosen over node timers for efficiency across many plants
2. **Metadata for Effects**: Uses player metadata rather than status effects
3. **Simplified Processing**: Manual crafting instead of GUI-based machines
4. **Texture Placeholder Generator**: Python script for quick testing
5. **No Dependencies**: Optional defaults/farming for compatibility

### Performance Considerations

- ABM interval tuned for 100+ TPS servers
- Light checks prevent unnecessary growth processing
- Efficient node registration (single registration per plant type)
- Lazy loading of strain data
- No expensive loops in main tick

### Future Architecture Plans

- Move to GUI-based machines with inventories
- Integration with Luanti's mod storage API
- Optional MineClone2 compatibility
- Server-side villager trading system
- WebUI for farm statistics

## Credits

### Original Work

- **Minecraft Mod**: Micaxs - SmokeleafIndustries (NeoForge)
- **Luanti Port**: Community Development

### Contributors

- Texture artists (pending)
- Translators (pending)
- Testers and debuggers (pending)

### Acknowledgments

- Luanti (Minetest) development team
- ContentDB platform
- Modding community feedback

## Links

- **GitHub**: https://github.com/luanti-org/smokeleaf_industries
- **ContentDB**: https://content.luanti.org/packages/smokeleaf_industries
- **Documentation**: https://luanti.org/docs/mod/smokeleaf_industries
- **Forum Discussion**: https://github.com/minetest/minetest/discussions

## License

This project is licensed under the MIT License - see LICENSE file for details.

---

**Last Updated**: October 26, 2026
**Current Version**: 1.0.0
**Next Release Target**: December 2026
**Maintenance Status**: Active Development
