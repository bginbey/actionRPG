package components;

import entities.Entity;

/**
 * Interface for entities that can take damage and have health
 * 
 * Used by players, enemies, and destructible objects to provide
 * a consistent health and damage system throughout the game.
 * 
 * Health System Design:
 * - Health is a float to support fractional damage/healing
 * - Damage can be modified by the entity (resistances, armor, etc.)
 * - Death is triggered automatically when health <= 0
 * - Healing is capped at maxHealth
 * 
 * Example implementation:
 * ```haxe
 * class Enemy extends Entity implements IHealth {
 *     public var health(get, set):Float;
 *     public var maxHealth(get, set):Float;
 *     
 *     private var _health:Float = 100;
 *     private var _maxHealth:Float = 100;
 *     
 *     function get_health():Float return _health;
 *     function set_health(v:Float):Float {
 *         _health = v;
 *         if (_health <= 0 && !isDead()) onDeath();
 *         return _health;
 *     }
 * }
 * ```
 * 
 * @see CombatSystem for damage calculation and application
 */
interface IHealth {
    /**
     * Current health value
     * Setting to 0 or below should trigger onDeath()
     */
    var health(get, set):Float;
    
    /**
     * Maximum health value
     * Used to cap healing and display health bars
     */
    var maxHealth(get, set):Float;
    
    /**
     * Apply damage to this entity
     * 
     * @param amount Base damage amount before modifications
     * @param source Optional source entity for damage attribution
     * @return Actual damage dealt after resistances/armor/modifiers
     * 
     * Implementation should:
     * - Apply any damage modifiers (armor, resistances, shields)
     * - Subtract final damage from health
     * - Trigger any on-hit effects
     * - Call onDeath() if health reaches 0
     */
    function takeDamage(amount:Float, ?source:Entity):Float;
    
    /**
     * Heal this entity
     * 
     * @param amount Amount of health to restore
     * @return Actual amount healed (capped at maxHealth - health)
     * 
     * Implementation should:
     * - Add healing to current health
     * - Cap at maxHealth
     * - Trigger any on-heal effects
     */
    function heal(amount:Float):Float;
    
    /**
     * Check if entity is dead (health <= 0)
     * 
     * @return true if health is 0 or below
     */
    function isDead():Bool;
    
    /**
     * Called when health reaches zero
     * 
     * Implementation should:
     * - Play death animation/effects
     * - Remove from collision system
     * - Drop items/rewards
     * - Clean up resources
     */
    function onDeath():Void;
}