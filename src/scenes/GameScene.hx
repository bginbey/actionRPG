package scenes;

import h2d.Text;
import ui.PixelText;
import systems.Tilemap;
import utils.TilesetGenerator;
import utils.ColorPalette;

class GameScene extends Scene {
    var debugText: Text;
    var tilemap: Tilemap;
    var player: h2d.Graphics;
    var playerX: Float = 160;
    var playerY: Float = 120;
    
    public function new(app: Main) {
        super(app, "game");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Set background color
        app.engine.backgroundColor = ColorPalette.BLACK;
        
        // Create tilemap
        tilemap = new Tilemap(this);
        
        // Load test level
        loadTestLevel();
        
        // Create simple player placeholder
        player = new h2d.Graphics(this);
        player.beginFill(ColorPalette.CYAN);
        player.drawRect(-8, -8, 16, 16);
        player.endFill();
        
        // Debug text
        var pixelDebug = new PixelText(this);
        pixelDebug.text = "WASD/Arrows to move - ESC for menu";
        pixelDebug.setPixelScale(1);
        pixelDebug.x = 10;
        pixelDebug.y = 10;
        debugText = pixelDebug;
    }
    
    function loadTestLevel() {
        // Create test tileset
        var tilesetImage = TilesetGenerator.createTestTileset();
        
        // For now, create level data directly (we'll load from JSON later)
        var levelData = {
            width: 20,
            height: 15,
            tileSize: 16,
            tiles: [
                1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,0,0,2,2,2,0,0,0,0,0,0,0,0,2,2,2,0,0,1,
                1,0,0,2,3,2,0,0,0,0,0,0,0,0,2,3,2,0,0,1,
                1,0,0,2,2,2,0,0,0,0,0,0,0,0,2,2,2,0,0,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,0,0,2,2,2,0,0,0,0,0,0,0,0,2,2,2,0,0,1,
                1,0,0,2,3,2,0,0,0,0,0,0,0,0,2,3,2,0,0,1,
                1,0,0,2,2,2,0,0,0,0,0,0,0,0,2,2,2,0,0,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
                1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
            ],
            collisionTiles: [false, true, true, true]
        };
        
        tilemap.loadFromData(levelData, tilesetImage);
        
        // Set player start position (center of room)
        playerX = 10 * Tilemap.TILE_SIZE;
        playerY = 7 * Tilemap.TILE_SIZE;
    }
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // Simple player movement
        var speed = 150.0;
        var dx = 0.0;
        var dy = 0.0;
        
        if (hxd.Key.isDown(hxd.Key.W) || hxd.Key.isDown(hxd.Key.UP)) dy -= 1;
        if (hxd.Key.isDown(hxd.Key.S) || hxd.Key.isDown(hxd.Key.DOWN)) dy += 1;
        if (hxd.Key.isDown(hxd.Key.A) || hxd.Key.isDown(hxd.Key.LEFT)) dx -= 1;
        if (hxd.Key.isDown(hxd.Key.D) || hxd.Key.isDown(hxd.Key.RIGHT)) dx += 1;
        
        // Normalize diagonal movement
        if (dx != 0 && dy != 0) {
            dx *= 0.707;
            dy *= 0.707;
        }
        
        // Apply movement with basic collision
        var newX = playerX + dx * speed * dt;
        var newY = playerY + dy * speed * dt;
        
        // Check collision at new position
        if (!tilemap.isSolidAtPixel(newX, newY)) {
            playerX = newX;
            playerY = newY;
        }
        
        // Update player position
        player.x = playerX;
        player.y = playerY;
        
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