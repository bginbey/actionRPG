package systems.effects.particles;

import h2d.Bitmap;
import h2d.Tile;

/**
 * Individual particle with physics and rendering
 */
class Particle extends Bitmap {
    // Position and movement
    public var px:Float = 0;
    public var py:Float = 0;
    public var vx:Float = 0;  // Velocity X
    public var vy:Float = 0;  // Velocity Y
    
    // Physics
    public var friction:Float = 0.9;
    public var gravity:Float = 0;
    public var bounce:Float = 0;  // Bounce factor when hitting bounds
    
    // Lifecycle
    public var life:Float = 1.0;
    public var lifeDecay:Float = 1.0;  // Life lost per second
    public var isDead:Bool = true;
    
    // Visual properties
    public var startScale:Float = 1.0;
    public var endScale:Float = 0.0;
    public var startAlpha:Float = 1.0;
    public var endAlpha:Float = 0.0;
    public var startColor:Int = 0xFFFFFF;
    public var endColor:Int = 0xFFFFFF;
    
    // Rotation
    public var rotationSpeed:Float = 0;  // Radians per second
    
    public function new(tile:Tile, parent:h2d.Object) {
        super(tile, parent);
        visible = false;
    }
    
    public function spawn(x:Float, y:Float, velX:Float, velY:Float) {
        px = x;
        py = y;
        vx = velX;
        vy = velY;
        
        life = 1.0;
        isDead = false;
        visible = true;
        rotation = Math.random() * Math.PI * 2;
        
        updateVisuals();
    }
    
    public function update(dt:Float) {
        if (isDead) return;
        
        // Update physics
        vx *= Math.pow(friction, dt * 60);
        vy *= Math.pow(friction, dt * 60);
        vy += gravity * dt;
        
        px += vx * dt;
        py += vy * dt;
        
        // Update rotation
        rotation += rotationSpeed * dt;
        
        // Update life
        life -= lifeDecay * dt;
        if (life <= 0) {
            kill();
            return;
        }
        
        // Update position and visuals
        updateVisuals();
    }
    
    function updateVisuals() {
        // Position
        x = px;
        y = py;
        
        // Interpolate scale
        var t = 1.0 - life;  // 0 to 1 over lifetime
        var scale = startScale + (endScale - startScale) * t;
        setScale(scale);
        
        // Interpolate alpha
        alpha = startAlpha + (endAlpha - startAlpha) * t;
    }
    
    function lerpColor(c1:Int, c2:Int, t:Float):Int {
        var r1 = (c1 >> 16) & 0xFF;
        var g1 = (c1 >> 8) & 0xFF;
        var b1 = c1 & 0xFF;
        
        var r2 = (c2 >> 16) & 0xFF;
        var g2 = (c2 >> 8) & 0xFF;
        var b2 = c2 & 0xFF;
        
        var r = Math.round(r1 + (r2 - r1) * t);
        var g = Math.round(g1 + (g2 - g1) * t);
        var b = Math.round(b1 + (b2 - b1) * t);
        
        return (r << 16) | (g << 8) | b;
    }
    
    public function kill() {
        isDead = true;
        visible = false;
    }
}