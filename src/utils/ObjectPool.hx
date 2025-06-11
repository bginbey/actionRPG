package utils;

/**
 * Generic object pool for performance optimization
 * 
 * Reuses objects instead of creating/destroying them, which helps:
 * - Reduce garbage collection pressure
 * - Improve performance by avoiding allocations
 * - Maintain steady frame rates during intense action
 * 
 * Design:
 * - Pre-allocates a set number of objects
 * - Provides get() to retrieve an available object
 * - Objects return themselves to the pool when done
 * - Automatically expands if pool is exhausted
 * 
 * Usage example:
 * ```haxe
 * // Define a poolable class
 * class Bullet implements IPoolable {
 *     public var isActive:Bool = false;
 *     public function reset() { isActive = false; }
 * }
 * 
 * // Create pool
 * var bulletPool = new ObjectPool<Bullet>(
 *     () -> new Bullet(),        // Create function
 *     (b) -> b.reset(),         // Reset function
 *     100                       // Initial size
 * );
 * 
 * // Use pool
 * var bullet = bulletPool.get();
 * // ... use bullet ...
 * bulletPool.release(bullet);
 * ```
 * 
 * @see GhostPool for a specific implementation
 * @see ParticlePool for another example
 */
class ObjectPool<T> {
    /** Available objects ready for use */
    var available:Array<T>;
    
    /** Objects currently in use */
    var active:Array<T>;
    
    /** Function to create new instances */
    var createFn:Void->T;
    
    /** Function to reset instances for reuse */
    var resetFn:T->Void;
    
    /** Track pool statistics */
    public var totalCreated(default, null):Int = 0;
    public var currentActive(get, never):Int;
    public var currentAvailable(get, never):Int;
    
    /**
     * Create a new object pool
     * 
     * @param create Function that creates a new instance of T
     * @param reset Function that resets an instance for reuse
     * @param initialSize Number of objects to pre-allocate (default: 10)
     */
    public function new(create:Void->T, reset:T->Void, initialSize:Int = 10) {
        this.createFn = create;
        this.resetFn = reset;
        this.available = [];
        this.active = [];
        
        // Pre-allocate initial objects
        for (i in 0...initialSize) {
            var obj = createFn();
            resetFn(obj);
            available.push(obj);
            totalCreated++;
        }
        
        trace('ObjectPool initialized with $initialSize objects');
    }
    
    /**
     * Get an object from the pool
     * Creates a new one if pool is exhausted
     * 
     * @return An available object, reset and ready for use
     */
    public function get():T {
        var obj:T;
        
        if (available.length > 0) {
            // Reuse existing object
            obj = available.pop();
        } else {
            // Pool exhausted, create new object
            obj = createFn();
            totalCreated++;
            trace('ObjectPool expanded: $totalCreated total objects');
        }
        
        active.push(obj);
        return obj;
    }
    
    /**
     * Return an object to the pool
     * 
     * @param obj The object to return
     * @return true if successfully returned, false if object wasn't from this pool
     */
    public function release(obj:T):Bool {
        var idx = active.indexOf(obj);
        if (idx == -1) {
            trace('Warning: Attempted to release object not from this pool');
            return false;
        }
        
        // Remove from active
        active.splice(idx, 1);
        
        // Reset and return to available
        resetFn(obj);
        available.push(obj);
        
        return true;
    }
    
    /**
     * Release all active objects back to the pool
     * Useful for scene transitions or cleanup
     */
    public function releaseAll():Void {
        while (active.length > 0) {
            var obj = active.pop();
            resetFn(obj);
            available.push(obj);
        }
    }
    
    /**
     * Pre-warm the pool by creating additional objects
     * Useful before intense sequences to avoid creation during gameplay
     * 
     * @param count Number of additional objects to create
     */
    public function preWarm(count:Int):Void {
        for (i in 0...count) {
            var obj = createFn();
            resetFn(obj);
            available.push(obj);
            totalCreated++;
        }
        trace('ObjectPool pre-warmed with $count additional objects. Total: $totalCreated');
    }
    
    /**
     * Clear the pool completely
     * Note: This doesn't dispose objects, just removes references
     */
    public function clear():Void {
        available = [];
        active = [];
        trace('ObjectPool cleared');
    }
    
    /**
     * Get pool statistics for debugging
     */
    public function getStats():String {
        return 'Pool Stats - Active: ${active.length}, Available: ${available.length}, Total: $totalCreated';
    }
    
    // Property getters
    function get_currentActive():Int return active.length;
    function get_currentAvailable():Int return available.length;
}