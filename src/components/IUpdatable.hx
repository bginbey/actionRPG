package components;

/**
 * Interface for entities that require per-frame updates
 * 
 * This is the most basic component for any dynamic game object
 * that needs to process logic every frame.
 * 
 * Usage:
 * - Implement this interface in any entity that moves, animates, or changes state
 * - The update method will be called once per frame with delta time
 * - Always use dt for time-based calculations to ensure frame-rate independence
 * 
 * @see Entity base class implements this by default
 */
interface IUpdatable {
    /**
     * Update the entity for one frame
     * 
     * @param dt Delta time in seconds since last frame
     *           Use this for all time-based calculations
     *           Example: position += velocity * dt
     */
    function update(dt:Float):Void;
}