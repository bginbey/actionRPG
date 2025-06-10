package scenes;

import h2d.Text;
import ui.PixelText;

class GameScene extends Scene {
    var debugText: Text;
    
    public function new(app: Main) {
        super(app, "game");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Temporary debug text
        var pixelDebug = new PixelText(this);
        pixelDebug.text = "GAME SCENE - Press ESC to return to menu";
        pixelDebug.setPixelScale(1);
        pixelDebug.x = 10;
        pixelDebug.y = 10;
        debugText = pixelDebug;
        
        // Test resource loading
        // #if debug
        // try {
        //     var testData = haxe.Json.parse(hxd.Res.data.test.entry.getText());
        //     trace("Resource test: " + testData.testData.message);
        //     trace("Player health: " + testData.testData.playerStats.health);
        // } catch (e:Dynamic) {
        //     trace("Resource loading test failed: " + e);
        // }
        // #end
    }
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // ESC to return to menu
        if (hxd.Key.isPressed(hxd.Key.ESCAPE)) {
            app.sceneManager.switchTo("menu", {
                duration: 0.3,
                fadeColor: 0x000000,
                onComplete: null
            });
        }
    }
}