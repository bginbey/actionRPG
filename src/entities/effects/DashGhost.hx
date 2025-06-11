package entities.effects;

import h2d.Bitmap;
import h2d.Tile;

/**
 * A single ghost image that fades out over time
 * Used for dash trail effects
 */
class DashGhost extends Bitmap {
    var lifetime:Float;
    var maxLifetime:Float;
    var fadeSpeed:Float = 3.0;  // How fast the ghost fades
    
    public var isAlive:Bool = true;
    
    public function new(tile:Tile, parent:h2d.Object) {
        super(tile, parent);
        maxLifetime = 0.3;  // Ghost lasts 0.3 seconds
        lifetime = maxLifetime;
        // Center the ghost sprite
        this.tile.dx = -16;
        this.tile.dy = -16;
    }
    
    public function spawn(centerX:Float, centerY:Float, facingRight:Bool) {
        // Position at center coordinates
        this.x = centerX;
        this.y = centerY;
        this.scaleX = facingRight ? 1 : -1;
        this.alpha = 0.5;  // Start at 50% opacity
        lifetime = maxLifetime;
        isAlive = true;
        visible = true;
    }
    
    public function update(dt:Float) {
        if (!isAlive) return;
        
        lifetime -= dt;
        
        if (lifetime <= 0) {
            isAlive = false;
            visible = false;
            return;
        }
        
        // Fade out
        alpha = (lifetime / maxLifetime) * 0.5;
        
        // Optional: scale down slightly as it fades
        var scale = 1.0 + (1.0 - lifetime / maxLifetime) * 0.1;
        this.scaleY = scale;
        // Preserve facing direction while scaling
        this.scaleX = (this.scaleX < 0 ? -scale : scale);
    }
}