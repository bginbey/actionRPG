package systems;

import h2d.Object;
import h2d.col.Bounds;
import utils.GameConstants;

class Camera {
    public var x:Float = 0;
    public var y:Float = 0;
    public var viewWidth:Int;
    public var viewHeight:Int;
    
    // World bounds
    public var minX:Float = 0;
    public var minY:Float = 0;
    public var maxX:Float = Math.POSITIVE_INFINITY;
    public var maxY:Float = Math.POSITIVE_INFINITY;
    
    // Follow parameters
    public var target:Dynamic = null;
    public var followSpeed:Float = 5.0;  // Keep this as is since GameConstants has a different value
    public var deadZoneX:Float = 40;
    public var deadZoneY:Float = 30;
    
    // Shake parameters
    var shakeX:Float = 0;
    var shakeY:Float = 0;
    var shakeTrauma:Float = 0;
    var shakeDecay:Float = 0.8;
    var shakeMaxOffset:Float = GameConstants.CAMERA_SHAKE_INTENSITY;
    
    // Debug mode
    public var debugMode:Bool = false;
    var worldContainer:Object;
    
    public function new(worldContainer:Object, viewWidth:Int, viewHeight:Int) {
        this.worldContainer = worldContainer;
        this.viewWidth = viewWidth;
        this.viewHeight = viewHeight;
    }
    
    public function setBounds(minX:Float, minY:Float, maxX:Float, maxY:Float) {
        this.minX = minX;
        this.minY = minY;
        this.maxX = maxX;
        this.maxY = maxY;
    }
    
    public function setWorldBounds(worldWidth:Float, worldHeight:Float) {
        setBounds(0, 0, worldWidth - viewWidth, worldHeight - viewHeight);
    }
    
    public function follow(target:Dynamic) {
        this.target = target;
    }
    
    public function update(dt:Float) {
        // Follow target with smooth interpolation
        if (target != null && !debugMode) {
            var targetX = target.x - viewWidth * 0.5;
            var targetY = target.y - viewHeight * 0.5;
            
            // Apply dead zone
            var dx = targetX - x;
            var dy = targetY - y;
            
            if (Math.abs(dx) > deadZoneX) {
                x += (dx - (dx > 0 ? deadZoneX : -deadZoneX)) * followSpeed * dt;
            }
            
            if (Math.abs(dy) > deadZoneY) {
                y += (dy - (dy > 0 ? deadZoneY : -deadZoneY)) * followSpeed * dt;
            }
        }
        
        // Update shake
        if (shakeTrauma > 0) {
            shakeTrauma = Math.max(0, shakeTrauma - shakeDecay * dt);
            var shakeAmount = shakeTrauma * shakeTrauma;
            shakeX = (Math.random() * 2 - 1) * shakeMaxOffset * shakeAmount;
            shakeY = (Math.random() * 2 - 1) * shakeMaxOffset * shakeAmount;
        } else {
            shakeX = shakeY = 0;
        }
        
        // Clamp to bounds
        x = Math.max(minX, Math.min(maxX, x));
        y = Math.max(minY, Math.min(maxY, y));
    }
    
    public function shake(trauma:Float = GameConstants.CAMERA_SHAKE_DURATION) {
        shakeTrauma = Math.min(1, shakeTrauma + trauma);
    }
    
    public function apply() {
        // Apply camera transform to world container including shake
        worldContainer.x = Math.round(-x + shakeX);
        worldContainer.y = Math.round(-y + shakeY);
    }
    
    public function screenToWorld(screenX:Float, screenY:Float):{x:Float, y:Float} {
        return {
            x: screenX + x - shakeX,
            y: screenY + y - shakeY
        };
    }
    
    public function worldToScreen(worldX:Float, worldY:Float):{x:Float, y:Float} {
        return {
            x: worldX - x + shakeX,
            y: worldY - y + shakeY
        };
    }
    
    public function centerOn(x:Float, y:Float) {
        this.x = x - viewWidth * 0.5;
        this.y = y - viewHeight * 0.5;
        
        // Clamp to bounds
        this.x = Math.max(minX, Math.min(maxX, this.x));
        this.y = Math.max(minY, Math.min(maxY, this.y));
    }
}