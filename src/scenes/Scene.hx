package scenes;

import h2d.Scene as H2dScene;

class Scene extends H2dScene {
    public var sceneName: String;
    public var isTransitioning: Bool = false;
    
    var app: Main;
    
    public function new(app: Main, name: String) {
        super();
        this.app = app;
        this.sceneName = name;
    }
    
    public function enter(): Void {
        // Called when scene becomes active
        #if debug
        trace('Entering scene: $sceneName');
        #end
    }
    
    public function exit(): Void {
        // Called when leaving this scene
        #if debug
        trace('Exiting scene: $sceneName');
        #end
    }
    
    public function update(dt: Float): Void {
        // Override in subclasses for scene-specific updates
    }
    
    public function fixedUpdate(dt: Float): Void {
        // Override in subclasses for fixed timestep logic
    }
    
    public function renderScene(dt: Float, alpha: Float): Void {
        // Override in subclasses for rendering with interpolation
    }
    
    public function resize(): Void {
        // Called when window is resized
        // Base resolution is fixed, scenes should use Main.GAME_WIDTH/HEIGHT
    }
    
    public var gameWidth(get, never): Int;
    public var gameHeight(get, never): Int;
    
    inline function get_gameWidth(): Int {
        return 320; // Match Main.GAME_WIDTH
    }
    
    inline function get_gameHeight(): Int {
        return 240; // Match Main.GAME_HEIGHT
    }
    
    override public function dispose(): Void {
        // Clean up resources
        super.dispose();
    }
}