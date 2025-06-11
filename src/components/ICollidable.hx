package components;

import h2d.col.Circle;
import h2d.col.Bounds;

/**
 * Interface for entities that participate in collision detection
 * 
 * Defines how entities interact with the collision system and other entities.
 * Supports both circle and bounds (AABB) collision shapes.
 * 
 * Collision System Design:
 * - Entities can have either a circle or bounds collider (not both)
 * - Collision groups determine what collides with what
 * - Solid entities block movement, non-solid entities trigger overlaps
 * 
 * Collision Groups (bitmask):
 * - 0x01: Player
 * - 0x02: Enemies  
 * - 0x04: Player projectiles
 * - 0x08: Enemy projectiles
 * - 0x10: Pickups
 * - 0x20: Environment
 * 
 * @see CollisionWorld for the collision detection system
 * @see Entity for base implementation
 */
interface ICollidable {
    /**
     * Collision shape for circular entities
     * Null if using bounds instead
     */
    var collisionCircle(get, never):Circle;
    
    /**
     * Collision shape for rectangular entities
     * Null if using circle instead
     */
    var collisionBounds(get, never):Bounds;
    
    /**
     * Collision group bitmask
     * Determines what this entity is
     */
    var collisionGroup(get, set):Int;
    
    /**
     * Collision mask bitmask
     * Determines what this entity collides with
     */
    var collisionMask(get, set):Int;
    
    /**
     * Whether this entity blocks movement
     * true = solid wall/obstacle
     * false = trigger/pickup
     */
    var isSolid(get, set):Bool;
    
    /**
     * Called when this entity overlaps with another
     * Only called for non-solid collisions
     * 
     * @param other The entity we're overlapping with
     * 
     * Implementation ideas:
     * - Pickups: Collect and destroy self
     * - Damage zones: Apply damage to other
     * - Triggers: Activate events
     */
    function onCollision(other:ICollidable):Void;
    
    /**
     * Update collision shape position
     * Called automatically after movement
     * 
     * @param x New X position
     * @param y New Y position
     */
    function updateCollisionPosition(x:Float, y:Float):Void;
    
    /**
     * Check if this entity can collide with another
     * Based on collision groups and masks
     * 
     * @param other Entity to check against
     * @return true if collision should be checked
     */
    function canCollideWith(other:ICollidable):Bool;
}