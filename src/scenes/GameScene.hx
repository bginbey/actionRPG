package scenes;

import h2d.Text;
import ui.PixelText;
import systems.Tilemap;
import systems.Camera;
import systems.CollisionWorld;
import systems.InputManager;
import utils.TilesetGenerator;
import utils.ColorPalette;
import entities.Player;
import effects.particles.ParticleSystem;
import effects.RainEffect;

class GameScene extends Scene {
    var debugText: Text;
    var tilemap: Tilemap;
    var player: Player;
    var gameCamera: Camera;
    var collisionWorld: CollisionWorld;
    var worldContainer: h2d.Object;
    var uiContainer: h2d.Object;
    var ghostContainer: h2d.Object;
    var particleSystem: ParticleSystem;
    var rainEffect: RainEffect;
    var debugGraphics: h2d.Graphics;
    var debugMode: Bool = false;
    var showHelp: Bool = false;
    var inputManager: InputManager;
    
    public function new(app: Main) {
        super(app, "game");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Set background color
        app.engine.backgroundColor = ColorPalette.BLACK;
        
        // Create input manager
        inputManager = new InputManager();
        
        // Create containers
        worldContainer = new h2d.Object(this);
        uiContainer = new h2d.Object(this);
        
        // Create camera
        gameCamera = new Camera(worldContainer, gameWidth, gameHeight);
        
        // Create tilemap in world container
        tilemap = new Tilemap(worldContainer);
        
        // Load test level
        loadTestLevel();
        
        // Create collision world from tilemap
        collisionWorld = new CollisionWorld(tilemap);
        
        // Set camera bounds based on level size
        gameCamera.setWorldBounds(tilemap.widthInPixels, tilemap.heightInPixels);
        
        // Create ghost container (behind player)
        ghostContainer = new h2d.Object(worldContainer);
        
        // Create player entity
        player = new Player(worldContainer, collisionWorld, ghostContainer);
        player.setPosGrid(10, 10);  // Start at grid position 10,10
        
        // Create particle system after player (renders on top)
        particleSystem = new ParticleSystem(worldContainer);
        
        // Create rain effect
        rainEffect = new RainEffect(particleSystem, gameCamera, gameWidth, gameHeight);
        rainEffect.start();  // Start with rain on
        
        // Set camera to follow player
        gameCamera.follow(player);
        gameCamera.centerOn(player.x, player.y);
        
        // Create debug graphics layer
        debugGraphics = new h2d.Graphics(worldContainer);
        
        // Debug text in UI container (not affected by camera)
        var pixelDebug = new PixelText(uiContainer);
        pixelDebug.text = "";  // Start with no text
        pixelDebug.setPixelScale(1);
        pixelDebug.x = 10;
        pixelDebug.y = 10;
        debugText = pixelDebug;
        debugText.visible = false;  // Hidden by default
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
    }
    
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // Debug controls
        if (hxd.Key.isPressed(hxd.Key.F1)) {
            gameCamera.debugMode = !gameCamera.debugMode;
            updateDebugText();
        }
        
        if (hxd.Key.isPressed(hxd.Key.F2)) {
            gameCamera.shake(0.5);
        }
        
        // Toggle debug visualization with backtick key
        if (hxd.Key.isPressed(192)) { // Backtick/tilde key
            debugMode = !debugMode;
            if (!debugMode) {
                debugGraphics.clear();
            }
            debugText.visible = showHelp || debugMode;
            updateDebugText();
        }
        
        // Toggle rain with R key
        if (hxd.Key.isPressed(hxd.Key.R)) {
            rainEffect.toggle();
            trace("Rain toggled: " + rainEffect.isActive);
            updateDebugText();
        }
        
        // Toggle help text with H key
        if (hxd.Key.isPressed(hxd.Key.H)) {
            showHelp = !showHelp;
            debugText.visible = showHelp || debugMode;
            updateDebugText();
        }
        
        // Test burst with B key
        if (hxd.Key.isPressed(hxd.Key.B)) {
            particleSystem.burst(player.px, player.py, 50, {
                speedMin: 50,
                speedMax: 200,
                color: 0xFF8800,  // Orange burst
                gravity: 200
            });
        }
        
        if (gameCamera.debugMode) {
            // Free camera movement
            var camSpeed = 200.0;
            if (hxd.Key.isDown(hxd.Key.W)) gameCamera.y -= camSpeed * dt;
            if (hxd.Key.isDown(hxd.Key.S)) gameCamera.y += camSpeed * dt;
            if (hxd.Key.isDown(hxd.Key.A)) gameCamera.x -= camSpeed * dt;
            if (hxd.Key.isDown(hxd.Key.D)) gameCamera.x += camSpeed * dt;
        } else {
            // Handle input press/release events
            // UP
            if (hxd.Key.isPressed(hxd.Key.W) || hxd.Key.isPressed(hxd.Key.UP)) 
                inputManager.onKeyPress(InputManager.DIR_UP);
            if (hxd.Key.isReleased(hxd.Key.W) || hxd.Key.isReleased(hxd.Key.UP)) 
                inputManager.onKeyRelease(InputManager.DIR_UP);
                
            // DOWN
            if (hxd.Key.isPressed(hxd.Key.S) || hxd.Key.isPressed(hxd.Key.DOWN)) 
                inputManager.onKeyPress(InputManager.DIR_DOWN);
            if (hxd.Key.isReleased(hxd.Key.S) || hxd.Key.isReleased(hxd.Key.DOWN)) 
                inputManager.onKeyRelease(InputManager.DIR_DOWN);
                
            // LEFT
            if (hxd.Key.isPressed(hxd.Key.A) || hxd.Key.isPressed(hxd.Key.LEFT)) 
                inputManager.onKeyPress(InputManager.DIR_LEFT);
            if (hxd.Key.isReleased(hxd.Key.A) || hxd.Key.isReleased(hxd.Key.LEFT)) 
                inputManager.onKeyRelease(InputManager.DIR_LEFT);
                
            // RIGHT
            if (hxd.Key.isPressed(hxd.Key.D) || hxd.Key.isPressed(hxd.Key.RIGHT)) 
                inputManager.onKeyPress(InputManager.DIR_RIGHT);
            if (hxd.Key.isReleased(hxd.Key.D) || hxd.Key.isReleased(hxd.Key.RIGHT)) 
                inputManager.onKeyRelease(InputManager.DIR_RIGHT);
            
            // Get movement vector from input manager
            var movement = inputManager.getMovementVector();
            player.setInput(movement.x, movement.y);
            
            // Dash input (Space or Shift)
            if (hxd.Key.isPressed(hxd.Key.SPACE) || hxd.Key.isPressed(hxd.Key.SHIFT)) {
                player.tryDash();
            }
        }
        
        // Update player
        if (!gameCamera.debugMode) {
            player.update(dt);
        }
        
        // Update camera
        gameCamera.update(dt);
        gameCamera.apply();
        
        // Update rain effect
        rainEffect.update(dt);
        
        // Update particle system
        particleSystem.update(dt);
        
        // Draw debug visualization
        if (debugMode) {
            drawDebug();
        }
        
        // Update debug text to show dash cooldown
        updateDebugText();
        
        // ESC to return to menu
        if (hxd.Key.isPressed(hxd.Key.ESCAPE)) {
            app.sceneManager.switchTo("menu", {
                duration: 0.3,
                fadeColor: 0x000000,
                onComplete: null
            });
        }
    }
    
    function drawDebug() {
        debugGraphics.clear();
        
        // Draw collision world bounds
        collisionWorld.debugDraw(debugGraphics);
        
        
        // Draw player sprite rect (red border)
        debugGraphics.lineStyle(1, 0xFF0000, 1);
        debugGraphics.drawRect(player.px - 16, player.py - 16, 32, 32);
        
        // Draw player collider (white when invincible, cyan when dashing, green normally)
        var colliderColor = player.isInvincible ? 0xFFFFFF : (player.isDashing ? 0x00FFFF : 0x00FF00);
        debugGraphics.lineStyle(2, colliderColor, 1);
        debugGraphics.drawCircle(player.px, player.py, player.radius);
        
        // Draw desired movement vector (red if blocked)
        if (player.desiredDx != 0 || player.desiredDy != 0) {
            var color = (player.lastHitX || player.lastHitY) ? 0xFF0000 : 0x00FF00;
            debugGraphics.lineStyle(3, color, 0.8);
            debugGraphics.moveTo(player.px, player.py);
            debugGraphics.lineTo(
                player.px + player.desiredDx * 50, 
                player.py + player.desiredDy * 50
            );
            
            // Draw collision indicators
            if (player.lastHitX) {
                debugGraphics.lineStyle(2, 0xFF0000, 1);
                var dir = player.desiredDx > 0 ? 1 : -1;
                debugGraphics.moveTo(player.px + dir * player.radius, player.py - player.radius);
                debugGraphics.lineTo(player.px + dir * player.radius, player.py + player.radius);
            }
            if (player.lastHitY) {
                debugGraphics.lineStyle(2, 0xFF0000, 1);
                var dir = player.desiredDy > 0 ? 1 : -1;
                debugGraphics.moveTo(player.px - player.radius, player.py + dir * player.radius);
                debugGraphics.lineTo(player.px + player.radius, player.py + dir * player.radius);
            }
        }
        
        // Draw actual movement vector (yellow)
        if (player.dx != 0 || player.dy != 0) {
            debugGraphics.lineStyle(2, 0xFFFF00, 1);
            debugGraphics.moveTo(player.px, player.py);
            debugGraphics.lineTo(
                player.px + player.dx * 50, 
                player.py + player.dy * 50
            );
        }
        
        // Draw corner push visualization
        if (player.lastCornerPush.x != 0 || player.lastCornerPush.y != 0) {
            // Orange circle at push origin
            debugGraphics.lineStyle(2, 0xFF8800, 1);
            debugGraphics.drawCircle(
                player.px - player.lastCornerPush.x, 
                player.py - player.lastCornerPush.y, 
                3
            );
            
            // Blue arrow showing push direction
            debugGraphics.lineStyle(3, 0x00CCFF, 0.8);
            debugGraphics.moveTo(
                player.px - player.lastCornerPush.x, 
                player.py - player.lastCornerPush.y
            );
            debugGraphics.lineTo(player.px, player.py);
        }
        
        // Draw player center point
        debugGraphics.lineStyle(1, 0xFFFFFF, 1);
        debugGraphics.drawCircle(player.px, player.py, 2);
    }
    
    function updateDebugText() {
        if (!showHelp && !debugMode) {
            debugText.text = "";
            return;
        }
        
        var text = showHelp ? "H help - WASD/Arrows move - Space/Shift dash - F1 cam - F2 shake - R rain - ` debug" : "";
        
        if (gameCamera.debugMode) {
            text = "FREE CAM MODE - WASD to move camera";
        }
        if (debugMode) {
            text += " [DEBUG ON]";
        }
        if (!player.canDash()) {
            var cooldown = Math.ceil(player.getDashCooldownPercent() * 100);
            text += " [DASH CD: " + cooldown + "%]";
        }
        if (particleSystem != null && debugMode) {
            text += " [Particles: " + particleSystem.totalActiveParticles + "]";
        }
        if (rainEffect != null && debugMode) {
            text += rainEffect.isActive ? " [RAIN ON]" : " [RAIN OFF]";
        }
        debugText.text = text;
    }
    
    override public function exit(): Void {
        // Clear input state when leaving scene
        if (inputManager != null) {
            inputManager.clear();
        }
        
        // Clean up effects
        if (rainEffect != null) {
            rainEffect.dispose();
        }
        
        super.exit();
    }
}