package effects;

import effects.particles.ParticleSystem;
import utils.ColorPalette;

/**
 * Dust cloud effect for dashing
 */
class DashDustEffect {
    var particleSystem:ParticleSystem;
    
    public function new(particleSystem:ParticleSystem) {
        this.particleSystem = particleSystem;
    }
    
    /**
     * Create dust burst at position
     * @param x World X position
     * @param y World Y position
     * @param direction Direction of dash in radians
     */
    public function burst(x:Float, y:Float, direction:Float) {
        var emitter = particleSystem.createEmitter("dust");
        emitter.x = x;
        emitter.y = y;
        emitter.shape = Circle(12);
        
        // Dust spreads opposite to dash direction
        var spreadAngle = direction + Math.PI;
        emitter.angleMin = spreadAngle - Math.PI/3;
        emitter.angleMax = spreadAngle + Math.PI/3;
        
        emitter.speedMin = 30;
        emitter.speedMax = 80;
        emitter.lifeMin = 0.3;
        emitter.lifeMax = 0.5;
        
        emitter.sizeMin = 1.5;
        emitter.sizeMax = 2.5;
        
        emitter.startAlpha = 0.6;
        emitter.endAlpha = 0;
        
        emitter.startColor = ColorPalette.LIGHT_GRAY;
        emitter.endColor = ColorPalette.GRAY;
        
        emitter.gravity = 50;
        emitter.friction = 0.85;
        
        emitter.burst(15);
        
        // Clean up after effect
        haxe.Timer.delay(() -> {
            particleSystem.removeEmitter(emitter);
        }, 1000);
    }
}