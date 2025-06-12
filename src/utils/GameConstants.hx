package utils;

/**
 * Centralized game constants to eliminate magic numbers
 * Organized by system for easy maintenance and understanding
 * 
 * All gameplay values should be defined here rather than hardcoded
 * This allows for easy tweaking and balancing without searching through code
 */
class GameConstants {
    // === Game Configuration ===
    /** Base game resolution width - designed for pixel art */
    public static inline var GAME_WIDTH:Int = 320;
    
    /** Base game resolution height - 4:3 aspect ratio */
    public static inline var GAME_HEIGHT:Int = 240;
    
    /** Fixed timestep for consistent physics (60 FPS) */
    public static inline var FIXED_TIMESTEP:Float = 1.0/60.0;
    
    /** Maximum frames to skip if running slow */
    public static inline var MAX_FRAMESKIP:Int = 5;
    
    // === Player Constants ===
    /** Normal movement speed in pixels per second */
    public static inline var PLAYER_MOVE_SPEED:Float = 120.0;
    
    /** Dash speed in pixels per second - roughly 4x normal speed */
    public static inline var PLAYER_DASH_SPEED:Float = 500.0;
    
    /** How long the dash lasts in seconds */
    public static inline var PLAYER_DASH_DURATION:Float = 0.15;
    
    /** Cooldown between dashes in seconds */
    public static inline var PLAYER_DASH_COOLDOWN:Float = 0.5;
    
    /** Duration of invincibility after dashing in seconds */
    public static inline var PLAYER_INVINCIBILITY_DURATION:Float = 0.5;
    
    /** How often the player flashes when invincible (times per second) */
    public static inline var PLAYER_INVINCIBILITY_FLASH_FREQUENCY:Float = 10.0;
    
    /** Interval between ghost spawns during dash (seconds) */
    public static inline var PLAYER_DASH_GHOST_INTERVAL:Float = 0.02;
    
    /** Player collision radius in pixels */
    public static inline var PLAYER_RADIUS:Float = 8.0;
    
    /** Player starting health */
    public static inline var PLAYER_HEALTH:Float = 100.0;
    
    /** Player maximum health */
    public static inline var PLAYER_MAX_HEALTH:Float = 100.0;
    
    // === Entity Constants ===
    /** Default collision radius for entities */
    public static inline var ENTITY_DEFAULT_RADIUS:Float = 8.0;
    
    /** Movement friction applied each frame (0-1, lower = more slippery) */
    public static inline var ENTITY_FRICTION:Float = 0.82;
    
    /** Grid size for entity positioning (matches tile size) */
    public static inline var ENTITY_GRID_SIZE:Int = 16;
    
    // === Camera Constants ===
    /** How fast camera follows target (0-1, higher = tighter follow) */
    public static inline var CAMERA_FOLLOW_SPEED:Float = 0.1;
    
    /** Minimum distance before camera starts following */
    public static inline var CAMERA_DEAD_ZONE:Float = 20.0;
    
    /** Free camera movement speed in debug mode (pixels/second) */
    public static inline var CAMERA_DEBUG_SPEED:Float = 200.0;
    
    /** Default camera shake duration in seconds */
    public static inline var CAMERA_SHAKE_DURATION:Float = 0.5;
    
    /** Camera shake intensity (max offset in pixels) */
    public static inline var CAMERA_SHAKE_INTENSITY:Float = 10.0;
    
    // === Particle Constants ===
    /** Base rain emission rate (particles per second) */
    public static inline var RAIN_BASE_EMISSION_RATE:Float = 600.0;
    
    /** Rain particle minimum speed (pixels/second) */
    public static inline var RAIN_SPEED_MIN:Float = 350.0;
    
    /** Rain particle maximum speed (pixels/second) */
    public static inline var RAIN_SPEED_MAX:Float = 550.0;
    
    /** Rain angle in radians (135 degrees for diagonal rain) */
    public static inline var RAIN_ANGLE:Float = 2.356194490192345; // Math.PI * 0.75
    
    /** Rain angle variation in radians */
    public static inline var RAIN_ANGLE_VARIATION:Float = 0.1;
    
    /** How long rain particles live (seconds) */
    public static inline var RAIN_LIFE_MIN:Float = 2.5;
    public static inline var RAIN_LIFE_MAX:Float = 3.0;
    
    /** Rain gravity effect (pixels/second²) */
    public static inline var RAIN_GRAVITY:Float = 50.0;
    
    /** Default particle pool size */
    public static inline var PARTICLE_POOL_SIZE:Int = 100;
    
    /** Rain particle pool size (more particles needed) */
    public static inline var RAIN_POOL_SIZE:Int = 2000;
    
    // === Collision Constants ===
    /** Corner sliding threshold (0-1, percentage of radius) */
    public static inline var COLLISION_CORNER_THRESHOLD:Float = 0.3;
    
    /** Collision spatial grid cell size (pixels) */
    public static inline var COLLISION_GRID_SIZE:Int = 32;
    
    // === Tilemap Constants ===
    /** Size of each tile in pixels */
    public static inline var TILE_SIZE:Int = 16;
    
    // === Debug Constants ===
    /** Backtick key code for debug toggle */
    public static inline var DEBUG_KEY_TOGGLE:Int = 192;
    
    /** Debug text default pixel scale */
    public static inline var DEBUG_TEXT_SCALE:Int = 1;
    
    /** Debug collision circle line width */
    public static inline var DEBUG_COLLISION_LINE_WIDTH:Float = 2.0;
    
    /** Debug movement vector display scale */
    public static inline var DEBUG_VECTOR_SCALE:Float = 50.0;
    
    // === UI Constants ===
    /** Default menu item spacing in pixels */
    public static inline var MENU_ITEM_SPACING:Float = 30.0;
    
    /** Menu transition duration in seconds */
    public static inline var MENU_TRANSITION_DURATION:Float = 0.3;
    
    // === Animation Constants ===
    /** Default animation frame rate */
    public static inline var DEFAULT_ANIMATION_FPS:Int = 10;
    
    /** Player idle animation speed */
    public static inline var PLAYER_ANIM_IDLE_FPS:Int = 4;
    
    /** Player run animation speed */
    public static inline var PLAYER_ANIM_RUN_FPS:Int = 10;
    
    // === Combat Constants ===
    /** Base sword damage */
    public static inline var SWORD_BASE_DAMAGE:Float = 10.0;
    
    /** Sword swing duration in seconds */
    public static inline var SWORD_SWING_DURATION:Float = 0.2;
    
    /** Combo window - time allowed between attacks to continue combo */
    public static inline var COMBO_WINDOW:Float = 0.5;
    
    /** Maximum combo count */
    public static inline var MAX_COMBO_COUNT:Int = 3;
    
    /** Combo damage multipliers */
    public static inline var COMBO_MULTIPLIER_1:Float = 1.0;
    public static inline var COMBO_MULTIPLIER_2:Float = 1.25;
    public static inline var COMBO_MULTIPLIER_3:Float = 1.5;
    
    /** Attack cooldown after combo finishes */
    public static inline var ATTACK_COOLDOWN:Float = 0.3;
    
    /** Sword hitbox size (width x height) */
    public static inline var SWORD_HITBOX_WIDTH:Float = 32.0;
    public static inline var SWORD_HITBOX_HEIGHT:Float = 24.0;
    
    /** Sword hitbox offset from player center */
    public static inline var SWORD_HITBOX_OFFSET:Float = 20.0;
    
    /** Hit pause duration when landing a hit */
    public static inline var HIT_PAUSE_DURATION:Float = 0.05;
    
    /** Knockback force applied to enemies */
    public static inline var KNOCKBACK_FORCE:Float = 200.0;
    
    // === Enemy Constants ===
    /** Basic enemy health */
    public static inline var ENEMY_HEALTH:Float = 30.0;
    
    /** Basic enemy movement speed */
    public static inline var ENEMY_MOVE_SPEED:Float = 60.0;
    
    /** Enemy patrol speed (slower than chase) */
    public static inline var ENEMY_PATROL_SPEED:Float = 40.0;
    
    /** Enemy chase speed (faster than patrol) */
    public static inline var ENEMY_CHASE_SPEED:Float = 80.0;
    
    /** Enemy sight range for detecting player */
    public static inline var ENEMY_SIGHT_RANGE:Float = 120.0;
    
    /** Enemy attack range */
    public static inline var ENEMY_ATTACK_RANGE:Float = 30.0;
    
    /** Enemy attack damage */
    public static inline var ENEMY_ATTACK_DAMAGE:Float = 5.0;
    
    /** Enemy attack cooldown */
    public static inline var ENEMY_ATTACK_COOLDOWN:Float = 1.0;
    
    /** Enemy collision radius */
    public static inline var ENEMY_RADIUS:Float = 10.0;
    
    /** Enemy knockback recovery time */
    public static inline var ENEMY_KNOCKBACK_RECOVERY:Float = 0.3;
    
    /** Enemy patrol waypoint wait time */
    public static inline var ENEMY_PATROL_WAIT_TIME:Float = 2.0;
    
    /** Enemy hurt flash duration */
    public static inline var ENEMY_HURT_FLASH_DURATION:Float = 0.2;
}