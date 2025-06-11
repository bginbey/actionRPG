package scenes;

import h2d.Text;
import ui.PixelText;
import systems.Tilemap;
import systems.Camera;
import utils.TilesetGenerator;
import utils.ColorPalette;

class GameScene extends Scene {
    var debugText: Text;
    var tilemap: Tilemap;
    var player: h2d.Graphics;
    var playerX: Float = 160;
    var playerY: Float = 120;
    var gameCamera: Camera;
    var worldContainer: h2d.Object;
    var uiContainer: h2d.Object;
    
    public function new(app: Main) {
        super(app, "game");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Set background color
        app.engine.backgroundColor = ColorPalette.BLACK;
        
        // Create containers
        worldContainer = new h2d.Object(this);
        uiContainer = new h2d.Object(this);
        
        // Create camera
        gameCamera = new Camera(worldContainer, gameWidth, gameHeight);
        
        // Create tilemap in world container
        tilemap = new Tilemap(worldContainer);
        
        // Load test level
        loadTestLevel();
        
        // Set camera bounds based on level size
        gameCamera.setWorldBounds(tilemap.widthInPixels, tilemap.heightInPixels);
        
        // Create simple player placeholder in world container
        player = new h2d.Graphics(worldContainer);
        player.beginFill(ColorPalette.CYAN);
        player.drawRect(-8, -8, 16, 16);
        player.endFill();
        
        // Set camera to follow player
        gameCamera.follow(player);
        gameCamera.centerOn(playerX, playerY);
        
        // Debug text in UI container (not affected by camera)
        var pixelDebug = new PixelText(uiContainer);
        pixelDebug.text = "WASD/Arrows - F1 for free cam - F2 for shake";
        pixelDebug.setPixelScale(1);
        pixelDebug.x = 10;
        pixelDebug.y = 10;
        debugText = pixelDebug;
    }
    
    function loadTestLevel() {
        // Create test tileset
        var tilesetImage = TilesetGenerator.createTestTileset();
        
        // Create a larger test level
        var levelData = {
            width: 40,
            height: 30,
            tileSize: 16,
            tiles: [],
            collisionTiles: [false, true, true, true]
        };
        
        // Generate a larger level procedurally
        for (y in 0...30) {
            for (x in 0...40) {
                var tile = 0;
                
                // Borders
                if (x == 0 || x == 39 || y == 0 || y == 29) {
                    tile = 1;
                }
                // Some obstacles
                else if ((x % 8 == 3 || x % 8 == 4) && (y % 6 == 2 || y % 6 == 3)) {
                    tile = 2;
                }
                // Special tiles
                else if (x % 8 == 3 && y % 6 == 2) {
                    tile = 3;
                }
                
                levelData.tiles.push(tile);
            }
        }
        
        tilemap.loadFromData(levelData, tilesetImage);
        
        // Set player start position (in a clear area)
        playerX = 10 * Tilemap.TILE_SIZE;
        playerY = 10 * Tilemap.TILE_SIZE;
    }
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // Debug camera controls
        if (hxd.Key.isPressed(hxd.Key.F1)) {
            gameCamera.debugMode = !gameCamera.debugMode;
            debugText.text = gameCamera.debugMode ? 
                "FREE CAM MODE - WASD to move camera" : 
                "WASD/Arrows - F1 for free cam - F2 for shake";
        }
        
        if (hxd.Key.isPressed(hxd.Key.F2)) {
            gameCamera.shake(0.5);
        }
        
        if (gameCamera.debugMode) {
            // Free camera movement
            var camSpeed = 200.0;
            if (hxd.Key.isDown(hxd.Key.W)) gameCamera.y -= camSpeed * dt;
            if (hxd.Key.isDown(hxd.Key.S)) gameCamera.y += camSpeed * dt;
            if (hxd.Key.isDown(hxd.Key.A)) gameCamera.x -= camSpeed * dt;
            if (hxd.Key.isDown(hxd.Key.D)) gameCamera.x += camSpeed * dt;
        } else {
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
            
            // Check collision at new position (checking 4 corners of player)
            var halfSize = 7; // Player is 16x16, so half is 8, minus 1 for margin
            var canMove = true;
            
            // Check all four corners
            if (tilemap.isSolidAtPixel(newX - halfSize, newY - halfSize) ||
                tilemap.isSolidAtPixel(newX + halfSize, newY - halfSize) ||
                tilemap.isSolidAtPixel(newX - halfSize, newY + halfSize) ||
                tilemap.isSolidAtPixel(newX + halfSize, newY + halfSize)) {
                canMove = false;
            }
            
            if (canMove) {
                playerX = newX;
                playerY = newY;
            }
            
            // Update player position
            player.x = playerX;
            player.y = playerY;
        }
        
        // Update camera
        gameCamera.update(dt);
        gameCamera.apply();
        
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