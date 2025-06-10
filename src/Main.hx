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
    
    var accumulator: Float = 0.0;
    var currentTime: Float = 0.0;
    
    public var sceneManager: SceneManager;
    
    static function main() {
        new Main();
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
        
        // Debug info
        #if debug
        trace("Action RPG initialized");
        trace("Window size: " + s2d.width + "x" + s2d.height);
        trace("Fixed timestep: " + FIXED_TIMESTEP + "s (" + (1.0/FIXED_TIMESTEP) + " FPS)");
        #end
    }
    
    override function update(dt:Float) {
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
        sceneManager.resize();
    }
}