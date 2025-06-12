package scenes;

import systems.Tilemap;
import systems.Camera;
import systems.CollisionWorld;
import systems.InputManager;
import systems.DebugRenderer;
import systems.LevelLoader;
import ui.GameHUD;
import utils.ColorPalette;
import utils.GameConstants;
import entities.Player;
import entities.Enemy;
import entities.AIState;
import systems.effects.particles.ParticleSystem;
import entities.effects.RainEffect;

/**
 * Main gameplay scene
 * 
 * Coordinates all game systems and manages gameplay flow.
 * This scene has been refactored to delegate specific responsibilities
 * to dedicated systems, keeping it focused on coordination.
 * 
 * Systems managed:
 * - Camera: Viewport and following
 * - Tilemap: Level tiles and visuals
 * - CollisionWorld: Physics and collision detection
 * - InputManager: Player input handling
 * - DebugRenderer: Visual debugging tools
 * - GameHUD: User interface elements
 * - ParticleSystem: Visual effects
 * - RainEffect: Weather effects
 * 
 * Controls:
 * - WASD/Arrows: Move player
 * - Space/Shift: Dash
 * - R: Toggle rain
 * - H: Toggle help
 * - `: Toggle debug view
 * - F1: Free camera mode
 * - F2: Camera shake
 * - B: Particle burst test
 * - ESC: Return to menu
 * 
 * @see LevelLoader for level generation
 * @see DebugRenderer for debug visualization
 * @see GameHUD for UI management
 */
class GameScene extends Scene {
    // === Core Systems ===
    var tilemap: Tilemap;
    var gameCamera: Camera;
    var collisionWorld: CollisionWorld;
    var inputManager: InputManager;
    var debugRenderer: DebugRenderer;
    var gameHUD: GameHUD;
    var particleSystem: ParticleSystem;
    
    // === Containers ===
    var worldContainer: h2d.Object;    // Affected by camera
    var uiContainer: h2d.Object;       // Screen space UI
    var ghostContainer: h2d.Object;    // For ghost effects
    
    // === Entities ===
    var player: Player;
    var enemies: Array<entities.Enemy>;
    var enemyContainer: h2d.Object;
    var rainEffect: RainEffect;
    
    public function new(app: Main) {
        super(app, "game");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Set background color
        app.engine.backgroundColor = ColorPalette.BLACK;
        
        // === Initialize containers ===
        worldContainer = new h2d.Object(this);
        uiContainer = new h2d.Object(this);
        
        // === Initialize core systems ===
        inputManager = new InputManager();
        gameCamera = new Camera(worldContainer, gameWidth, gameHeight);
        tilemap = new Tilemap(worldContainer);
        
        // === Load level ===
        LevelLoader.loadTestLevel(tilemap);
        
        // === Setup collision ===
        collisionWorld = new CollisionWorld(tilemap);
        gameCamera.setWorldBounds(tilemap.widthInPixels, tilemap.heightInPixels);
        
        // === Create entities ===
        ghostContainer = new h2d.Object(worldContainer);
        enemyContainer = new h2d.Object(worldContainer);
        enemies = [];
        
        player = new Player(worldContainer, collisionWorld, ghostContainer);
        
        // Get spawn point from level metadata
        var metadata = LevelLoader.loadMetadata(null);
        player.setPosGrid(metadata.playerSpawn.x, metadata.playerSpawn.y);
        
        // Spawn some test enemies
        spawnTestEnemies();
        
        // === Setup camera ===
        gameCamera.follow(player);
        gameCamera.centerOn(player.x, player.y);
        
        // === Initialize effects ===
        particleSystem = new ParticleSystem(worldContainer);
        rainEffect = new RainEffect(particleSystem, gameCamera, gameWidth, gameHeight);
        rainEffect.start();  // Start with rain on
        
        // === Initialize UI ===
        var debugGraphics = new h2d.Graphics(worldContainer);
        debugRenderer = new DebugRenderer(debugGraphics);
        gameHUD = new GameHUD(uiContainer);
    }
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // === Handle debug controls ===
        handleDebugControls();
        
        // === Handle player input ===
        if (!gameCamera.debugMode) {
            handlePlayerInput();
            player.update(dt);
        } else {
            handleCameraDebugInput(dt);
        }
        
        // === Update systems ===
        gameCamera.update(dt);
        gameCamera.apply();
        rainEffect.update(dt);
        particleSystem.update(dt);
        gameHUD.update(dt);
        
        // === Update enemies ===
        for (enemy in enemies) {
            if (enemy.parent != null) {
                enemy.update(dt);
            }
        }
        
        // Clean up dead enemies
        enemies = enemies.filter(e -> e.parent != null);
        
        // === Check combat ===
        // Check player attacks against enemies
        var playerHitbox = player.getCurrentHitbox();
        if (playerHitbox != null) {
            var hits = playerHitbox.checkHits(cast enemies);
            if (hits.length > 0) {
                // Apply hit pause and screen shake only once per frame
                app.game.triggerHitPause(GameConstants.HIT_PAUSE_DURATION);
                gameCamera.shake(0.5); // Player hitting enemies
                
                // Apply damage to all hit enemies
                for (hit in hits) {
                    playerHitbox.applyHit(hit);
                    // TODO: Add hit particles
                }
            }
        }
        
        // === Update debug rendering ===
        if (debugRenderer.isEnabled()) {
            debugRenderer.render(collisionWorld, player);
        }
        
        // === Update HUD text ===
        updateHUDText();
        
        // === Handle scene transition ===
        if (hxd.Key.isPressed(hxd.Key.ESCAPE)) {
            app.game.sceneManager.switchTo("menu", {
                duration: 0.3,
                fadeColor: 0x000000,
                onComplete: null
            });
        }
    }
    
    /**
     * Handle debug-related keyboard controls
     */
    function handleDebugControls():Void {
        // Toggle free camera mode
        if (hxd.Key.isPressed(hxd.Key.F1)) {
            gameCamera.debugMode = !gameCamera.debugMode;
        }
        
        // Test camera shake
        if (hxd.Key.isPressed(hxd.Key.F2)) {
            gameCamera.shake(GameConstants.CAMERA_SHAKE_DURATION);
        }
        
        // Toggle debug visualization
        if (hxd.Key.isPressed(GameConstants.DEBUG_KEY_TOGGLE)) {
            debugRenderer.toggle();
            gameHUD.toggleDebug();
        }
        
        // Toggle rain
        if (hxd.Key.isPressed(hxd.Key.R)) {
            rainEffect.toggle();
            trace("Rain toggled: " + rainEffect.isActive);
        }
        
        // Toggle help
        if (hxd.Key.isPressed(hxd.Key.H)) {
            gameHUD.toggleHelp();
        }
        
        // Test particle burst
        if (hxd.Key.isPressed(hxd.Key.B)) {
            particleSystem.burst(player.px, player.py, 50, {
                speedMin: 50,
                speedMax: 200,
                color: 0xFF8800,  // Orange burst
                gravity: 200
            });
        }
    }
    
    /**
     * Handle player movement input
     */
    function handlePlayerInput():Void {
        // === Movement input ===
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
        
        // Apply movement to player
        var movement = inputManager.getMovementVector();
        player.setInput(movement.x, movement.y);
        
        // === Action input ===
        // Dash
        if (hxd.Key.isPressed(hxd.Key.SPACE) || hxd.Key.isPressed(hxd.Key.SHIFT)) {
            player.tryDash();
        }
        
        // Attack
        if (hxd.Key.isPressed(hxd.Key.J) || hxd.Key.isPressed(hxd.Key.X)) {
            player.tryAttack();
        }
    }
    
    /**
     * Handle camera movement in debug mode
     */
    function handleCameraDebugInput(dt:Float):Void {
        var camSpeed = GameConstants.CAMERA_DEBUG_SPEED;
        if (hxd.Key.isDown(hxd.Key.W)) gameCamera.y -= camSpeed * dt;
        if (hxd.Key.isDown(hxd.Key.S)) gameCamera.y += camSpeed * dt;
        if (hxd.Key.isDown(hxd.Key.A)) gameCamera.x -= camSpeed * dt;
        if (hxd.Key.isDown(hxd.Key.D)) gameCamera.x += camSpeed * dt;
    }
    
    /**
     * Update HUD text based on current state
     */
    function updateHUDText():Void {
        var text = "";
        
        // Build text based on what's visible
        if (gameHUD.isHelpVisible()) {
            text = gameHUD.getHelpText();
        }
        
        // Add debug-specific text
        if (gameHUD.isDebugVisible() || gameCamera.debugMode) {
            text += debugRenderer.getDebugText(
                gameCamera.debugMode,
                player.canDash(),
                player.getDashCooldownPercent(),
                particleSystem,
                rainEffect,
                player
            );
        }
        
        gameHUD.updateDebugText(text);
    }
    
    /**
     * Spawn test enemies for combat testing
     */
    function spawnTestEnemies():Void {
        // Spawn a few enemies around the map
        var spawnPoints = [
            {x: 15, y: 10},
            {x: 25, y: 15},
            {x: 20, y: 20},
            {x: 10, y: 18}
        ];
        
        for (spawn in spawnPoints) {
            var enemy = new entities.Enemy(enemyContainer, collisionWorld, player);
            enemy.setPosGrid(spawn.x, spawn.y);
            enemies.push(enemy);
            
            // Set hit callback for screen effects
            enemy.onHitPlayer = () -> {
                app.game.triggerHitPause(GameConstants.HIT_PAUSE_DURATION * 0.5);
                gameCamera.shake(0.4); // Enemies hitting player
            };
            
            // Start with patrol behavior
            enemy.currentState = AIState.Patrol;
        }
    }
    
    override public function exit(): Void {
        // Clean up systems
        if (inputManager != null) {
            inputManager.clear();
        }
        
        if (rainEffect != null) {
            rainEffect.dispose();
        }
        
        if (gameHUD != null) {
            gameHUD.dispose();
        }
        
        super.exit();
    }
}