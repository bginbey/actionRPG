package ui;

import h2d.Text;
import h2d.Font;

class PixelText extends Text {
    public static var defaultPixelFont: Font;
    
    public function new(?parent: h2d.Object, ?font: Font) {
        if (font == null) {
            font = getDefaultPixelFont();
        }
        super(font, parent);
        
        // Pixel-perfect rendering
        smooth = false;
    }
    
    static function getDefaultPixelFont(): Font {
        if (defaultPixelFont == null) {
            // Use Heaps' default font but configure it for pixel rendering
            defaultPixelFont = hxd.res.DefaultFont.get();
        }
        return defaultPixelFont;
    }
    
    public function setPixelScale(scale: Int = 1): Void {
        // Ensure text renders at integer scales
        scaleX = scaleY = scale;
        x = Math.floor(x);
        y = Math.floor(y);
    }
}