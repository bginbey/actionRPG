package systems.effects.particles;

import h2d.Object;
import h2d.Tile;

enum EmitterShape {
    Point;
    Circle(radius:Float);
    Rectangle(width:Float, height:Float);
    Line(length:Float, angle:Float);
}

/**
 * Particle emitter that spawns particles with configurable patterns
 */
class ParticleEmitter {
    // Position
    public var x:Float = 0;
    public var y:Float = 0;
    
    // Emission properties
    public var emissionRate:Float = 10;  // Particles per second
    public var burstCount:Int = 0;  // For burst emissions
    public var isEmitting:Bool = true;
    public var shape:EmitterShape = Point;
    
    // Particle properties (ranges)
    public var speedMin:Float = 50;
    public var speedMax:Float = 100;
    public var angleMin:Float = 0;  // In radians
    public var angleMax:Float = Math.PI * 2;
    public var lifeMin:Float = 0.5;
    public var lifeMax:Float = 1.0;
    public var sizeMin:Float = 0.5;
    public var sizeMax:Float = 1.5;
    
    // Visual properties
    public var startColor:Int = 0xFFFFFF;
    public var endColor:Int = 0xFFFFFF;
    public var startAlpha:Float = 1.0;
    public var endAlpha:Float = 0.0;
    
    // Physics
    public var gravity:Float = 0;
    public var friction:Float = 0.98;
    
    // Rotation
    public var rotationSpeedMin:Float = -Math.PI;
    public var rotationSpeedMax:Float = Math.PI;
    
    // Internal
    var pool:ParticlePool;
    var emissionAccumulator:Float = 0;
    
    public function new(pool:ParticlePool) {
        this.pool = pool;
    }
    
    public function update(dt:Float) {
        if (!isEmitting) return;
        
        // Handle continuous emission
        if (emissionRate > 0) {
            emissionAccumulator += emissionRate * dt;
            while (emissionAccumulator >= 1) {
                spawnParticle();
                emissionAccumulator -= 1;
            }
        }
    }
    
    public function burst(count:Int = -1) {
        var num = count > 0 ? count : burstCount;
        for (i in 0...num) {
            spawnParticle();
        }
    }
    
    function spawnParticle() {
        // Get spawn position based on shape
        var spawnPos = getSpawnPosition();
        
        // Random values within ranges
        var speed = randRange(speedMin, speedMax);
        var angle = randRange(angleMin, angleMax);
        var vx = Math.cos(angle) * speed;
        var vy = Math.sin(angle) * speed;
        
        // Spawn particle
        var p = pool.spawn(spawnPos.x, spawnPos.y, vx, vy);
        
        // Configure particle
        p.lifeDecay = 1.0 / randRange(lifeMin, lifeMax);
        p.gravity = gravity;
        p.friction = friction;
        
        // Visual properties
        p.startScale = randRange(sizeMin, sizeMax);
        p.endScale = p.startScale * 0.1;  // Shrink to 10% of start size
        p.startColor = startColor;
        p.endColor = endColor;
        p.startAlpha = startAlpha;
        p.endAlpha = endAlpha;
        
        // Rotation - set initial rotation to match movement angle (adjusted for sprite orientation)
        p.rotation = angle - Math.PI/2;  // Subtract 90 degrees since sprite is vertical
        p.rotationSpeed = randRange(rotationSpeedMin, rotationSpeedMax);
    }
    
    function getSpawnPosition():{x:Float, y:Float} {
        switch(shape) {
            case Point:
                return {x: x, y: y};
                
            case Circle(radius):
                var angle = Math.random() * Math.PI * 2;
                var r = Math.sqrt(Math.random()) * radius;  // sqrt for uniform distribution
                return {
                    x: x + Math.cos(angle) * r,
                    y: y + Math.sin(angle) * r
                };
                
            case Rectangle(width, height):
                return {
                    x: x + (Math.random() - 0.5) * width,
                    y: y + (Math.random() - 0.5) * height
                };
                
            case Line(length, angle):
                var t = Math.random() - 0.5;  // -0.5 to 0.5
                return {
                    x: x + Math.cos(angle) * length * t,
                    y: y + Math.sin(angle) * length * t
                };
        }
    }
    
    inline function randRange(min:Float, max:Float):Float {
        return min + Math.random() * (max - min);
    }
    
    public function start() {
        isEmitting = true;
    }
    
    public function stop() {
        isEmitting = false;
    }
}