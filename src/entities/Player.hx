package entities;

import h2d.Bitmap;
import h2d.Tile;
import h2d.Anim;
import h2d.col.Circle;
import utils.ColorPalette;
import utils.SpriteGenerator;
import systems.CollisionWorld;

class Player extends Entity {
    var collisionWorld:CollisionWorld;
    
    // Movement
    public var moveSpeed:Float = 120.0;  // Pixels per second
    public var isMoving:Bool = false;
    public var facingRight:Bool = true;
    
    // Input
    var inputDx:Float = 0;
    var inputDy:Float = 0;
    
    // Debug info
    public var lastHitX:Bool = false;
    public var lastHitY:Bool = false;
    public var desiredDx:Float = 0;
    public var desiredDy:Float = 0;
    public var lastCornerPush:{x:Float, y:Float} = {x: 0, y: 0};
    
    public function new(parent:h2d.Object, collisionWorld:CollisionWorld) {
        super(parent);
        this.collisionWorld = collisionWorld;
        
        // Create sprite sheet
        var spriteSheet = SpriteGenerator.createPlayerSpriteSheet();
        
        // Create animation tiles
        var tiles:Array<Tile> = [];
        
        // Idle frame
        tiles.push(spriteSheet.sub(0, 0, 32, 32));
        
        // Walk frames
        for (i in 0...4) {
            tiles.push(spriteSheet.sub(i * 32, 0, 32, 32));
        }
        
        // Create animated sprite
        anim = new Anim(tiles, 8, this);
        anim.x = -16;  // Center the 32x32 sprite
        anim.y = -16;
        anim.pause = true;
        anim.currentFrame = 0;
        
        // Set collision radius
        setColliderRadius(12);
    }
    
    public function setInput(dx:Float, dy:Float) {
        inputDx = dx;
        inputDy = dy;
        isMoving = dx != 0 || dy != 0;
        
        // Update facing direction
        if (dx > 0) facingRight = true;
        else if (dx < 0) facingRight = false;
    }
    
    override function update(dt:Float) {
        // Calculate desired velocity based on input
        desiredDx = inputDx * moveSpeed * dt;
        desiredDy = inputDy * moveSpeed * dt;
        
        // Check collision and get safe position
        if (desiredDx != 0 || desiredDy != 0) {
            var resolved = collisionWorld.resolveCircleCollision(collider, desiredDx, desiredDy);
            px = resolved.x;
            py = resolved.y;
            lastHitX = resolved.hitX;
            lastHitY = resolved.hitY;
            lastCornerPush = resolved.cornerPush;
            
            // Set actual velocity for animation purposes
            dx = resolved.x - collider.x;
            dy = resolved.y - collider.y;
        } else {
            dx = 0;
            dy = 0;
            lastHitX = false;
            lastHitY = false;
            lastCornerPush = {x: 0, y: 0};
        }
        
        // Handle animations
        if (isMoving && (dx != 0 || dy != 0)) {
            // Play walk animation
            if (anim.pause) {
                anim.pause = false;
                anim.currentFrame = 1;
            }
        } else {
            // Stop at idle frame
            if (!anim.pause) {
                anim.pause = true;
                anim.currentFrame = 0;
            }
        }
        
        // Update position and sprite facing
        updatePosition();
        scaleX = facingRight ? 1 : -1;
    }
}