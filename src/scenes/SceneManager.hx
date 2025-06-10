package scenes;

import h2d.Object;

typedef Transition = {
    duration: Float,
    fadeColor: Int,
    onComplete: Void -> Void
};

class SceneManager {
    var app: Main;
    var scenes: Map<String, Scene> = new Map();
    var currentScene: Scene;
    var nextScene: Scene;
    
    // Transition overlay
    var transitionOverlay: h2d.Graphics;
    var transitionAlpha: Float = 0.0;
    var transitionTime: Float = 0.0;
    var currentTransition: Transition;
    
    public function new(app: Main) {
        this.app = app;
        
        // Create transition overlay
        transitionOverlay = new h2d.Graphics();
        transitionOverlay.visible = false;
    }
    
    public function addScene(scene: Scene): Void {
        scenes.set(scene.sceneName, scene);
        #if debug
        trace('Scene added: ${scene.sceneName}');
        #end
    }
    
    public function removeScene(name: String): Void {
        var scene = scenes.get(name);
        if (scene != null) {
            if (scene == currentScene) {
                throw 'Cannot remove active scene';
            }
            scene.dispose();
            scenes.remove(name);
        }
    }
    
    public function switchTo(name: String, ?transition: Transition): Void {
        var scene = scenes.get(name);
        if (scene == null) {
            throw 'Scene not found: $name';
        }
        
        if (currentScene != null && currentScene.isTransitioning) {
            return; // Already transitioning
        }
        
        nextScene = scene;
        
        if (transition != null) {
            startTransition(transition);
        } else {
            // Instant switch
            performSwitch();
        }
    }
    
    function startTransition(transition: Transition): Void {
        currentTransition = transition;
        transitionTime = 0.0;
        transitionAlpha = 0.0;
        transitionOverlay.visible = true;
        
        if (currentScene != null) {
            currentScene.isTransitioning = true;
        }
        nextScene.isTransitioning = true;
        
        // Add overlay to top of current scene
        if (app.s2d != null) {
            app.s2d.addChild(transitionOverlay);
        }
    }
    
    function performSwitch(): Void {
        if (currentScene != null) {
            currentScene.exit();
            currentScene.isTransitioning = false;
        }
        
        currentScene = nextScene;
        nextScene = null;
        
        // Set the new scene as active
        app.s2d.removeChildren();
        app.s2d.addChild(currentScene);
        
        currentScene.enter();
        currentScene.isTransitioning = false;
        currentScene.resize();
    }
    
    public function update(dt: Float): Void {
        // Update transition
        if (currentTransition != null) {
            transitionTime += dt;
            var halfDuration = currentTransition.duration * 0.5;
            
            if (transitionTime < halfDuration) {
                // Fade out
                transitionAlpha = transitionTime / halfDuration;
            } else if (transitionTime < currentTransition.duration) {
                // Switch scene at halfway point
                if (currentScene != nextScene && nextScene != null) {
                    performSwitch();
                }
                // Fade in
                transitionAlpha = 1.0 - ((transitionTime - halfDuration) / halfDuration);
            } else {
                // Transition complete
                transitionAlpha = 0.0;
                transitionOverlay.visible = false;
                currentTransition = null;
                
                if (currentTransition?.onComplete != null) {
                    currentTransition.onComplete();
                }
            }
            
            // Update overlay
            if (transitionOverlay.visible) {
                var w = app.s2d.width;
                var h = app.s2d.height;
                transitionOverlay.clear();
                transitionOverlay.beginFill(currentTransition.fadeColor, transitionAlpha);
                transitionOverlay.drawRect(0, 0, w, h);
                transitionOverlay.endFill();
            }
        }
        
        // Update current scene
        if (currentScene != null) {
            currentScene.update(dt);
        }
    }
    
    public function fixedUpdate(dt: Float): Void {
        if (currentScene != null && !currentScene.isTransitioning) {
            currentScene.fixedUpdate(dt);
        }
    }
    
    public function render(dt: Float, alpha: Float): Void {
        if (currentScene != null) {
            currentScene.renderScene(dt, alpha);
        }
    }
    
    public function resize(): Void {
        if (currentScene != null) {
            currentScene.resize();
        }
    }
    
    public function getCurrentScene(): Scene {
        return currentScene;
    }
}