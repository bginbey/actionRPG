package entities;

import h2d.Bitmap;
import h2d.Graphics;
import h2d.col.Circle;
import utils.ColorPalette;
import utils.GameConstants;
import systems.CollisionWorld;
import components.IHealth;
import entities.AIState;

/**
 * Base enemy class
 * 
 * Provides common functionality for all enemy types:
 * - Health and damage system
 * - Movement and collision
 * - State management (idle, patrol, chase, attack, hurt)
 * - Visual representation
 * - Knockback handling
 * 
 * Subclasses should override:
 * - createVisual() for custom appearance
 * - updateAI() for behavior patterns
 * - attack() for attack implementation
 * 
 * @see IHealth for damage interface
 * @see Player for combat target
 */
class Enemy extends Entity implements IHealth {
    // Health properties
    private var _health:Float;
    private var _maxHealth:Float;
    private var _isDead:Bool = false;
    
    public var health(get, set):Float;
    public var maxHealth(get, set):Float;
    
    // References
    var collisionWorld:CollisionWorld;
    var player:Player;
    
    // AI State
    public var currentState:AIState = Idle;
    var stateTime:Float = 0;
    
    // Movement
    public var moveSpeed:Float = GameConstants.ENEMY_MOVE_SPEED;
    var targetX:Float = 0;
    var targetY:Float = 0;
    
    // Combat
    var attackCooldown:Float = 0;
    var hurtTime:Float = 0;
    var knockbackTime:Float = 0;
    var knockbackDx:Float = 0;
    var knockbackDy:Float = 0;
    
    // Visual
    var graphics:Graphics;
    var baseColor:Int = ColorPalette.RED;
    var flashTime:Float = 0;
    
    // Detection
    public var sightRange:Float = GameConstants.ENEMY_SIGHT_RANGE;
    public var attackRange:Float = GameConstants.ENEMY_ATTACK_RANGE;
    
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
        if (_health > _maxHealth) {
            _health = _maxHealth;
        }
        return _maxHealth;
    }
    
    public function new(parent:h2d.Object, collisionWorld:CollisionWorld, player:Player) {
        super(parent);
        this.collisionWorld = collisionWorld;
        this.player = player;
        
        // Initialize health
        _maxHealth = GameConstants.ENEMY_HEALTH;
        _health = _maxHealth;
        
        // Set collision
        setColliderRadius(GameConstants.ENEMY_RADIUS);
        
        // Create visual
        createVisual();
    }
    
    /**
     * Create the enemy's visual representation
     * Override in subclasses for custom appearance
     */
    function createVisual() {
        graphics = new Graphics(this);
        drawEnemy();
    }
    
    function drawEnemy() {
        graphics.clear();
        
        // Choose color based on state
        var color = baseColor;
        if (flashTime > 0) {
            // Flash white when hurt
            color = ColorPalette.WHITE;
        }
        
        // Draw simple enemy shape (triangle pointing in move direction)
        graphics.beginFill(color);
        graphics.lineStyle(2, ColorPalette.BLACK);
        
        // Draw body circle
        graphics.drawCircle(0, 0, radius);
        
        // Draw direction indicator
        if (Math.abs(dx) > 0.1 || Math.abs(dy) > 0.1) {
            var angle = Math.atan2(dy, dx);
            graphics.moveTo(0, 0);
            graphics.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius);
        }
        
        graphics.endFill();
        
        // Health bar
        if (_health < _maxHealth) {
            var barWidth = 30;
            var barHeight = 4;
            var barY = -radius - 10;
            
            // Background
            graphics.beginFill(ColorPalette.BLACK);
            graphics.drawRect(-barWidth/2, barY, barWidth, barHeight);
            graphics.endFill();
            
            // Health
            var healthPercent = _health / _maxHealth;
            graphics.beginFill(ColorPalette.RED);
            graphics.drawRect(-barWidth/2, barY, barWidth * healthPercent, barHeight);
            graphics.endFill();
        }
    }
    
    override function update(dt:Float) {
        // Update timers
        if (attackCooldown > 0) attackCooldown -= dt;
        if (hurtTime > 0) hurtTime -= dt;
        if (knockbackTime > 0) knockbackTime -= dt;
        if (flashTime > 0) {
            flashTime -= dt;
            drawEnemy(); // Redraw for flash effect
        }
        
        // Update state time
        stateTime += dt;
        
        // Handle knockback
        if (knockbackTime > 0) {
            dx = knockbackDx * (knockbackTime / GameConstants.ENEMY_KNOCKBACK_RECOVERY);
            dy = knockbackDy * (knockbackTime / GameConstants.ENEMY_KNOCKBACK_RECOVERY);
        } else {
            // Normal AI update
            updateAI(dt);
        }
        
        // Apply movement with collision
        if (dx != 0 || dy != 0) {
            var resolved = collisionWorld.resolveCircleCollision(collider, dx * dt, dy * dt);
            px = resolved.x;
            py = resolved.y;
            
            // Update collider position
            if (collider != null) {
                collider.x = px;
                collider.y = py;
            }
        }
        
        // Update position
        x = px;
        y = py;
        
        // Apply friction
        dx *= GameConstants.ENTITY_FRICTION;
        dy *= GameConstants.ENTITY_FRICTION;
    }
    
    /**
     * Update AI behavior
     * Override in subclasses for custom AI
     */
    function updateAI(dt:Float) {
        if (_isDead) return;
        
        // Calculate distance to player
        var distToPlayer = distanceTo(player);
        var canSeePlayer = distToPlayer <= sightRange && !player.isDead();
        
        switch(currentState) {
            case Idle:
                if (canSeePlayer) {
                    changeState(Chase);
                }
                
            case Patrol:
                // Simple back and forth patrol
                if (canSeePlayer) {
                    changeState(Chase);
                } else {
                    // Move towards target
                    var distToTarget = Math.sqrt(Math.pow(targetX - px, 2) + Math.pow(targetY - py, 2));
                    if (distToTarget > 5) {
                        var angle = Math.atan2(targetY - py, targetX - px);
                        dx = Math.cos(angle) * GameConstants.ENEMY_PATROL_SPEED;
                        dy = Math.sin(angle) * GameConstants.ENEMY_PATROL_SPEED;
                    } else {
                        // Reached target, wait then pick new target
                        if (stateTime > GameConstants.ENEMY_PATROL_WAIT_TIME) {
                            // Pick random nearby point
                            targetX = px + (Math.random() - 0.5) * 100;
                            targetY = py + (Math.random() - 0.5) * 100;
                            stateTime = 0;
                        }
                    }
                }
                
            case Chase:
                if (!canSeePlayer) {
                    changeState(Patrol);
                } else if (distToPlayer <= attackRange) {
                    changeState(Attack);
                } else {
                    // Move towards player
                    var angle = Math.atan2(player.py - py, player.px - px);
                    dx = Math.cos(angle) * GameConstants.ENEMY_CHASE_SPEED;
                    dy = Math.sin(angle) * GameConstants.ENEMY_CHASE_SPEED;
                }
                
            case Attack:
                if (distToPlayer > attackRange) {
                    changeState(Chase);
                } else if (attackCooldown <= 0) {
                    performAttack();
                }
                dx = 0;
                dy = 0;
                
            case Hurt:
                // Wait for hurt animation to finish
                if (hurtTime <= 0) {
                    changeState(canSeePlayer ? Chase : Patrol);
                }
                
            case Dead:
                // Do nothing
        }
    }
    
    function changeState(newState:AIState) {
        currentState = newState;
        stateTime = 0;
        
        // Initialize state-specific behavior
        switch(newState) {
            case Patrol:
                targetX = px;
                targetY = py;
            default:
        }
    }
    
    function performAttack() {
        // Basic melee attack towards player
        attackCooldown = GameConstants.ENEMY_ATTACK_COOLDOWN;
        
        // Visual attack indicator
        createAttackIndicator();
        
        // Deal damage if in range (with slight delay for visual feedback)
        haxe.Timer.delay(() -> {
            if (!_isDead && distanceTo(player) <= attackRange) {
                player.takeDamage(GameConstants.ENEMY_ATTACK_DAMAGE, this);
            }
        }, 100);
    }
    
    function createAttackIndicator() {
        // Create a simple attack slash effect
        var attackGraphics = new Graphics(parent);
        attackGraphics.x = px;
        attackGraphics.y = py;
        
        // Calculate angle to player
        var angle = Math.atan2(player.py - py, player.px - px);
        
        // Draw attack arc
        attackGraphics.lineStyle(3, ColorPalette.ORANGE, 0.8);
        var arcRadius = attackRange;
        var arcSpread = Math.PI/4; // 45 degree arc
        
        var startAngle = angle - arcSpread/2;
        var endAngle = angle + arcSpread/2;
        
        // Draw arc
        for (i in 0...5) {
            var t = i / 4;
            var a = startAngle + (endAngle - startAngle) * t;
            var x = Math.cos(a) * arcRadius;
            var y = Math.sin(a) * arcRadius;
            if (i == 0) {
                attackGraphics.moveTo(x, y);
            } else {
                attackGraphics.lineTo(x, y);
            }
        }
        
        // Remove after a short time
        haxe.Timer.delay(() -> {
            attackGraphics.remove();
        }, 200);
    }
    
    function distanceTo(other:Entity):Float {
        var dx = other.px - px;
        var dy = other.py - py;
        return Math.sqrt(dx * dx + dy * dy);
    }
    
    // IHealth implementation
    public function takeDamage(amount:Float, ?source:Entity):Float {
        if (_isDead) return 0;
        
        health -= amount;
        
        // Visual feedback
        flashTime = GameConstants.ENEMY_HURT_FLASH_DURATION;
        hurtTime = GameConstants.ENEMY_HURT_FLASH_DURATION;
        
        // Apply knockback
        if (source != null) {
            var angle = Math.atan2(py - source.py, px - source.px);
            knockbackDx = Math.cos(angle) * GameConstants.KNOCKBACK_FORCE;
            knockbackDy = Math.sin(angle) * GameConstants.KNOCKBACK_FORCE;
            knockbackTime = GameConstants.ENEMY_KNOCKBACK_RECOVERY;
        }
        
        // Change to hurt state
        if (!_isDead) {
            changeState(Hurt);
        }
        
        return amount;
    }
    
    public function heal(amount:Float):Float {
        if (_isDead) return 0;
        
        var previousHealth = _health;
        health = Math.min(_health + amount, _maxHealth);
        return _health - previousHealth;
    }
    
    public function isDead():Bool {
        return _isDead;
    }
    
    public function onDeath():Void {
        if (_isDead) return;
        _isDead = true;
        changeState(Dead);
        
        // TODO: Death animation
        // TODO: Drop items
        // For now, just remove after a delay
        haxe.Timer.delay(() -> {
            remove();
        }, 500);
    }
}