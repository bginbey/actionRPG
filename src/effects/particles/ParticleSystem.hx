package effects.particles;

import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import utils.ColorPalette;

/**
 * Main particle system manager
 * Handles multiple emitters and particle pools
 */
class ParticleSystem extends Object {
    var pools:Map<String, ParticlePool>;
    var emitters:Array<ParticleEmitter>;
    var defaultTile:Tile;
    
    // Debug info
    public var totalActiveParticles:Int = 0;
    
    public function new(parent:Object) {
        super(parent);
        
        pools = new Map();
        emitters = [];
        
        // Create default particle tile (4x4 white square)
        var bmp = new hxd.BitmapData(4, 4);
        bmp.clear(0xFFFFFFFF);  // Fill with white
        var texture = h3d.mat.Texture.fromBitmap(bmp);
        defaultTile = h2d.Tile.fromTexture(texture);
        defaultTile.dx = -2;  // Center the tile
        defaultTile.dy = -2;
    }
    
    /**
     * Create or get a particle pool
     */
    public function getPool(name:String, ?customTile:Tile, poolSize:Int = 100):ParticlePool {
        if (!pools.exists(name)) {
            var tile = customTile != null ? customTile : defaultTile;
            pools[name] = new ParticlePool(this, tile, poolSize);
        }
        return pools[name];
    }
    
    /**
     * Create a new emitter
     */
    public function createEmitter(poolName:String = "default"):ParticleEmitter {
        var pool = getPool(poolName);
        var emitter = new ParticleEmitter(pool);
        emitters.push(emitter);
        return emitter;
    }
    
    /**
     * Quick burst effect at position
     */
    public function burst(x:Float, y:Float, count:Int = 20, ?config:Dynamic) {
        var emitter = createEmitter();
        emitter.x = x;
        emitter.y = y;
        emitter.isEmitting = false;  // One-time burst
        
        // Apply config if provided
        if (config != null) {
            if (config.speedMin != null) emitter.speedMin = config.speedMin;
            if (config.speedMax != null) emitter.speedMax = config.speedMax;
            if (config.color != null) {
                emitter.startColor = config.color;
                emitter.endColor = config.color;
            }
            if (config.gravity != null) emitter.gravity = config.gravity;
        }
        
        emitter.burst(count);
        
        // Remove emitter after a delay
        haxe.Timer.delay(() -> {
            emitters.remove(emitter);
        }, 2000);  // Clean up after 2 seconds
    }
    
    /**
     * Create a dash dust effect
     */
    public function createDashDust(x:Float, y:Float, direction:Float) {
        var emitter = createEmitter("dust");
        emitter.x = x;
        emitter.y = y;
        emitter.shape = Circle(8);
        emitter.speedMin = 20;
        emitter.speedMax = 50;
        emitter.angleMin = direction - Math.PI/4;
        emitter.angleMax = direction + Math.PI/4;
        emitter.lifeMin = 0.3;
        emitter.lifeMax = 0.5;
        emitter.startColor = ColorPalette.GRAY;
        emitter.endColor = ColorPalette.DARK_GRAY;
        emitter.gravity = 100;
        emitter.friction = 0.9;
        emitter.burst(10);
        
        // Clean up
        haxe.Timer.delay(() -> {
            emitters.remove(emitter);
        }, 1000);
    }
    
    /**
     * Create an impact effect
     */
    public function createImpact(x:Float, y:Float, color:Int = 0xFFFFFF) {
        var emitter = createEmitter();
        emitter.x = x;
        emitter.y = y;
        emitter.speedMin = 100;
        emitter.speedMax = 200;
        emitter.lifeMin = 0.2;
        emitter.lifeMax = 0.4;
        emitter.sizeMin = 0.5;
        emitter.sizeMax = 1.0;
        emitter.startColor = color;
        emitter.endColor = color;
        emitter.gravity = 300;
        emitter.burst(15);
        
        // Clean up
        haxe.Timer.delay(() -> {
            emitters.remove(emitter);
        }, 1000);
    }
    
    /**
     * Update all particle systems
     */
    public function update(dt:Float) {
        // Update all emitters
        for (emitter in emitters) {
            emitter.update(dt);
        }
        
        // Update all pools
        totalActiveParticles = 0;
        for (pool in pools) {
            pool.update(dt);
            totalActiveParticles += pool.getActiveCount();
        }
    }
    
    /**
     * Clear all particles
     */
    public function clear() {
        for (pool in pools) {
            pool.clear();
        }
        emitters = [];
    }
    
    /**
     * Remove a specific emitter
     */
    public function removeEmitter(emitter:ParticleEmitter) {
        emitters.remove(emitter);
    }
}