package entities;

import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Anim;
import h2d.col.Circle;

class Entity extends Object {
    // Simple position
    public var px:Float = 0;  // Pixel X position
    public var py:Float = 0;  // Pixel Y position
    
    public var dx:Float = 0;  // X velocity
    public var dy:Float = 0;  // Y velocity
    public var frictionX:Float = 0.82;
    public var frictionY:Float = 0.82;
    
    public var sprite:Bitmap;
    public var anim:Anim;
    
    // Collision
    public var collider:Circle;
    public var radius:Float = 8;  // Collision radius
    
    public var isAlive:Bool = true;
    
    public function new(parent:Object) {
        super(parent);
    }
    
    public function setColliderRadius(r:Float) {
        radius = r;
        if (collider != null) {
            collider.ray = r;
        } else {
            collider = new Circle(px, py, r);
        }
    }
    
    public function setPosPixel(x:Float, y:Float) {
        this.px = x;
        this.py = y;
        updatePosition();
    }
    
    public function setPosGrid(gx:Int, gy:Int) {
        this.px = (gx + 0.5) * 16;  // Center in tile
        this.py = (gy + 0.5) * 16;
        updatePosition();
    }
    
    function updatePosition() {
        x = px;
        y = py;
        if (collider != null) {
            collider.x = px;
            collider.y = py;
        }
    }
    
    public function update(dt:Float) {
        // Apply movement (collision handled by subclasses)
        px += dx;
        py += dy;
        
        // Apply friction
        dx *= Math.pow(frictionX, dt * 60);
        dy *= Math.pow(frictionY, dt * 60);
        
        // Clamp small velocities to zero
        if (Math.abs(dx) < 0.001) dx = 0;
        if (Math.abs(dy) < 0.001) dy = 0;
        
        updatePosition();
    }
    
    public function dispose() {
        remove();
    }
}