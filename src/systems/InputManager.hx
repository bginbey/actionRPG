package systems;

/**
 * InputManager - Handles input priority for smooth directional movement
 * 
 * SPECIFICATIONS:
 * - Tracks the order in which directional keys are pressed
 * - Most recently pressed direction takes priority
 * - When a key is released, falls back to previously pressed direction if still held
 * - Prevents opposite directions from canceling each other out
 * - Designed to work with both keyboard and future gamepad support
 * 
 * KEYBOARD BEHAVIOR:
 * - Each direction (up/down/left/right) can be in pressed or released state
 * - When multiple directions are pressed, only the most recent is active
 * - Diagonal movement is allowed when non-conflicting directions are pressed
 * 
 * FUTURE GAMEPAD SUPPORT:
 * - D-pad will use the same priority system as keyboard
 * - Analog stick will bypass priority system and use raw values
 * 
 * @author Claude
 */
class InputManager {
    // Direction enum for cleaner code
    public static inline var DIR_UP = 0;
    public static inline var DIR_DOWN = 1;
    public static inline var DIR_LEFT = 2;
    public static inline var DIR_RIGHT = 3;
    
    // Track which keys are currently pressed
    var pressedKeys:Map<Int, Bool>;
    
    // Priority queue for horizontal and vertical axes
    var horizontalPriority:Array<Int>;  // LEFT or RIGHT
    var verticalPriority:Array<Int>;    // UP or DOWN
    
    public function new() {
        pressedKeys = new Map();
        horizontalPriority = [];
        verticalPriority = [];
    }
    
    /**
     * Called when a directional key is pressed
     * @param direction One of DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT
     */
    public function onKeyPress(direction:Int) {
        if (pressedKeys.get(direction) == true) return; // Already pressed
        
        pressedKeys.set(direction, true);
        
        // Add to appropriate priority queue
        switch(direction) {
            case DIR_UP, DIR_DOWN:
                verticalPriority.push(direction);
            case DIR_LEFT, DIR_RIGHT:
                horizontalPriority.push(direction);
        }
    }
    
    /**
     * Called when a directional key is released
     * @param direction One of DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT
     */
    public function onKeyRelease(direction:Int) {
        pressedKeys.set(direction, false);
        
        // Remove from appropriate priority queue
        switch(direction) {
            case DIR_UP, DIR_DOWN:
                verticalPriority.remove(direction);
            case DIR_LEFT, DIR_RIGHT:
                horizontalPriority.remove(direction);
        }
    }
    
    /**
     * Get the current movement vector based on input priority
     * @return {x:Float, y:Float} Normalized movement vector
     */
    public function getMovementVector():{x:Float, y:Float} {
        var dx:Float = 0;
        var dy:Float = 0;
        
        // Get horizontal direction from priority queue
        if (horizontalPriority.length > 0) {
            var lastHorizontal = horizontalPriority[horizontalPriority.length - 1];
            if (pressedKeys.get(lastHorizontal) == true) {
                dx = (lastHorizontal == DIR_LEFT) ? -1 : 1;
            }
        }
        
        // Get vertical direction from priority queue
        if (verticalPriority.length > 0) {
            var lastVertical = verticalPriority[verticalPriority.length - 1];
            if (pressedKeys.get(lastVertical) == true) {
                dy = (lastVertical == DIR_UP) ? -1 : 1;
            }
        }
        
        // Normalize diagonal movement
        if (dx != 0 && dy != 0) {
            dx *= 0.707;
            dy *= 0.707;
        }
        
        return {x: dx, y: dy};
    }
    
    /**
     * Clear all input state
     */
    public function clear() {
        pressedKeys.clear();
        horizontalPriority = [];
        verticalPriority = [];
    }
}