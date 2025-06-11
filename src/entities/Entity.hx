package entities;

import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Anim;
import h2d.col.Circle;
import h2d.col.Bounds;
import utils.GameConstants;
import components.IUpdatable;
import components.IMovable;
import components.ICollidable;

/**
 * Base entity class for all game objects
 * 
 * Provides core functionality for position, movement, collision, and rendering.
 * All game entities (player, enemies, projectiles, etc.) should extend this class.
 * 
 * Features:
 * - Position and velocity management
 * - Basic collision detection with circle colliders
 * - Sprite/animation rendering
 * - Grid-based positioning helpers
 * 
 * Subclasses should override:
 * - update() for custom behavior
 * - dispose() for cleanup
 * 
 * @see Player for a complex entity example
 * @see IMovable for movement interface
 * @see ICollidable for collision interface
 */
class Entity extends Object implements IUpdatable implements IMovable implements ICollidable {
    // === IMovable Implementation ===
    // Note: x and y are inherited from h2d.Object, so we'll use those
    /** X velocity in pixels per second */
    public var dx(get, set):Float;
    /** Y velocity in pixels per second */
    public var dy(get, set):Float;
    
    // Internal velocity storage
    var _dx:Float = 0;
    var _dy:Float = 0;
    
    // Legacy position properties for compatibility
    public var px(get, set):Float;  // Pixel X position
    public var py(get, set):Float;  // Pixel Y position
    
    /** Friction applied to X movement (0-1) */
    public var frictionX:Float = GameConstants.ENTITY_FRICTION;
    /** Friction applied to Y movement (0-1) */
    public var frictionY:Float = GameConstants.ENTITY_FRICTION;
    
    public var sprite:Bitmap;
    public var anim:Anim;
    
    // === ICollidable Implementation ===
    /** Circle collision shape */
    public var collisionCircle(get, never):Circle;
    /** Bounds collision shape (not used in base Entity) */
    public var collisionBounds(get, never):Bounds;
    /** Collision group this entity belongs to */
    public var collisionGroup(get, set):Int;
    /** What this entity collides with */
    public var collisionMask(get, set):Int;
    /** Whether this entity blocks movement */
    public var isSolid(get, set):Bool;
    
    // Internal collision storage
    var collider:Circle;
    var _collisionGroup:Int = 0;
    var _collisionMask:Int = 0;
    var _isSolid:Bool = true;
    
    /** Collision radius in pixels */
    public var radius:Float = GameConstants.ENTITY_DEFAULT_RADIUS;
    
    public var isAlive:Bool = true;
    
    public function new(parent:Object) {
        super(parent);
    }
    
    public function setColliderRadius(r:Float) {
        radius = r;
        if (collider != null) {
            collider.ray = r;
        } else {
            collider = new Circle(px, py, r);
        }
    }
    
    // === IMovable Methods ===
    
    /**
     * Move the entity by the given amount
     * Base implementation doesn't check collision - override in subclasses
     */
    public function moveBy(dx:Float, dy:Float):{x:Float, y:Float} {
        x += dx;
        y += dy;
        updatePosition();
        return {x: dx, y: dy};
    }
    
    /**
     * Set position directly without collision checks
     */
    public function setPos(nx:Float, ny:Float):Void {
        x = nx;
        y = ny;
        updatePosition();
    }
    
    /**
     * Apply friction to current velocity
     */
    public function applyFriction(friction:Float):Void {
        _dx *= friction;
        _dy *= friction;
    }
    
    // === ICollidable Methods ===
    
    /**
     * Called when this entity overlaps with another
     * Override in subclasses for specific behavior
     */
    public function onCollision(other:ICollidable):Void {
        // Override in subclasses
    }
    
    /**
     * Update collision shape position
     */
    public function updateCollisionPosition(nx:Float, ny:Float):Void {
        if (collider != null) {
            collider.x = nx;
            collider.y = ny;
        }
    }
    
    /**
     * Check if this entity can collide with another
     */
    public function canCollideWith(other:ICollidable):Bool {
        return (other.collisionGroup & collisionMask) != 0;
    }
    
    // === Legacy Methods (for compatibility) ===
    
    public function setPosPixel(nx:Float, ny:Float) {
        setPos(nx, ny);
    }
    
    public function setPosGrid(gx:Int, gy:Int) {
        x = (gx + 0.5) * GameConstants.ENTITY_GRID_SIZE;  // Center in tile
        y = (gy + 0.5) * GameConstants.ENTITY_GRID_SIZE;
        updatePosition();
    }
    
    /**
     * Update visual and collision positions
     * Called whenever entity position changes
     */
    function updatePosition() {
        // Update collision position
        updateCollisionPosition(x, y);
    }
    
    /**
     * Update entity for one frame
     * Override in subclasses for custom behavior
     * 
     * @param dt Delta time in seconds
     */
    public function update(dt:Float) {
        // Apply movement (collision handled by subclasses)
        x += _dx;
        y += _dy;
        
        // Apply friction
        _dx *= Math.pow(frictionX, dt * 60);
        _dy *= Math.pow(frictionY, dt * 60);
        
        // Clamp small velocities to zero
        if (Math.abs(_dx) < 0.001) _dx = 0;
        if (Math.abs(_dy) < 0.001) _dy = 0;
        
        updatePosition();
    }
    
    /**
     * Clean up entity resources
     * Override in subclasses to clean up additional resources
     */
    public function dispose() {
        remove();
    }
    
    // === Property Getters/Setters ===
    
    // IMovable properties (velocity only, position uses h2d.Object's x,y)
    function get_dx():Float return _dx;
    function set_dx(v:Float):Float return _dx = v;
    
    function get_dy():Float return _dy;
    function set_dy(v:Float):Float return _dy = v;
    
    // Legacy properties
    function get_px():Float return x;
    function set_px(v:Float):Float {
        x = v;
        updatePosition();
        return x;
    }
    
    function get_py():Float return y;
    function set_py(v:Float):Float {
        y = v;
        updatePosition();
        return y;
    }
    
    // ICollidable properties
    function get_collisionCircle():Circle return collider;
    function get_collisionBounds():Bounds return null;  // Not used in base entity
    
    function get_collisionGroup():Int return _collisionGroup;
    function set_collisionGroup(v:Int):Int return _collisionGroup = v;
    
    function get_collisionMask():Int return _collisionMask;
    function set_collisionMask(v:Int):Int return _collisionMask = v;
    
    function get_isSolid():Bool return _isSolid;
    function set_isSolid(v:Bool):Bool return _isSolid = v;
}