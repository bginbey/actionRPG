package components;

/**
 * Interface for entities that can move in the game world
 * 
 * Provides a standard way to handle position, velocity, and movement
 * for all moving game objects (players, enemies, projectiles, etc.)
 * 
 * Movement System:
 * - Position (x,y) represents the entity's world location
 * - Velocity (dx,dy) represents movement per second
 * - Move method handles the actual position update with collision detection
 * 
 * Coordinate System:
 * - (0,0) is top-left of the world
 * - X increases to the right
 * - Y increases downward
 * - All values are in pixels
 * 
 * @see CollisionWorld for movement validation
 * @see Entity for base implementation
 */
interface IMovable {
    /**
     * X position in world coordinates (pixels)
     */
    var x(default, set):Float;
    
    /**
     * Y position in world coordinates (pixels)
     */
    var y(default, set):Float;
    
    /**
     * X velocity in pixels per second
     * Positive = right, Negative = left
     */
    var dx(get, set):Float;
    
    /**
     * Y velocity in pixels per second
     * Positive = down, Negative = up
     */
    var dy(get, set):Float;
    
    /**
     * Move the entity by the given amount
     * 
     * @param dx Delta X in pixels
     * @param dy Delta Y in pixels
     * @return Actual movement applied after collision detection
     *         {x: actualDx, y: actualDy}
     * 
     * Implementation should:
     * - Check collision before moving
     * - Update position by allowed amount
     * - Handle collision response (sliding, bouncing, etc.)
     */
    function moveBy(dx:Float, dy:Float):{x:Float, y:Float};
    
    /**
     * Set position directly without collision checks
     * 
     * @param nx New X position
     * @param ny New Y position
     * 
     * Use for:
     * - Teleportation
     * - Initial spawn positioning
     * - Cutscene movement
     */
    function setPos(nx:Float, ny:Float):Void;
    
    /**
     * Apply friction to current velocity
     * 
     * @param friction Friction coefficient (0-1)
     *                 0 = no friction (ice)
     *                 1 = full stop
     *                 0.82 = default ground friction
     */
    function applyFriction(friction:Float):Void;
}