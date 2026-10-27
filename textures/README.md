# Smokeleaf Industries - Texture Guide

This directory contains all texture files for the Smokeleaf Industries mod. All textures should be PNG format, 16x16 pixels unless otherwise specified.

## Texture File Organization

```
textures/
├── blocks/           # Block/node textures (16x16)
│   ├── smokeleaf_industries_hemp_*.png
│   ├── smokeleaf_industries_tobacco_*.png
│   ├── smokeleaf_industries_weed_*.png
│   ├── smokeleaf_industries_grow_light_*.png
│   ├── smokeleaf_industries_grow_pot_*.png
│   ├── smokeleaf_industries_drying_rack_*.png
│   └── smokeleaf_industries_machine_*.png
│
├── items/            # Item/craftitem textures (16x16)
│   ├── smokeleaf_industries_buds.png
│   ├── smokeleaf_industries_dried_buds.png
│   ├── smokeleaf_industries_seeds.png
│   ├── smokeleaf_industries_hemp_*.png
│   ├── smokeleaf_industries_tobacco_*.png
│   ├── smokeleaf_industries_joint.png
│   ├── smokeleaf_industries_blunt.png
│   ├── smokeleaf_industries_hash.png
│   ├── smokeleaf_industries_glass_bong.png
│   └── smokeleaf_industries_grinder.png
│
└── README.md         # This file
```

## Required Textures

### Plant Textures (Growth Stages)

#### Weed Plants (8 stages, one per texture)
- `smokeleaf_industries_weed_1.png` - Sprout stage
- `smokeleaf_industries_weed_2.png` - Early growth
- `smokeleaf_industries_weed_3.png` - Growth stage
- `smokeleaf_industries_weed_4.png` - Mid-growth
- `smokeleaf_industries_weed_5.png` - Heavy growth
- `smokeleaf_industries_weed_6.png` - Pre-flowering
- `smokeleaf_industries_weed_7.png` - Flowering
- `smokeleaf_industries_weed_8.png` - Mature/Flowering (buds visible)

**Recommendation**: Create a progression from small seedling to large plant with visible flowers/buds in final stages.

#### Hemp Plants (8 stages)
- `smokeleaf_industries_hemp_1.png` through `smokeleaf_industries_hemp_8.png`
- Use lighter green color to differentiate from weed
- Final stage should show mature hemp stalk

#### Tobacco Plants (8 stages)
- `smokeleaf_industries_tobacco_1.png` through `smokeleaf_industries_tobacco_8.png`
- Use reddish-brown or dark green tone
- Should visually differ from cannabis plants

### Item Textures

#### Bud Items
- `smokeleaf_industries_buds.png` - Fresh green buds
- `smokeleaf_industries_dried_buds.png` - Dried/brown buds
- `smokeleaf_industries_seeds.png` - Small seeds (used for all strains)

#### Hemp Items
- `smokeleaf_industries_hemp_seeds.png` - Hemp seeds
- `smokeleaf_industries_hemp_fiber.png` - Processed hemp fiber
- `smokeleaf_industries_hemp_rope.png` - Twisted rope
- `smokeleaf_industries_hemp_oil.png` - Golden oil in bottle

#### Tobacco Items
- `smokeleaf_industries_tobacco_seeds.png` - Tobacco seeds
- `smokeleaf_industries_tobacco_leaves.png` - Dried tobacco leaves

#### Smoking Items
- `smokeleaf_industries_joint.png` - Rolled joint (white/beige)
- `smokeleaf_industries_blunt.png` - Blunt wrap (brown/tan)
- `smokeleaf_industries_glass_bong.png` - Glass bong (transparent blue)
- `smokeleaf_industries_grinder.png` - Metal grinder
- `smokeleaf_industries_hash.png` - Concentrated hash (dark brown)

### Block/Infrastructure Textures

#### Grow Pot
- `smokeleaf_industries_grow_pot_top.png` - Top view
- `smokeleaf_industries_grow_pot_bottom.png` - Bottom view
- `smokeleaf_industries_grow_pot_side.png` - Side view (clay pot texture)

#### LED Grow Light
- `smokeleaf_industries_led_light_on.png` - Emitting light (blue glow)
- `smokeleaf_industries_led_light_off.png` - Off state (dark blue)
- `smokeleaf_industries_led_light_side.png` - Side view

#### HPS Grow Light
- `smokeleaf_industries_hps_light_on.png` - Emitting light (yellow/orange glow)
- `smokeleaf_industries_hps_light_off.png` - Off state (dark orange)
- `smokeleaf_industries_hps_light_side.png` - Side view

#### Drying Rack
- `smokeleaf_industries_drying_rack_top.png` - Wooden frame top
- `smokeleaf_industries_drying_rack_bottom.png` - Wooden frame bottom
- `smokeleaf_industries_drying_rack_side.png` - Wooden slats

#### Processing Machine
- `smokeleaf_industries_machine_top.png` - Top surface (metal)
- `smokeleaf_industries_machine_bottom.png` - Bottom surface
- `smokeleaf_industries_machine_side.png` - Generic side
- `smokeleaf_industries_machine_front.png` - Front with display/controls
- `smokeleaf_industries_machine_back.png` - Back with vents

## Texture Design Guidelines

### Color Schemes

**Weed Plants**:
- Early stages: Light green (#90EE90)
- Mid stages: Medium green (#228B22)
- Late stages: Dark green with purple (#2F1B4C) highlights for maturity

**Hemp Plants**:
- Use 10-15% lighter green than weed
- Taller, thinner appearance
- Brown stem visible in later stages

**Tobacco Plants**:
- Reddish-green tone (#556B2F)
- Wider leaves than cannabis
- Brown/rust colored in mature stages

**Growth Stages General**:
- Stage 1: Single leaf, very small
- Stage 2-3: 2-3 leaves, small plant
- Stage 4-5: Full foliage, medium plant
- Stage 6-7: Dense foliage, large plant
- Stage 8: Mature with flowers/buds visible

### Technical Specifications

**Resolution**: 16x16 pixels (Luanti standard)
**Format**: PNG with transparency (alpha channel)
**Color Space**: sRGB
**Compression**: Lossless PNG compression recommended
**Texture Coordinates**: Full 16x16 space usage

### Design Tips

1. **Clarity**: Ensure pixels are clear and distinct at 16x16 size
2. **Color Contrast**: Use distinct colors to differentiate plant types
3. **Growth Progression**: Make size/detail increase obvious between stages
4. **Consistency**: Maintain consistent style across all textures
5. **Alpha Transparency**: Use for plant edges for natural look
6. **Test In-Game**: Always test textures in Luanti to verify appearance

## Creating Textures

### Using GIMP
1. Create new 16x16 image
2. Set grid to 1x1 pixel (View > Show Grid)
3. Use pencil/paintbrush tools
4. Save as PNG with transparency

### Using Aseprite
1. New sprite: 16x16 pixels
2. Use pixel-by-pixel drawing
3. Export as PNG

### Using Python/PIL
```python
from PIL import Image, ImageDraw

# Create 16x16 image
img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw your texture
draw.rectangle([4, 0, 11, 8], fill=(144, 238, 144, 255))  # Light green

img.save('texture.png')
```

### Using Piskel App (Web-based)
Online pixel art editor: https://www.piskelapp.com/
- No installation needed
- Export directly as PNG

## Texture Variants (Optional Enhancement)

For visual variety, you can create 2-3 texture variants per stage:
- `smokeleaf_industries_weed_1_a.png`
- `smokeleaf_industries_weed_1_b.png`
- `smokeleaf_industries_weed_1_c.png`

Then modify init.lua to randomly select variant per plant.

## Attribution & Licensing

If using textures from other sources:
1. Verify Creative Commons or similar license
2. Credit original artists in README
3. Ensure compatibility with MIT license
4. Keep all textures free/open-source

## Common Issues

**Issue**: Textures appear blurry
- **Solution**: Ensure 16x16 pixel size, no scaling in Gimp/editor

**Issue**: Plants look flat
- **Solution**: Add shading and highlights with darker/lighter pixels

**Issue**: Textures don't show
- **Solution**: Verify PNG format, RGBA color mode, correct file paths

**Issue**: Transparency not working
- **Solution**: Use Image > Mode > RGBA in GIMP before saving

## Future Improvements

- [ ] High-resolution texture variants (32x32)
- [ ] Texture packs for different art styles
- [ ] Animated plant growth (future Luanti feature)
- [ ] Season-specific textures
- [ ] Custom effects/overlays for mature plants

---

**Last Updated**: October 2026
**Status**: Texture specification for Luanti port v1.0.4
**Total Required Textures**: ~70+ PNG files
