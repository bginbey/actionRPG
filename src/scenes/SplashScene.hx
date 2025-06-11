package scenes;

import h2d.Text;
import h2d.Object;
import ui.PixelText;

class SplashScene extends Scene {
    static inline var DISPLAY_DURATION: Float = 2.0; // Time to show splash
    static inline var FADE_DURATION: Float = 0.5;
    
    var splashText: Text;
    var studioText: Text;
    var skipText: Text;
    var fadeOverlay: h2d.Graphics;
    
    var timer: Float = 0.0;
    var state: SplashState = FadeIn;
    
    public function new(app: Main) {
        super(app, "splash");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Create splash content
        var centerX = gameWidth * 0.5;
        var centerY = gameHeight * 0.5;
        
        // Studio name
        var pixelStudio = new PixelText(this);
        pixelStudio.text = "PIXEL FORGE STUDIOS";
        pixelStudio.textAlign = Center;
        pixelStudio.setPixelScale(2);
        pixelStudio.x = centerX;
        pixelStudio.y = centerY - 30;
        studioText = pixelStudio;
        
        // Game title
        var pixelSplash = new PixelText(this);
        pixelSplash.text = "presents";
        pixelSplash.textAlign = Center;
        pixelSplash.setPixelScale(1);
        pixelSplash.x = centerX;
        pixelSplash.y = centerY + 10;
        splashText = pixelSplash;
        
        // Skip hint
        var pixelSkip = new PixelText(this);
        pixelSkip.text = "Press SPACE to skip";
        pixelSkip.textAlign = Center;
        pixelSkip.setPixelScale(1);
        pixelSkip.x = centerX;
        pixelSkip.y = gameHeight - 40;
        pixelSkip.alpha = 0.5;
        skipText = pixelSkip;
        
        // Fade overlay
        fadeOverlay = new h2d.Graphics(this);
        updateFadeOverlay(1.0); // Start fully black
        
        timer = 0.0;
        state = FadeIn;
    }
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // Skip splash on any key press
        if (hxd.Key.isPressed(hxd.Key.SPACE) || hxd.Key.isPressed(hxd.Key.ENTER) || 
            hxd.Key.isPressed(hxd.Key.ESCAPE)) {
            if (state != FadeOut) {
                timer = 0.0;
                state = FadeOut;
            }
        }
        
        timer += dt;
        
        switch (state) {
            case FadeIn:
                var alpha = 1.0 - (timer / FADE_DURATION);
                updateFadeOverlay(Math.max(0, alpha));
                
                if (timer >= FADE_DURATION) {
                    timer = 0.0;
                    state = Display;
                }
                
            case Display:
                if (timer >= DISPLAY_DURATION) {
                    timer = 0.0;
                    state = FadeOut;
                }
                
            case FadeOut:
                var alpha = timer / FADE_DURATION;
                updateFadeOverlay(Math.min(1.0, alpha));
                
                if (timer >= FADE_DURATION) {
                    // Transition to menu
                    app.sceneManager.switchTo("menu");
                }
        }
    }
    
    function updateFadeOverlay(alpha: Float): Void {
        fadeOverlay.clear();
        fadeOverlay.beginFill(0x000000, alpha);
        fadeOverlay.drawRect(0, 0, gameWidth, gameHeight);
        fadeOverlay.endFill();
    }
    
    override public function resize(): Void {
        super.resize();
        
        var centerX = gameWidth * 0.5;
        var centerY = gameHeight * 0.5;
        
        if (studioText != null) {
            studioText.x = centerX;
            studioText.y = centerY - 30;
        }
        
        if (splashText != null) {
            splashText.x = centerX;
            splashText.y = centerY + 10;
        }
        
        if (skipText != null) {
            skipText.x = centerX;
            skipText.y = gameHeight - 40;
        }
        
        if (fadeOverlay != null && state != null) {
            var alpha = switch (state) {
                case FadeIn: 1.0 - (timer / FADE_DURATION);
                case Display: 0.0;
                case FadeOut: timer / FADE_DURATION;
            };
            updateFadeOverlay(Math.max(0, Math.min(1.0, alpha)));
        }
    }
}

enum SplashState {
    FadeIn;
    Display;
    FadeOut;
}