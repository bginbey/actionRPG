package components;

import h2d.col.Bounds;
import entities.Entity;

/**
 * Hitbox component for combat collision detection
 * 
 * Represents an active damage zone that can hit entities with IHealth.
 * Hitboxes are temporary and exist only during attack animations.
 * 
 * Features:
 * - Rectangle-based collision detection
 * - Damage and knockback properties
 * - Entity filtering to prevent self-damage
 * - Single-hit tracking to prevent multiple hits on same target
 * 
 * Usage:
 * ```haxe
 * var hitbox = new Hitbox(10, 100); // 10 damage, 100 knockback
 * hitbox.owner = player;
 * hitbox.setBounds(x, y, width, height);
 * var hits = hitbox.checkHits(enemies);
 * ```
 */
class Hitbox {
    /** Entity that created this hitbox (prevents self-damage) */
    public var owner:Entity;
    
    /** Damage to deal on hit */
    public var damage:Float;
    
    /** Knockback force to apply */
    public var knockback:Float;
    
    /** Collision bounds */
    public var bounds:Bounds;
    
    /** Entities already hit by this hitbox (prevents double hits) */
    private var hitEntities:Array<Entity>;
    
    /** Whether this hitbox is currently active */
    public var active:Bool = true;
    
    /**
     * Create a new hitbox
     * @param damage Base damage amount
     * @param knockback Knockback force
     */
    public function new(damage:Float, knockback:Float) {
        this.damage = damage;
        this.knockback = knockback;
        this.bounds = new Bounds();
        this.hitEntities = [];
    }
    
    /**
     * Set the hitbox bounds
     * @param x Center X position
     * @param y Center Y position  
     * @param width Hitbox width
     * @param height Hitbox height
     */
    public function setBounds(x:Float, y:Float, width:Float, height:Float) {
        bounds.x = x - width * 0.5;
        bounds.y = y - height * 0.5;
        bounds.width = width;
        bounds.height = height;
    }
    
    /**
     * Check for hits against a list of entities
     * @param entities List of potential targets
     * @return Array of entities that were hit
     */
    public function checkHits(entities:Array<Entity>):Array<Entity> {
        if (!active) return [];
        
        var hits:Array<Entity> = [];
        
        for (entity in entities) {
            // Skip if already hit this entity
            if (hitEntities.indexOf(entity) != -1) continue;
            
            // Skip owner
            if (entity == owner) continue;
            
            // Skip dead entities
            var healthComponent = cast(entity, IHealth);
            if (healthComponent != null && healthComponent.isDead()) continue;
            
            // Check collision using public interface
            var collisionCircle = entity.collisionCircle;
            if (collisionCircle != null) {
                var entityBounds = new Bounds();
                entityBounds.x = collisionCircle.x - collisionCircle.ray;
                entityBounds.y = collisionCircle.y - collisionCircle.ray;
                entityBounds.width = collisionCircle.ray * 2;
                entityBounds.height = collisionCircle.ray * 2;
                
                if (bounds.intersects(entityBounds)) {
                    hits.push(entity);
                    hitEntities.push(entity);
                }
            }
        }
        
        return hits;
    }
    
    /**
     * Reset the hit list (allows hitting same entities again)
     */
    public function reset() {
        hitEntities = [];
    }
    
    /**
     * Apply damage and knockback to a hit entity
     * @param target Entity that was hit
     */
    public function applyHit(target:Entity) {
        // Apply damage if target has health
        var healthComponent = cast(target, IHealth);
        if (healthComponent != null) {
            healthComponent.takeDamage(damage, owner);
        }
        
        // Apply knockback
        if (knockback > 0 && owner != null) {
            var dx = target.px - owner.px;
            var dy = target.py - owner.py;
            var dist = Math.sqrt(dx * dx + dy * dy);
            if (dist > 0) {
                dx /= dist;
                dy /= dist;
                target.dx += dx * knockback;
                target.dy += dy * knockback;
            }
        }
    }
}