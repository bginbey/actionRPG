# Architecture Refactoring Plan

**Date**: 2025-06-11  
**Purpose**: Align codebase with Development Philosophy and improve maintainability

## Overview

This document outlines a comprehensive refactoring plan to bring the Action RPG codebase in line with the established Development Philosophy. The refactor focuses on creating a clean, maintainable architecture while preserving the current working build throughout the process.

## Current State Analysis

### Architecture Violations
- Missing `Game.hx` file (core game loop mixed into Main.hx)
- `effects/` folder at root level instead of proper system organization
- Empty `components/` folder despite philosophy emphasis on component pattern
- No component interfaces defined

### Code Quality Issues
- Magic numbers throughout the codebase
- Large classes with multiple responsibilities (GameScene: 370+ lines)
- Repeated code patterns without abstraction
- Limited code documentation

### Missing Systems
- No health/damage system despite combat being planned
- No proper state machine for entity states
- No centralized animation system
- No resource manager using hxd.Res

## Refactoring Plan

### Phase 1: Core Architecture (Maintain Working Build)

#### 1.1 Create GameConstants.hx
Create a centralized constants file to eliminate magic numbers:

```haxe
package utils;

/**
 * Centralized game constants to eliminate magic numbers
 * Organized by system for easy maintenance
 */
class GameConstants {
    // Game Configuration
    public static inline var GAME_WIDTH:Int = 320;
    public static inline var GAME_HEIGHT:Int = 240;
    public static inline var FIXED_TIMESTEP:Float = 1.0/60.0;
    public static inline var MAX_FRAMESKIP:Int = 5;
    
    // Player Constants
    public static inline var PLAYER_MOVE_SPEED:Float = 120.0;
    public static inline var PLAYER_DASH_SPEED:Float = 500.0;
    public static inline var PLAYER_DASH_DURATION:Float = 0.15;
    public static inline var PLAYER_DASH_COOLDOWN:Float = 0.5;
    // ... etc
}
```

#### 1.2 Create Component Interfaces
Establish a component-based architecture:

- `components/IUpdatable.hx` - For entities requiring updates
- `components/IHealth.hx` - For damageable entities
- `components/IMovable.hx` - For moving entities
- `components/ICollidable.hx` - For collision-enabled entities
- `components/IAnimated.hx` - For animated entities

Each interface will include comprehensive documentation:

```haxe
package components;

/**
 * Interface for entities that can take damage and have health
 * Used by players, enemies, and destructible objects
 */
interface IHealth {
    /**
     * Current health value
     */
    var health(get, set):Float;
    
    /**
     * Maximum health value
     */
    var maxHealth(get, set):Float;
    
    /**
     * Apply damage to this entity
     * @param amount Amount of damage to apply
     * @param source Optional source of the damage for tracking
     * @return Actual damage dealt after resistances/modifiers
     */
    function takeDamage(amount:Float, ?source:Entity):Float;
    
    /**
     * Heal this entity
     * @param amount Amount of healing to apply
     * @return Actual amount healed (capped at maxHealth)
     */
    function heal(amount:Float):Float;
    
    /**
     * Check if entity is dead (health <= 0)
     */
    function isDead():Bool;
    
    /**
     * Called when health reaches zero
     */
    function onDeath():Void;
}
```

#### 1.3 Extract Game.hx from Main.hx
Separate concerns between app initialization and game logic:

- Main.hx: App initialization, window setup, basic configuration
- Game.hx: Game loop, scene management, game state

### Phase 2: Reorganize Effects System

#### 2.1 Restructure Effects
- Move particle system to `systems/effects/particles/`
- Create `entities/effects/` for game-specific effects
- Move RainEffect and DashDustEffect to entities/effects/

#### 2.2 Create Base Pool Class
Generic object pooling system:

```haxe
package utils;

/**
 * Generic object pool for performance optimization
 * Reuses objects instead of creating/destroying them
 * @param T Type of object to pool
 */
class ObjectPool<T> {
    private var available:Array<T>;
    private var active:Array<T>;
    private var createFn:Void->T;
    private var resetFn:T->Void;
    
    /**
     * Create a new object pool
     * @param create Function to create new instances
     * @param reset Function to reset instances for reuse
     * @param initialSize Number of objects to pre-allocate
     */
    public function new(create:Void->T, reset:T->Void, initialSize:Int = 10) {
        // Implementation
    }
}
```

### Phase 3: Split Large Classes

#### 3.1 Refactor GameScene.hx
Extract into focused systems:

- `systems/DebugRenderer.hx` - All debug visualization
- `systems/LevelLoader.hx` - Level loading and generation
- `ui/GameHUD.hx` - UI management and updates

GameScene will coordinate these systems:

```haxe
/**
 * Main gameplay scene
 * Coordinates all game systems and manages gameplay flow
 * 
 * Systems:
 * - DebugRenderer: Visual debugging (F1 to toggle)
 * - LevelLoader: Handles level data and tilemap generation
 * - GameHUD: Player UI and information display
 * - ParticleSystem: Visual effects management
 * 
 * @see DebugRenderer for debug commands
 * @see LevelLoader for level format
 */
class GameScene extends Scene {
    // Focused coordination code
}
```

#### 3.2 Refactor Player.hx
Extract components:

- `components/DashComponent.hx` - Dash mechanics
- `components/InvincibilityComponent.hx` - Invincibility frames
- `components/AnimationController.hx` - Animation state management

### Phase 4: Create Reusable Systems

#### 4.1 Timer/Cooldown System
```haxe
package utils;

/**
 * Reusable timer for countdowns and delays
 * 
 * Usage:
 * var timer = new Timer(1.0); // 1 second timer
 * timer.onComplete = () -> trace("Timer finished!");
 * 
 * // In update loop
 * timer.update(dt);
 */
class Timer {
    public var duration:Float;
    public var elapsed:Float = 0;
    public var onComplete:Void->Void;
    public var isComplete(get, never):Bool;
    
    // Implementation with full documentation
}
```

#### 4.2 State Machine
Generic state machine for entity states, game states, etc.

#### 4.3 Animation System
Centralized animation management removing logic from individual entities.

### Phase 5: Resource Management

#### 5.1 Implement Proper Resource Loading
- Configure hxd.Res for compile-time resource checking
- Remove all hardcoded paths
- Document resource organization

#### 5.2 Create Resource Manager
Centralized resource handling with proper disposal.

### Phase 6: Documentation Enhancement

#### 6.1 Architecture Comments
Every file will include:
- Purpose statement at the top
- Responsibility boundaries
- Cross-references to related systems
- Usage examples where appropriate

#### 6.2 Algorithm Documentation
Complex algorithms will be documented:
- Collision detection math
- Corner sliding calculations
- Animation timing logic

#### 6.3 Game Logic Documentation
- Physics constants and their gameplay effects
- Coordinate system explanations
- State transition documentation

## Execution Order

### Step 1: Foundation
1. Create GameConstants.hx and migrate all magic numbers
2. Create component interfaces with documentation
3. Update Entity.hx to implement appropriate interfaces
4. Test build integrity

### Step 2: Core Architecture
1. Create Game.hx and extract game logic
2. Update Main.hx to delegate appropriately
3. Create base ObjectPool<T> class
4. Verify all scenes function correctly

### Step 3: Effects Reorganization
1. Create new directory structure
2. Move particle system to systems/effects/
3. Move game effects to entities/effects/
4. Update all imports and test

### Step 4: Scene Refactoring
1. Extract DebugRenderer from GameScene
2. Extract LevelLoader from GameScene
3. Extract GameHUD from GameScene
4. Simplify GameScene to coordination role
5. Test all functionality

### Step 5: Player Components
1. Create component classes
2. Refactor Player to use components
3. Update collision and movement systems
4. Verify player functionality

### Step 6: Utilities and Polish
1. Implement Timer and Cooldown utilities
2. Create StateMachine implementation
3. Update all systems to use utilities
4. Final documentation pass
5. Comprehensive testing

## Risk Mitigation

- Each phase produces a working build
- Git commits after each successful phase
- Incremental changes allow easy rollback
- No "big bang" refactor
- Continuous testing throughout

## Success Metrics

- All Development Philosophy requirements met
- No magic numbers in code
- All classes under 200 lines
- Clear separation of concerns
- Comprehensive documentation
- Working build maintained throughout

## Documentation Standards

### Class Documentation
```haxe
/**
 * Brief description of class purpose
 * 
 * Responsibilities:
 * - List of what this class handles
 * 
 * Does NOT handle:
 * - List of what this class explicitly doesn't do
 * 
 * @see RelatedClass for interaction details
 */
```

### Method Documentation
```haxe
/**
 * Brief description of what method does
 * 
 * @param paramName Description and valid ranges
 * @return What is returned and when
 * 
 * Example:
 * ```
 * var result = object.method(10);
 * ```
 */
```

### Complex Algorithm Documentation
```haxe
// === Corner Sliding Algorithm ===
// When player hits corner at shallow angle:
// 1. Calculate overlap percentage
// 2. If overlap < 30% of radius, push perpendicular
// 3. This creates smooth movement around obstacles
// See: https://gamedev.stackexchange.com/...
```

## Conclusion

This refactoring plan will transform the codebase into a well-architected, maintainable system that fully complies with the Development Philosophy. The incremental approach ensures the game remains playable throughout the process while building a solid foundation for future development.