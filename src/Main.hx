import hxd.App;
// import hxd.Res;
import scenes.SceneManager;
import scenes.SplashScene;
import scenes.MenuScene;
import scenes.GameScene;

class Main extends App {
    // Fixed timestep configuration
    static inline var FIXED_TIMESTEP: Float = 1.0 / 60.0; // 60 FPS logic
    static inline var MAX_FRAMESKIP: Int = 5;
    
    // Base game resolution
    static inline var GAME_WIDTH: Int = 320;
    static inline var GAME_HEIGHT: Int = 240;
    
    var accumulator: Float = 0.0;
    var currentTime: Float = 0.0;
    var currentScale: Int = 1;
    
    public var sceneManager: SceneManager;
    
    static function main() {
        new Main();
    }
    
    public function new() {
        super();
        
        // Make the canvas fill the window on web
        #if js
        var canvas = js.Browser.document.getElementById("webgl");
        if (canvas != null) {
            canvas.style.width = "100%";
            canvas.style.height = "100%";
        }
        #end
    }
    
    override function init() {
        super.init();
        
        // Initialize resource loader
        // #if debug
        // hxd.Res.initLocal();
        // #else
        // hxd.Res.initEmbed();
        // #end
        
        // Set up window
        engine.backgroundColor = 0x1a1a2e;
        
        // Initialize timing
        currentTime = hxd.Timer.lastTimeStamp;
        
        // Initialize scene manager
        sceneManager = new SceneManager(this);
        
        // Register scenes
        sceneManager.addScene(new SplashScene(this));
        sceneManager.addScene(new MenuScene(this));
        sceneManager.addScene(new GameScene(this));
        
        // Start with splash scene
        sceneManager.switchTo("splash");
        
        // Apply initial scaling
        updateScaling();
        
        // Debug info
        #if debug
        trace("Main init complete, starting with splash scene");
        trace("Action RPG initialized");
        trace("Game resolution: " + GAME_WIDTH + "x" + GAME_HEIGHT);
        trace("Window size: " + s2d.width + "x" + s2d.height);
        trace("Current scale: " + currentScale + "x");
        trace("Fixed timestep: " + FIXED_TIMESTEP + "s (" + (1.0/FIXED_TIMESTEP) + " FPS)");
        #end
    }
    
    function updateScaling() {
        var window = hxd.Window.getInstance();
        var windowWidth = window.width;
        var windowHeight = window.height;
        
        // Calculate the largest integer scale that fits
        var scaleX = Math.floor(windowWidth / GAME_WIDTH);
        var scaleY = Math.floor(windowHeight / GAME_HEIGHT);
        currentScale = Std.int(Math.max(1, Math.min(scaleX, scaleY)));
        
        // Apply scale to the main scene
        s2d.scaleX = s2d.scaleY = currentScale;
        
        // Center the game view
        var scaledWidth = GAME_WIDTH * currentScale;
        var scaledHeight = GAME_HEIGHT * currentScale;
        s2d.x = Math.floor((windowWidth - scaledWidth) / 2);
        s2d.y = Math.floor((windowHeight - scaledHeight) / 2);
        
        #if debug
        trace("Window: " + windowWidth + "x" + windowHeight + " -> Scale: " + currentScale + "x");
        #end
    }
    
    override function update(dt:Float) {
        // Handle fullscreen toggle
        if (hxd.Key.isPressed(hxd.Key.F11)) {
            var window = hxd.Window.getInstance();
            window.displayMode = window.displayMode == Fullscreen ? Windowed : Fullscreen;
        }
        
        // Fixed timestep implementation
        var newTime = hxd.Timer.lastTimeStamp;
        var frameTime = Math.min(newTime - currentTime, FIXED_TIMESTEP * MAX_FRAMESKIP);
        currentTime = newTime;
        
        accumulator += frameTime;
        
        // Fixed update loop
        while (accumulator >= FIXED_TIMESTEP) {
            fixedUpdate(FIXED_TIMESTEP);
            accumulator -= FIXED_TIMESTEP;
        }
        
        // Interpolation factor for smooth rendering
        var alpha = accumulator / FIXED_TIMESTEP;
        
        // Variable framerate update for rendering
        renderGame(dt, alpha);
    }
    
    function fixedUpdate(dt:Float) {
        // Fixed timestep game logic goes here
        sceneManager.fixedUpdate(dt);
    }
    
    function renderGame(dt:Float, alpha:Float) {
        // Rendering and interpolation logic goes here
        sceneManager.render(dt, alpha);
        
        // Update scene manager (for transitions)
        sceneManager.update(dt);
    }
    
    override function onResize() {
        super.onResize();
        updateScaling();
        sceneManager.resize();
    }
}