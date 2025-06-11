package utils;

import h2d.Tile;
import h3d.mat.Texture;
import hxd.Pixels;

class SpriteGenerator {
    public static function createPlayerSpriteSheet():Tile {
        // Create a 128x128 texture for 4x4 grid of 32x32 sprites
        var size = 128;
        var pixels = Pixels.alloc(size, size, hxd.PixelFormat.RGBA);
        
        // Frame 0: Idle (facing right)
        drawPlayerFrame(pixels, 0, 0, false);
        
        // Frame 1: Walk frame 1
        drawPlayerFrame(pixels, 32, 0, false, 1);
        
        // Frame 2: Walk frame 2
        drawPlayerFrame(pixels, 64, 0, false, 2);
        
        // Frame 3: Walk frame 3
        drawPlayerFrame(pixels, 96, 0, false, 3);
        
        // Frames 4-7: Dash frames
        for (i in 0...4) {
            drawPlayerFrame(pixels, i * 32, 32, false, 0, true);
        }
        
        var texture = Texture.fromPixels(pixels);
        return Tile.fromTexture(texture);
    }
    
    static function drawPlayerFrame(pixels:Pixels, x:Int, y:Int, flipped:Bool = false, walkFrame:Int = 0, isDash:Bool = false) {
        // Colors
        var bodyColor = isDash ? ColorPalette.LIGHT_BLUE : ColorPalette.CYAN;
        var darkColor = ColorPalette.DARK_BLUE;
        var eyeColor = ColorPalette.WHITE;
        
        // Simple 32x32 character
        // Head (10x10)
        for (dy in 0...10) {
            for (dx in 0...10) {
                if ((dx > 1 && dx < 8) && (dy > 1 && dy < 8)) {
                    pixels.setPixel(x + dx + 11, y + dy + 4, bodyColor | 0xFF000000);
                }
            }
        }
        
        // Eyes
        pixels.setPixel(x + 14, y + 7, eyeColor | 0xFF000000);
        pixels.setPixel(x + 17, y + 7, eyeColor | 0xFF000000);
        
        // Body (12x12)
        for (dy in 0...12) {
            for (dx in 0...12) {
                if ((dx > 1 && dx < 10) && (dy > 0 && dy < 11)) {
                    pixels.setPixel(x + dx + 10, y + dy + 13, bodyColor | 0xFF000000);
                }
            }
        }
        
        // Arms (simple rectangles)
        for (i in 0...6) {
            // Left arm
            pixels.setPixel(x + 8, y + 15 + i, darkColor | 0xFF000000);
            pixels.setPixel(x + 9, y + 15 + i, darkColor | 0xFF000000);
            
            // Right arm
            pixels.setPixel(x + 22, y + 15 + i, darkColor | 0xFF000000);
            pixels.setPixel(x + 23, y + 15 + i, darkColor | 0xFF000000);
        }
        
        // Legs with walk animation
        var legOffset = walkFrame > 0 ? (walkFrame % 2 == 0 ? 2 : -2) : 0;
        
        // Left leg
        for (i in 0...6) {
            pixels.setPixel(x + 13, y + 24 + i, darkColor | 0xFF000000);
            pixels.setPixel(x + 14, y + 24 + i, darkColor | 0xFF000000);
        }
        
        // Right leg (animated)
        for (i in 0...6) {
            var yPos = y + 24 + i + (walkFrame > 0 ? legOffset : 0);
            if (yPos >= y && yPos < y + 32) {
                pixels.setPixel(x + 17, yPos, darkColor | 0xFF000000);
                pixels.setPixel(x + 18, yPos, darkColor | 0xFF000000);
            }
        }
    }
}