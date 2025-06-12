import scenes.SceneManager;
import scenes.Scene;
import scenes.SplashScene;
import scenes.MenuScene;
import scenes.GameScene;
import utils.GameConstants;

/**
 * Core game loop and state management
 * 
 * Responsibilities:
 * - Manages the fixed timestep game loop
 * - Handles scene management and transitions
 * - Coordinates game-wide systems (audio, saves, etc.)
 * - Manages game state (paused, playing, menu)
 * 
 * Does NOT handle:
 * - Window management (handled by Main)
 * - Rendering setup (handled by Main/App)
 * - Input device setup (handled by Main/App)
 * 
 * Architecture:
 * Main.hx → Game.hx → SceneManager → Individual Scenes
 * 
 * The Game class acts as the central coordinator for all gameplay
 * systems, while Main.hx handles platform-specific initialization.
 * 
 * @see Main for application setup
 * @see SceneManager for scene handling
 */
class Game {
    /** Reference to the main app for engine access */
    public var app:Main;
    
    /** Scene manager handles all scene transitions and updates */
    public var sceneManager:SceneManager;
    
    /** Current game state */
    public var isPaused:Bool = false;
    
    /** Global game speed multiplier (for slow-mo effects) */
    public var gameSpeed:Float = 1.0;
    
    /** Hit pause system */
    var hitPauseTime:Float = 0;
    public var isHitPaused:Bool = false;
    
    /**
     * Create the game instance
     * @param app Reference to the main application
     */
    public function new(app:Main) {
        this.app = app;
        
        // Initialize scene manager
        sceneManager = new SceneManager(app);
        
        // Register all game scenes
        registerScenes();
        
        trace("Game initialized");
    }
    
    /**
     * Register all game scenes with the scene manager
     * Add new scenes here as they're created
     */
    function registerScenes() {
        // Register each scene
        sceneManager.addScene(new SplashScene(app));
        sceneManager.addScene(new MenuScene(app));
        sceneManager.addScene(new GameScene(app));
        
        // Future scenes to add:
        // - OptionsScene
        // - PauseScene  
        // - GameOverScene
        // - VictoryScene
        // - CreditsScene
    }
    
    /**
     * Start the game by showing the splash screen
     */
    public function start() {
        sceneManager.switchTo("splash");
    }
    
    /**
     * Fixed timestep update - called at consistent intervals
     * Used for physics, game logic, and anything that needs deterministic behavior
     * 
     * @param dt Fixed delta time (always FIXED_TIMESTEP)
     */
    public function fixedUpdate(dt:Float) {
        if (isPaused) return;
        
        // Handle hit pause
        if (hitPauseTime > 0) {
            hitPauseTime -= dt;
            if (hitPauseTime <= 0) {
                isHitPaused = false;
            }
            return; // Skip all updates during hit pause
        }
        
        // Apply game speed multiplier
        var scaledDt = dt * gameSpeed;
        
        // Update current scene
        sceneManager.fixedUpdate(scaledDt);
        
        // Update global systems here in the future:
        // - Physics system
        // - AI system
        // - Buff/debuff timers
    }
    
    /**
     * Variable timestep update - called every frame
     * Used for animations, particles, and visual effects
     * 
     * @param dt Actual frame delta time
     * @param alpha Interpolation factor for smooth rendering
     */
    public function update(dt:Float, alpha:Float) {
        // Update scene transitions (not affected by pause)
        sceneManager.update(dt);
        
        if (isPaused) return;
        
        // Render current scene with interpolation
        sceneManager.render(dt * gameSpeed, alpha);
        
        // Update non-gameplay systems:
        // - Audio fade in/out
        // - Screen effects
        // - UI animations
    }
    
    /**
     * Handle window resize events
     */
    public function onResize() {
        sceneManager.resize();
    }
    
    /**
     * Pause the game
     * Stops all gameplay updates but allows UI to continue
     */
    public function pause() {
        if (!isPaused) {
            isPaused = true;
            trace("Game paused");
            
            // Future: Show pause menu
            // sceneManager.pushScene("pause");
        }
    }
    
    /**
     * Resume the game from pause
     */
    public function resume() {
        if (isPaused) {
            isPaused = false;
            trace("Game resumed");
            
            // Future: Hide pause menu
            // sceneManager.popScene();
        }
    }
    
    /**
     * Set global game speed
     * Useful for slow-motion effects or speed-up power-ups
     * 
     * @param speed Speed multiplier (1.0 = normal, 0.5 = half speed)
     */
    public function setGameSpeed(speed:Float) {
        gameSpeed = Math.max(0.1, Math.min(2.0, speed));
        trace("Game speed set to: " + gameSpeed);
    }
    
    /**
     * Quick access to switch scenes
     * @param sceneName Name of the scene to switch to
     */
    public function switchScene(sceneName:String) {
        sceneManager.switchTo(sceneName);
    }
    
    /**
     * Trigger a hit pause effect
     * Freezes the game momentarily to emphasize impact
     * 
     * @param duration How long to pause (in seconds)
     */
    public function triggerHitPause(duration:Float = 0.05) {
        hitPauseTime = duration;
        isHitPaused = true;
    }
    
    /**
     * Clean up resources
     */
    public function dispose() {
        // Future: Clean up any global resources
        // sceneManager doesn't need disposal as scenes clean themselves up
    }
}