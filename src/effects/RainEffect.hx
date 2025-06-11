package effects;

import effects.particles.ParticleSystem;
import effects.particles.ParticleEmitter;
import systems.Camera;

/**
 * Dramatic angled rain effect
 */
class RainEffect {
    var particleSystem:ParticleSystem;
    var rainEmitter:ParticleEmitter;
    var camera:Camera;
    var gameWidth:Int;
    var gameHeight:Int;
    
    // Rain parameters
    public var baseEmissionRate:Float = 600;
    public var isActive(default, null):Bool = false;
    
    // Intensity variation
    var intensityTimer:Float = 0;
    
    public function new(particleSystem:ParticleSystem, camera:Camera, gameWidth:Int, gameHeight:Int) {
        this.particleSystem = particleSystem;
        this.camera = camera;
        this.gameWidth = gameWidth;
        this.gameHeight = gameHeight;
        
        setupRain();
    }
    
    function setupRain() {
        // Create rain streak tile (angled line)
        var rainTile = h2d.Tile.fromColor(0xFFFFFF, 1, 4);  // 4px tall line
        rainTile.dx = -0.5;  // Center X
        rainTile.dy = -2;    // Center Y
        
        var rainPool = particleSystem.getPool("rain", rainTile, 2000);
        
        // Create rain emitter
        rainEmitter = particleSystem.createEmitter("rain");
        rainEmitter.shape = Rectangle(gameWidth * 6, 100);  // Very wide spawn area
        rainEmitter.emissionRate = baseEmissionRate;
        rainEmitter.isEmitting = false;  // Start off
        
        // Rain particle properties - dramatic 45 degree angle
        var rainAngle = Math.PI * 0.75;  // 135 degrees
        rainEmitter.speedMin = 350;
        rainEmitter.speedMax = 550;
        rainEmitter.angleMin = rainAngle - 0.1;
        rainEmitter.angleMax = rainAngle + 0.1;
        
        rainEmitter.lifeMin = 2.5;
        rainEmitter.lifeMax = 3.0;
        
        rainEmitter.sizeMin = 1.0;
        rainEmitter.sizeMax = 1.0;
        
        rainEmitter.startAlpha = 1.0;
        rainEmitter.endAlpha = 1.0;
        
        rainEmitter.startColor = 0xFFFFFF;
        rainEmitter.endColor = 0xCCCCCC;
        
        rainEmitter.gravity = 50;
        rainEmitter.friction = 1.0;
        
        rainEmitter.rotationSpeedMin = 0;
        rainEmitter.rotationSpeedMax = 0;
    }
    
    public function start() {
        if (isActive) return;
        
        isActive = true;
        rainEmitter.isEmitting = true;
        
        // Warm up the rain with gradual spawning
        var originalRate = rainEmitter.emissionRate;
        for (i in 0...120) {  // 4 seconds warm-up
            rainEmitter.emissionRate = originalRate * (i / 120.0);
            rainEmitter.update(1.0/30.0);
            particleSystem.update(1.0/30.0);
        }
        rainEmitter.emissionRate = originalRate;
    }
    
    public function stop() {
        if (!isActive) return;
        
        isActive = false;
        rainEmitter.isEmitting = false;
        
        // Clear existing rain particles
        var rainPool = particleSystem.getPool("rain");
        if (rainPool != null) {
            rainPool.clear();
        }
    }
    
    public function toggle() {
        if (isActive) stop() else start();
    }
    
    public function update(dt:Float) {
        // Always update position for when rain restarts
        rainEmitter.x = camera.x - gameWidth * 0.5;  // Offset left from camera center
        rainEmitter.y = camera.y - 300;  // Well above camera view
        
        if (!isActive) return;
        
        // Vary rain intensity over time
        intensityTimer += dt;
        
        // Use multiple sine waves for complex patterns
        var intensity1 = Math.sin(intensityTimer * 0.3) * 0.3;
        var intensity2 = Math.sin(intensityTimer * 1.7) * 0.2;
        var intensity3 = Math.sin(intensityTimer * 4.1) * 0.1;
        
        var intensity = 0.6 + intensity1 + intensity2 + intensity3 + Math.random() * 0.1;
        intensity = Math.max(0.3, Math.min(1.0, intensity));
        
        rainEmitter.emissionRate = baseEmissionRate * intensity;
        
        // Vary speed with intensity
        rainEmitter.speedMin = 350 * (0.8 + intensity * 0.2);
        rainEmitter.speedMax = 550 * (0.8 + intensity * 0.2);
    }
    
    public function dispose() {
        if (rainEmitter != null) {
            particleSystem.removeEmitter(rainEmitter);
            rainEmitter = null;
        }
    }
}