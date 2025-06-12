# Sprite Sheet Layout Guide

If you prefer to work with sprite sheets instead of individual files, here's the recommended layout:

## Option A: Single Master Sheet (256x256 pixels)

```
    0   32  64  96  128 160 192 224
0   I1  I2  I3  I4  I5  I6  -   -    <- Idle (6 frames)
32  W1  W2  W3  W4  W5  W6  W7  W8   <- Walk (8 frames)  
64  D1  D2  D3  A11 A12 A13 A14 A15  <- Dash (3) + Attack1 (6, splits to next row)
96  A16 A21 A22 A23 A24 A25 A26 A31  <- Attack1 (cont) + Attack2 (6) + Attack3 (start)
128 A32 A33 A34 A35 A36 H1  H2  H3   <- Attack3 (cont) + Hurt (3)
160 X1  X2  X3  X4  X5  X6  -   -    <- Death (6 frames)
192 -   -   -   -   -   -   -   -    <- Reserved for future
224 -   -   -   -   -   -   -   -    <- Reserved for future
```

## Option B: Animation Strips (Recommended)

Create separate horizontal strips for each animation:

### player_idle_strip.png (192x32)
```
[I1][I2][I3][I4][I5][I6]
```

### player_walk_strip.png (256x32)
```
[W1][W2][W3][W4][W5][W6][W7][W8]
```

### player_dash_strip.png (96x32)
```
[D1][D2][D3]
```

### player_attack1_strip.png (192x32)
```
[A11][A12][A13][A14][A15][A16]
```

### player_attack2_strip.png (192x32)
```
[A21][A22][A23][A24][A25][A26]
```

### player_attack3_strip.png (192x32)
```
[A31][A32][A33][A34][A35][A36]
```

### player_hurt_strip.png (96x32)
```
[H1][H2][H3]
```

### player_death_strip.png (192x32)
```
[X1][X2][X3][X4][X5][X6]
```

## How to Convert from Individual Files to Sprite Sheet

If you've created individual files and want to combine them:

### Using ImageMagick (command line):
```bash
# Create horizontal strip
montage player_idle_*.png -tile 6x1 -geometry 32x32+0+0 -background transparent player_idle_strip.png

# Create full sprite sheet
montage player_*.png -tile 8x8 -geometry 32x32+0+0 -background transparent player_sprites.png
```

### Using Aseprite:
1. File → Import Sprite Sheet
2. Select all your individual PNGs
3. Set grid to 32x32
4. Export as single sheet

### Using Free Tools:
- **TexturePacker** (free version available)
- **Shoebox** (free sprite sheet tool)
- **Piskel** (free online pixel art editor)

## Integration Notes

### For Individual Files:
```haxe
// Load each frame
var idleFrames = [];
for (i in 1...7) {
    var bmp = hxd.Res.sprites.player.idle['player_idle_0$i'].toBitmap();
    idleFrames.push(bmp);
}
```

### For Sprite Strips:
```haxe
// Load strip and split
var strip = hxd.Res.sprites.player.player_idle_strip.toTile();
var idleFrames = strip.split(6); // Split into 6 frames
```

### For Master Sheet:
```haxe
// Load sheet and define regions
var sheet = hxd.Res.sprites.player.player_sprites.toTile();
var idleFrames = [
    sheet.sub(0, 0, 32, 32),
    sheet.sub(32, 0, 32, 32),
    // etc...
];
```

## Sprite Naming Convention

If using individual files:
- `player_[state]_[frame].png`
- Frame numbers: 01, 02, 03 (always 2 digits)
- States: idle, walk, dash, attack1, attack2, attack3, hurt, death

If using strips:
- `player_[state]_strip.png`

If using master sheet:
- `player_sprites.png` or `player_all.png`

## Export Settings

### Photoshop/Aseprite:
- Color Mode: RGB
- Bit Depth: 32-bit (with alpha)
- No compression
- No interlacing
- Transparency: Enabled

### GIMP:
- Export as PNG
- 32-bit RGBA
- Compression level: 9 (doesn't affect quality)
- No interlacing
- Save background color: OFF

## Testing Your Sprite Sheet

1. Ensure no pixels bleed between frames
2. Keep 32x32 boundaries precise
3. Test in game with different scale factors
4. Verify transparent areas are fully transparent (alpha = 0)
5. Check that pivot points align across all frames