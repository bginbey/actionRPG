package utils;

import h2d.Bitmap;
import h2d.Tile;
import h3d.mat.Texture;

class TilesetGenerator {
    public static function createTestTileset():Tile {
        var size = 64; // 4x4 tiles at 16x16 each
        var pixels = hxd.Pixels.alloc(size, size, hxd.PixelFormat.RGBA);
        
        // Tile 0: Empty (transparent)
        drawTile(pixels, 0, 0, 0x00000000);
        
        // Tile 1: Wall (dark gray)
        drawTile(pixels, 1, 0, ColorPalette.DARK_GRAY);
        
        // Tile 2: Floor pattern (gray)
        drawTileWithPattern(pixels, 2, 0, ColorPalette.GRAY, ColorPalette.DARK_GRAY);
        
        // Tile 3: Special tile (blue)
        drawTile(pixels, 3, 0, ColorPalette.DARK_BLUE);
        
        var texture = Texture.fromPixels(pixels);
        return Tile.fromTexture(texture);
    }
    
    static function drawTile(pixels:hxd.Pixels, tileX:Int, tileY:Int, color:Int) {
        var startX = tileX * 16;
        var startY = tileY * 16;
        
        for (y in 0...16) {
            for (x in 0...16) {
                pixels.setPixel(startX + x, startY + y, color | 0xFF000000);
            }
        }
    }
    
    static function drawTileWithPattern(pixels:hxd.Pixels, tileX:Int, tileY:Int, color1:Int, color2:Int) {
        var startX = tileX * 16;
        var startY = tileY * 16;
        
        for (y in 0...16) {
            for (x in 0...16) {
                var color = ((x + y) % 4 == 0) ? color2 : color1;
                pixels.setPixel(startX + x, startY + y, color | 0xFF000000);
            }
        }
    }
}