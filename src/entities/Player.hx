package entities;

import h2d.Bitmap;
import h2d.Tile;
import h2d.Anim;
import h2d.col.Circle;
import utils.ColorPalette;
import utils.SpriteGenerator;
import utils.GameConstants;
import systems.CollisionWorld;
import entities.effects.GhostPool;

class Player extends Entity {
    var collisionWorld:CollisionWorld;
    var ghostPool:GhostPool;
    
    // Movement
    public var moveSpeed:Float = GameConstants.PLAYER_MOVE_SPEED;  // Pixels per second
    public var isMoving:Bool = false;
    public var facingRight:Bool = true;
    
    // Dash mechanics
    public var dashSpeed:Float = GameConstants.PLAYER_DASH_SPEED;  // Pixels per second during dash
    public var dashDuration:Float = GameConstants.PLAYER_DASH_DURATION;  // Dash lasts 0.15 seconds
    public var dashCooldown:Float = GameConstants.PLAYER_DASH_COOLDOWN;   // 0.5 second cooldown between dashes
    
    public var isDashing:Bool = false;
    var dashTime:Float = 0;
    var dashCooldownTime:Float = 0;
    var dashDirection:{x:Float, y:Float} = {x: 0, y: 0};
    var ghostSpawnTimer:Float = 0;
    var ghostSpawnInterval:Float = GameConstants.PLAYER_DASH_GHOST_INTERVAL;  // Spawn ghost every 0.02 seconds during dash
    
    // Input
    var inputDx:Float = 0;
    var inputDy:Float = 0;
    
    // Debug info
    public var lastHitX:Bool = false;
    public var lastHitY:Bool = false;
    public var desiredDx:Float = 0;
    public var desiredDy:Float = 0;
    public var lastCornerPush:{x:Float, y:Float} = {x: 0, y: 0};
    
    // Invincibility system
    public var isInvincible:Bool = false;
    var invincibilityTime:Float = 0;
    var invincibilityDuration:Float = GameConstants.PLAYER_INVINCIBILITY_DURATION;  // Default invincibility duration
    var invincibilityFlashInterval:Float = 0.1;  // Flash every 0.1 seconds
    var invincibilityFlashTimer:Float = 0;
    
    // Public getters for UI/debug
    public function canDash():Bool {
        return dashCooldownTime <= 0 && !isDashing;
    }
    
    public function getDashCooldownPercent():Float {
        return dashCooldownTime > 0 ? dashCooldownTime / dashCooldown : 0;
    }
    
    public function makeInvincible(duration:Float) {
        isInvincible = true;
        invincibilityTime = duration;
        invincibilityFlashTimer = 0;
    }
    
    public function new(parent:h2d.Object, collisionWorld:CollisionWorld, ghostContainer:h2d.Object) {
        super(parent);
        this.collisionWorld = collisionWorld;
        
        // Create ghost pool in a container behind the player
        ghostPool = new GhostPool(ghostContainer);
        
        // Create sprite sheet
        var spriteSheet = SpriteGenerator.createPlayerSpriteSheet();
        
        // Create animation tiles
        var tiles:Array<Tile> = [];
        
        // Idle frame
        var tile = spriteSheet.sub(0, 0, 32, 32);
        tile.dx = -16;  // Center the tile
        tile.dy = -16;
        tiles.push(tile);
        
        // Walk frames
        for (i in 0...4) {
            var walkTile = spriteSheet.sub(i * 32, 0, 32, 32);
            walkTile.dx = -16;
            walkTile.dy = -16;
            tiles.push(walkTile);
        }
        
        // Create animated sprite directly on the player
        anim = new Anim(tiles, 8, this);
        anim.pause = true;
        anim.currentFrame = 0;
        
        // Initialize ghost pool with player sprite
        ghostPool.init(tiles[0]);  // Use idle frame for ghosts
        
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
    
    public function tryDash():Bool {
        // Can't dash if on cooldown or already dashing
        if (dashCooldownTime > 0 || isDashing) return false;
        
        // Require directional input to dash
        if (inputDx == 0 && inputDy == 0) {
            return false;  // No dash without direction
        }
        
        // Dash in input direction
        dashDirection.x = inputDx;
        dashDirection.y = inputDy;
        
        // Normalize dash direction
        var len = Math.sqrt(dashDirection.x * dashDirection.x + dashDirection.y * dashDirection.y);
        if (len > 0) {
            dashDirection.x /= len;
            dashDirection.y /= len;
        }
        
        // Start dash
        isDashing = true;
        dashTime = dashDuration;
        dashCooldownTime = dashCooldown;
        
        // Make invincible during dash + a bit after
        makeInvincible(dashDuration + 0.1);  // Extra 0.1s of invincibility after dash
        
        return true;
    }
    
    override function update(dt:Float) {
        // Update dash timers
        if (dashCooldownTime > 0) {
            dashCooldownTime -= dt;
        }
        
        // Update invincibility
        if (isInvincible) {
            invincibilityTime -= dt;
            if (invincibilityTime <= 0) {
                isInvincible = false;
                alpha = 1.0;  // Ensure full opacity when invincibility ends
            } else {
                // Flash effect using sine wave for smooth pulsing
                var flashFrequency = GameConstants.PLAYER_INVINCIBILITY_FLASH_FREQUENCY;  // Flashes per second
                alpha = 0.5 + 0.5 * Math.sin(invincibilityTime * flashFrequency * Math.PI * 2);
            }
        }
        
        if (isDashing) {
            dashTime -= dt;
            if (dashTime <= 0) {
                isDashing = false;
            }
            
            // Spawn ghosts during dash
            ghostSpawnTimer += dt;
            if (ghostSpawnTimer >= ghostSpawnInterval) {
                ghostSpawnTimer = 0;
                // Spawn ghost at player center position
                ghostPool.spawn(px, py, facingRight);
            }
        }
        
        // Calculate desired velocity
        if (isDashing) {
            // Use dash speed and direction
            desiredDx = dashDirection.x * dashSpeed * dt;
            desiredDy = dashDirection.y * dashSpeed * dt;
        } else {
            // Normal movement based on input
            desiredDx = inputDx * moveSpeed * dt;
            desiredDy = inputDy * moveSpeed * dt;
        }
        
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
        
        // Update collider position BEFORE handling animations
        if (collider != null) {
            collider.x = px;
            collider.y = py;
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
        
        // Update position - make sure we update the entity position
        x = px;
        y = py;
        
        // Handle sprite flipping
        scaleX = facingRight ? 1 : -1;
        
        // Update ghost pool
        ghostPool.update(dt);
    }
}