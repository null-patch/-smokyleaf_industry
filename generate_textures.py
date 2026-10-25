#!/usr/bin/env python3
"""
Smokeleaf Industries - Texture Generator
Generates placeholder textures for testing the mod.
Replace these with proper artistic textures for release.
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import sys

# Create textures directory if it doesn't exist
os.makedirs("textures", exist_ok=True)

def create_plant_texture(stage, plant_type="weed"):
    """Create a simple plant growth stage texture."""
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Color schemes per plant type
    colors = {
        'weed': {
            'early': (144, 238, 144, 255),    # Light green
            'mid': (34, 139, 34, 255),        # Forest green
            'late': (47, 27, 76, 255),        # Purple tinted
        },
        'hemp': {
            'early': (152, 251, 152, 255),    # Pale green
            'mid': (107, 142, 35, 255),       # Olive green
            'late': (101, 67, 33, 255),       # Brown
        },
        'tobacco': {
            'early': (169, 169, 169, 255),    # Dark gray-green
            'mid': (85, 107, 47, 255),        # Dark khaki
            'late': (139, 69, 19, 255),       # Brown
        }
    }
    
    color_scheme = colors.get(plant_type, colors['weed'])
    
    # Select color based on stage
    if stage <= 3:
        color = color_scheme['early']
        height = 4 + stage
    elif stage <= 6:
        color = color_scheme['mid']
        height = 8 + (stage - 3)
    else:
        color = color_scheme['late']
        height = 14
    
    # Draw simple plant shape (cone/triangle)
    width = 4 + stage
    x_center = 8
    
    # Draw plant from bottom up
    for i in range(height):
        progress = i / height
        current_width = int(width * (1 - progress * 0.3))
        left = x_center - current_width // 2
        right = left + current_width
        y = 16 - i - 1
        
        if left >= 0 and right <= 16:
            draw.line([(left, y), (right, y)], fill=color, width=1)
    
    # Add some visual variation
    if stage >= 6:
        # Add "buds" to mature stages
        draw.ellipse([6, 3, 10, 8], fill=(200, 100, 100, 255))
        draw.ellipse([7, 2, 11, 7], fill=(220, 120, 120, 255))
    
    return img

def create_item_texture(item_type):
    """Create simple item textures."""
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Different colors and shapes for different items
    textures = {
        'buds': {
            'color': (34, 139, 34, 255),
            'shape': 'circle',
            'desc': 'Fresh buds - green',
        },
        'dried_buds': {
            'color': (139, 90, 43, 255),
            'shape': 'circle',
            'desc': 'Dried buds - brown',
        },
        'seeds': {
            'color': (64, 64, 64, 255),
            'shape': 'small_circles',
            'desc': 'Seeds - dark',
        },
        'hemp_seeds': {
            'color': (139, 69, 19, 255),
            'shape': 'small_circles',
            'desc': 'Hemp seeds - tan',
        },
        'hemp_fiber': {
            'color': (218, 165, 32, 255),
            'shape': 'lines',
            'desc': 'Hemp fiber - golden',
        },
        'hemp_rope': {
            'color': (160, 120, 80, 255),
            'shape': 'spiral',
            'desc': 'Rope - brown',
        },
        'hemp_oil': {
            'color': (184, 134, 11, 255),
            'shape': 'liquid',
            'desc': 'Hemp oil - golden liquid',
        },
        'tobacco_seeds': {
            'color': (101, 67, 33, 255),
            'shape': 'small_circles',
            'desc': 'Tobacco seeds',
        },
        'tobacco_leaves': {
            'color': (85, 107, 47, 255),
            'shape': 'leaf',
            'desc': 'Tobacco leaves',
        },
        'joint': {
            'color': (240, 230, 200, 255),
            'shape': 'cone',
            'desc': 'Joint - light',
        },
        'blunt': {
            'color': (160, 110, 80, 255),
            'shape': 'cone',
            'desc': 'Blunt - brown',
        },
        'glass_bong': {
            'color': (100, 200, 255, 255),
            'shape': 'glass',
            'desc': 'Bong - blue glass',
        },
        'grinder': {
            'color': (128, 128, 128, 255),
            'shape': 'circle',
            'desc': 'Grinder - metal',
        },
        'hash': {
            'color': (60, 40, 20, 255),
            'shape': 'cube',
            'desc': 'Hash - dark brown',
        },
    }
    
    info = textures.get(item_type, {})
    color = info.get('color', (100, 100, 100, 255))
    shape = info.get('shape', 'circle')
    
    # Draw different shapes
    if shape == 'circle':
        draw.ellipse([2, 2, 14, 14], fill=color)
    elif shape == 'small_circles':
        draw.ellipse([3, 3, 8, 8], fill=color)
        draw.ellipse([8, 7, 13, 12], fill=color)
        draw.ellipse([5, 10, 10, 15], fill=color)
    elif shape == 'cone':
        draw.polygon([(8, 2), (4, 14), (12, 14)], fill=color)
    elif shape == 'leaf':
        draw.ellipse([4, 4, 12, 12], fill=color)
        draw.line([(4, 8), (12, 8)], fill=(color[0]-50, color[1]-50, color[2]-50, 255), width=1)
    elif shape == 'glass':
        draw.rectangle([4, 2, 12, 14], outline=color, width=2)
        draw.ellipse([5, 2, 11, 5], fill=(200, 230, 255, 100))
    elif shape == 'cube':
        draw.rectangle([3, 3, 13, 13], fill=color)
        draw.line([(3, 3), (8, 0), (13, 0), (13, 8)], fill=(color[0]+50, color[1]+50, color[2]+50, 255))
    elif shape == 'lines':
        for i in range(2, 15, 2):
            draw.line([(i, 2), (i-2, 14)], fill=color, width=1)
    elif shape == 'spiral':
        center = 8
        for i in range(1, 6):
            draw.arc([(center-i, center-i), (center+i, center+i)], 0, 360, fill=color, width=1)
    elif shape == 'liquid':
        draw.rectangle([3, 8, 13, 13], fill=color)
        draw.arc([(3, 3), (13, 13)], 0, 180, fill=color, width=2)
    
    return img

def create_block_texture(block_type):
    """Create simple block textures."""
    img = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    blocks = {
        'grow_pot': {
            'base': (160, 82, 45, 255),     # Brown
            'detail': (139, 69, 19, 255),   # Dark brown
        },
        'led_light': {
            'on': (0, 100, 255, 255),       # Blue
            'off': (50, 50, 100, 255),      # Dark blue
        },
        'hps_light': {
            'on': (255, 165, 0, 255),       # Orange
            'off': (100, 80, 50, 255),      # Dark orange
        },
        'drying_rack': {
            'color': (139, 90, 43, 255),    # Wood brown
        },
        'machine': {
            'base': (80, 80, 80, 255),      # Dark gray
            'detail': (120, 120, 120, 255), # Light gray
        },
    }
    
    # Draw based on block type
    if 'grow_pot' in block_type:
        # Pot shape
        colors = blocks['grow_pot']
        draw.rectangle([3, 2, 13, 13], fill=colors['base'])
        draw.line([(2, 13), (14, 13)], fill=colors['detail'], width=2)
    
    elif 'led_light' in block_type:
        colors = blocks['led_light']
        color = colors['on'] if 'on' in block_type else colors['off']
        draw.rectangle([2, 2, 14, 14], fill=color)
        draw.ellipse([4, 4, 12, 12], fill=(color[0]+50, color[1]+50, color[2]+50, 200))
    
    elif 'hps_light' in block_type:
        colors = blocks['hps_light']
        color = colors['on'] if 'on' in block_type else colors['off']
        draw.rectangle([2, 2, 14, 14], fill=color)
        draw.ellipse([4, 4, 12, 12], fill=(color[0]+50, color[1]+50, color[2]+50, 200))
    
    elif 'drying_rack' in block_type:
        # Wood slats
        color = blocks['drying_rack']['color']
        for i in range(0, 16, 3):
            draw.rectangle([i, 0, i+2, 16], fill=color)
        for i in range(0, 16, 4):
            draw.line([(0, i), (16, i)], fill=(color[0]-30, color[1]-30, color[2]-30, 255), width=1)
    
    elif 'machine' in block_type:
        colors = blocks['machine']
        # Metal block with detail
        draw.rectangle([1, 1, 15, 15], fill=colors['base'])
        draw.rectangle([2, 2, 14, 14], fill=colors['detail'])
        draw.rectangle([4, 4, 12, 12], fill=colors['base'])
        if 'front' in block_type:
            # Add control panel appearance
            draw.rectangle([5, 6, 11, 10], fill=(200, 100, 100, 255))
    
    return img

def main():
    """Generate all placeholder textures."""
    print("Generating Smokeleaf Industries placeholder textures...")
    
    # Generate plant textures (weed, hemp, tobacco - 8 stages each)
    for plant_type in ['weed', 'hemp', 'tobacco']:
        for stage in range(1, 9):
            filename = f"textures/smokeleaf_industries_{plant_type}_{stage}.png"
            img = create_plant_texture(stage, plant_type)
            img.save(filename)
            print(f"✓ {filename}")
    
    # Generate item textures
    items = [
        'buds', 'dried_buds', 'seeds', 'hemp_seeds', 'hemp_fiber', 'hemp_rope',
        'hemp_oil', 'tobacco_seeds', 'tobacco_leaves', 'joint', 'blunt',
        'glass_bong', 'grinder', 'hash'
    ]
    
    for item in items:
        filename = f"textures/smokeleaf_industries_{item}.png"
        img = create_item_texture(item)
        img.save(filename)
        print(f"✓ {filename}")
    
    # Generate block textures
    blocks = [
        'grow_pot_top', 'grow_pot_bottom', 'grow_pot_side',
        'led_light_on', 'led_light_off', 'led_light_side',
        'hps_light_on', 'hps_light_off', 'hps_light_side',
        'drying_rack_top', 'drying_rack_bottom', 'drying_rack_side',
        'machine_top', 'machine_bottom', 'machine_side', 'machine_front', 'machine_back'
    ]
    
    for block in blocks:
        filename = f"textures/smokeleaf_industries_{block}.png"
        img = create_block_texture(block)
        img.save(filename)
        print(f"✓ {filename}")
    
    print("\n✅ All textures generated successfully!")
    print("Note: These are placeholder textures. Replace with proper art for release.")
    print(f"Total textures created: {3*8 + len(items) + len(blocks)}")

if __name__ == "__main__":
    try:
        main()
    except ImportError:
        print("Error: PIL/Pillow not installed")
        print("Install with: pip install Pillow")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
