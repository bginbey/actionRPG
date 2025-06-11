package ui;

import h2d.Object;
import h2d.Text;
import ui.PixelText;
import utils.GameConstants;

/**
 * Game HUD (Heads-Up Display)
 * 
 * Manages all on-screen UI elements during gameplay:
 * - Debug text and help information
 * - Player health/energy bars (future)
 * - Score/currency display (future)  
 * - Status effects indicators (future)
 * - Minimap (future)
 * 
 * The HUD is rendered in screen space (not affected by camera)
 * and updates based on game state.
 * 
 * Current features:
 * - Help text (H key to toggle)
 * - Debug information display
 * - Dynamic text updates
 * 
 * @see GameScene for integration
 * @see DebugRenderer for debug text generation
 */
class GameHUD {
    /** Container for all HUD elements */
    var container:Object;
    
    /** Debug/help text display */
    var debugText:Text;
    
    /** Whether help text is shown */
    var showHelp:Bool = false;
    
    /** Whether debug info is shown */
    var showDebug:Bool = false;
    
    /**
     * Create a new game HUD
     * @param parent Parent container (usually scene's UI container)
     */
    public function new(parent:Object) {
        container = new Object(parent);
        
        // Create debug text using pixel font
        var pixelText = new PixelText(container);
        pixelText.text = "";  // Start with no text
        pixelText.setPixelScale(GameConstants.DEBUG_TEXT_SCALE);
        pixelText.x = 10;
        pixelText.y = 10;
        debugText = pixelText;
        debugText.visible = false;  // Hidden by default
    }
    
    /**
     * Toggle help text display
     */
    public function toggleHelp():Void {
        showHelp = !showHelp;
        updateVisibility();
    }
    
    /**
     * Toggle debug info display
     */
    public function toggleDebug():Void {
        showDebug = !showDebug;
        updateVisibility();
    }
    
    /**
     * Check if help is currently shown
     */
    public function isHelpVisible():Bool {
        return showHelp;
    }
    
    /**
     * Check if debug info is currently shown
     */
    public function isDebugVisible():Bool {
        return showDebug;
    }
    
    /**
     * Update text visibility based on current state
     */
    function updateVisibility():Void {
        debugText.visible = showHelp || showDebug;
    }
    
    /**
     * Update the debug/help text
     * 
     * @param text The text to display
     */
    public function updateDebugText(text:String):Void {
        debugText.text = text;
    }
    
    /**
     * Build the help text string
     * @return Formatted help text
     */
    public function getHelpText():String {
        return "H help - WASD/Arrows move - Space/Shift dash - F1 cam - F2 shake - R rain - ` debug";
    }
    
    /**
     * Update HUD elements
     * Called each frame to refresh displays
     * 
     * @param dt Delta time
     */
    public function update(dt:Float):Void {
        // Future: Update health bars, timers, etc.
    }
    
    /**
     * Show a temporary message
     * Useful for pickups, achievements, etc.
     * 
     * @param message The message to show
     * @param duration How long to show it (seconds)
     */
    public function showMessage(message:String, duration:Float = 2.0):Void {
        // TODO: Implement temporary message system
        trace('HUD Message: $message');
    }
    
    /**
     * Clean up HUD resources
     */
    public function dispose():Void {
        container.remove();
    }
}