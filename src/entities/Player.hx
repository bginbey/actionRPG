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
import entities.effects.SwordSwing;
import components.IHealth;
import components.Hitbox;

class Player extends Entity implements IHealth {
    var collisionWorld:CollisionWorld;
    var ghostPool:GhostPool;
    
    // Health properties
    private var _health:Float;
    private var _maxHealth:Float;
    private var _isDead:Bool = false;
    
    public var health(get, set):Float;
    public var maxHealth(get, set):Float;
    
    function get_health():Float return _health;
    function set_health(v:Float):Float {
        _health = Math.max(0, v);
        if (_health <= 0 && !_isDead) {
            onDeath();
        }
        return _health;
    }
    
    function get_maxHealth():Float return _maxHealth;
    function set_maxHealth(v:Float):Float {
        _maxHealth = Math.max(1, v);
        // Ensure current health doesn't exceed new max
        if (_health > _maxHealth) {
            _health = _maxHealth;
        }
        return _maxHealth;
    }
    
    // Movement
    public var moveSpeed:Float = GameConstants.PLAYER_MOVE_SPEED;  // Pixels per second
    public var isMoving:Bool = false;
    public var facingRight:Bool = true;
    
    // Direction (for 8-way attacks)
    public var facingAngle:Float = 0;  // Angle in radians (0 = right, PI/2 = down, PI = left, -PI/2 = up)
    
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
    
    // Combat system
    public var isAttacking:Bool = false;
    var attackTime:Float = 0;
    var attackCooldown:Float = 0;
    var comboCount:Int = 0;
    var comboWindow:Float = 0;
    var currentHitbox:Hitbox;
    var attackQueued:Bool = false;
    var currentSwingEffect:SwordSwing;
    
    // Public getters for UI/debug
    public function canDash():Bool {
        return dashCooldownTime <= 0 && !isDashing;
    }
    
    public function getDashCooldownPercent():Float {
        return dashCooldownTime > 0 ? dashCooldownTime / dashCooldown : 0;
    }
    
    public function getCurrentHitbox():Hitbox {
        return isAttacking ? currentHitbox : null;
    }
    
    public function getComboCount():Int {
        return comboCount;
    }
    
    public function getFacingAngle():Float {
        return facingAngle;
    }
    
    public function makeInvincible(duration:Float) {
        isInvincible = true;
        invincibilityTime = duration;
        invincibilityFlashTimer = 0;
    }
    
    public function new(parent:h2d.Object, collisionWorld:CollisionWorld, ghostContainer:h2d.Object) {
        super(parent);
        this.collisionWorld = collisionWorld;
        
        // Initialize health
        _maxHealth = GameConstants.PLAYER_MAX_HEALTH;
        _health = GameConstants.PLAYER_HEALTH;
        
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
        
        // Update facing direction and angle
        if (dx != 0 || dy != 0) {
            facingAngle = Math.atan2(dy, dx);
            facingRight = dx >= 0;
        }
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
    
    public function tryAttack():Bool {
        // Can't attack while dashing or dead
        if (isDashing || _isDead) return false;
        
        // If already attacking, queue next attack if within combo window
        if (isAttacking) {
            if (comboWindow > 0 && comboCount < GameConstants.MAX_COMBO_COUNT) {
                attackQueued = true;
                return true;
            }
            return false;
        }
        
        // Check if on cooldown
        if (attackCooldown > 0) return false;
        
        // Start attack
        isAttacking = true;
        attackTime = GameConstants.SWORD_SWING_DURATION;
        
        // Increment combo or reset
        if (comboWindow > 0 && comboCount < GameConstants.MAX_COMBO_COUNT) {
            comboCount++;
        } else {
            comboCount = 1;
        }
        
        // Create hitbox
        var damage = GameConstants.SWORD_BASE_DAMAGE;
        
        // Apply combo multiplier
        switch(comboCount) {
            case 1: damage *= GameConstants.COMBO_MULTIPLIER_1;
            case 2: damage *= GameConstants.COMBO_MULTIPLIER_2;
            case 3: damage *= GameConstants.COMBO_MULTIPLIER_3;
        }
        
        currentHitbox = new Hitbox(damage, GameConstants.KNOCKBACK_FORCE);
        currentHitbox.owner = this;
        
        // Position hitbox based on facing angle (8 directions)
        var hitboxX = px + Math.cos(facingAngle) * GameConstants.SWORD_HITBOX_OFFSET;
        var hitboxY = py + Math.sin(facingAngle) * GameConstants.SWORD_HITBOX_OFFSET;
        currentHitbox.setBounds(hitboxX, hitboxY, GameConstants.SWORD_HITBOX_WIDTH, GameConstants.SWORD_HITBOX_HEIGHT);
        
        // Create visual effect
        currentSwingEffect = new SwordSwing(parent, px, py, facingAngle, comboCount);
        
        // TODO: Play attack animation
        // TODO: Play attack sound
        
        return true;
    }
    
    override function update(dt:Float) {
        // Update dash timers
        if (dashCooldownTime > 0) {
            dashCooldownTime -= dt;
        }
        
        // Update combat timers
        if (attackCooldown > 0) {
            attackCooldown -= dt;
        }
        
        if (comboWindow > 0) {
            comboWindow -= dt;
            if (comboWindow <= 0) {
                comboCount = 0;
            }
        }
        
        // Update attack
        if (isAttacking) {
            attackTime -= dt;
            if (attackTime <= 0) {
                isAttacking = false;
                
                // Check for queued attack
                if (attackQueued) {
                    attackQueued = false;
                    tryAttack();
                } else {
                    // Set combo window
                    comboWindow = GameConstants.COMBO_WINDOW;
                    
                    // Set cooldown after full combo
                    if (comboCount >= GameConstants.MAX_COMBO_COUNT) {
                        attackCooldown = GameConstants.ATTACK_COOLDOWN;
                        comboCount = 0;
                        comboWindow = 0;
                    }
                }
                
                // Clear hitbox
                currentHitbox = null;
            }
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
        } else if (isAttacking) {
            // No movement during attack (root motion)
            desiredDx = 0;
            desiredDy = 0;
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
        
        // Update sword swing effect
        if (currentSwingEffect != null) {
            currentSwingEffect.update(dt);
            // Check if it removed itself
            if (currentSwingEffect.parent == null) {
                currentSwingEffect = null;
            }
        }
    }
    
    // IHealth implementation
    public function takeDamage(amount:Float, ?source:Entity):Float {
        // Can't take damage if invincible or dead
        if (isInvincible || _isDead) return 0;
        
        var actualDamage = amount;
        
        // Apply damage
        health -= actualDamage;
        
        // Trigger invincibility frames
        makeInvincible(GameConstants.PLAYER_INVINCIBILITY_DURATION);
        
        // TODO: Add visual feedback (flash red, particles, etc.)
        // TODO: Add audio feedback
        
        return actualDamage;
    }
    
    public function heal(amount:Float):Float {
        if (_isDead) return 0;
        
        var previousHealth = _health;
        health = Math.min(_health + amount, _maxHealth);
        var actualHealing = _health - previousHealth;
        
        // TODO: Add healing visual effect
        // TODO: Add healing sound
        
        return actualHealing;
    }
    
    public function isDead():Bool {
        return _isDead;
    }
    
    public function onDeath():Void {
        if (_isDead) return;
        _isDead = true;
        
        // TODO: Play death animation
        // TODO: Disable player controls
        // TODO: Trigger game over or respawn sequence
        // For now, just make the player invisible
        visible = false;
        
        // Remove from collision world
        // TODO: Implement removeCollider in CollisionWorld
        // if (collider != null) {
        //     collisionWorld.removeCollider(collider);
        // }
    }
}