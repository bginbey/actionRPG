package components;

import h2d.Anim;

/**
 * Interface for entities with animated sprites
 * 
 * Provides a consistent way to manage sprite animations across
 * all animated game objects. Supports multiple animation states
 * and smooth transitions.
 * 
 * Animation System Design:
 * - Each animation state has a unique name (e.g., "idle", "run", "attack")
 * - Animations can loop or play once
 * - Frame data is stored per animation
 * - Transitions can be immediate or wait for current animation to finish
 * 
 * Animation Naming Convention:
 * - "idle" - Default standing animation
 * - "run" - Movement animation
 * - "attack" - Attack animation
 * - "hurt" - Damage reaction
 * - "death" - Death sequence
 * 
 * @see AnimationController for a reusable implementation
 * @see Player for example usage
 */
interface IAnimated {
    /**
     * Current animation name
     * Setting this triggers an animation change
     */
    var currentAnimation(get, set):String;
    
    /**
     * The sprite animation object
     * Manages frames and playback
     */
    var anim(get, never):Anim;
    
    /**
     * Play a specific animation
     * 
     * @param name Animation name (e.g., "idle", "run", "attack")
     * @param loop Whether to loop the animation (default: true)
     * @param force Force restart even if already playing (default: false)
     * @param onComplete Optional callback when animation finishes (non-looping only)
     * 
     * Usage:
     * ```haxe
     * entity.playAnimation("attack", false, true, () -> {
     *     entity.playAnimation("idle");
     * });
     * ```
     */
    function playAnimation(name:String, ?loop:Bool = true, ?force:Bool = false, ?onComplete:Void->Void):Void;
    
    /**
     * Register a new animation
     * 
     * @param name Unique animation name
     * @param frames Array of frame indices
     * @param fps Frames per second for this animation
     * 
     * Example:
     * ```haxe
     * entity.registerAnimation("idle", [0, 1, 2, 1], 4);
     * entity.registerAnimation("run", [3, 4, 5, 6, 7, 8], 10);
     * ```
     */
    function registerAnimation(name:String, frames:Array<Int>, fps:Int):Void;
    
    /**
     * Check if a specific animation exists
     * 
     * @param name Animation name to check
     * @return true if animation is registered
     */
    function hasAnimation(name:String):Bool;
    
    /**
     * Pause the current animation
     */
    function pauseAnimation():Void;
    
    /**
     * Resume the current animation
     */
    function resumeAnimation():Void;
    
    /**
     * Set animation speed multiplier
     * 
     * @param speed Speed multiplier (1.0 = normal, 0.5 = half speed, 2.0 = double speed)
     */
    function setAnimationSpeed(speed:Float):Void;
}