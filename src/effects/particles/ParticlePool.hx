package effects.particles;

import h2d.Tile;
import h2d.Object;

/**
 * Object pool for particles to avoid allocation during gameplay
 */
class ParticlePool {
    var particles:Array<Particle>;
    var container:Object;
    var particleTile:Tile;
    var poolSize:Int;
    var activeCount:Int = 0;
    
    public function new(parent:Object, tile:Tile, initialSize:Int = 100) {
        container = parent;
        particleTile = tile;
        poolSize = initialSize;
        particles = [];
        
        // Pre-allocate particles
        for (i in 0...poolSize) {
            var particle = new Particle(tile.clone(), container);
            particles.push(particle);
        }
    }
    
    public function spawn(x:Float, y:Float, velX:Float, velY:Float):Particle {
        // Find dead particle
        for (p in particles) {
            if (p.isDead) {
                p.spawn(x, y, velX, velY);
                activeCount++;
                return p;
            }
        }
        
        // Pool exhausted, create new particle
        var particle = new Particle(particleTile.clone(), container);
        particle.spawn(x, y, velX, velY);
        particles.push(particle);
        poolSize++;
        activeCount++;
        
        trace('Particle pool expanded to $poolSize particles');
        return particle;
    }
    
    public function update(dt:Float) {
        activeCount = 0;
        for (p in particles) {
            if (!p.isDead) {
                p.update(dt);
                if (!p.isDead) activeCount++;
            }
        }
    }
    
    public function clear() {
        for (p in particles) {
            p.kill();
        }
        activeCount = 0;
    }
    
    public function getActiveCount():Int {
        return activeCount;
    }
    
    public function getPoolSize():Int {
        return poolSize;
    }
}