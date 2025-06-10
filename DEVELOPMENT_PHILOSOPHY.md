# Action RPG Development Philosophy

## Core Philosophy
Build a focused, polished action RPG using Heaps.io that prioritizes game feel, visual clarity, and emergent gameplay through simple, well-executed systems.

## Guiding Principles

### 1. Code Architecture (Heaps-Specific)
- **Scene Graph Architecture**: Leverage H2D's object hierarchy for game entities
- **Component Pattern**: Use Haxe interfaces and composition for behaviors
- **Resource Management**: Use HXD.Res for all asset loading
- **Entity Structure**: Extend `h2d.Object` for game objects, use `h2d.Interactive` for clickable elements
- **State Management**: Implement game states as separate scenes or scene layers
- **Reuse First**: Always prefer extending/reusing existing code over creating new solutions. Check for existing systems, utilities, or patterns before implementing new ones.

### 2. Code Hygiene (Haxe/Heaps Conventions)
- **Naming Convention**: 
  - Classes: PascalCase (PlayerController, HealthSystem)
  - Methods: camelCase (takeDamage, onPlayerDeath) - Haxe convention
  - Variables: camelCase (currentHealth, movementSpeed)
  - Constants: UPPER_SNAKE_CASE (MAX_HEALTH, DEFAULT_SPEED)
  - Packages: lowercase (com.game.player, com.game.combat)
- **Type Safety**: Always use explicit types, leverage Haxe's strong typing
- **Null Safety**: Use Haxe's null safety features, avoid nullable types when possible
- **Resource References**: Use `hxd.Res` for compile-time resource checking
- **DRY Principle**: Extract common functionality into utilities and base classes
- **No Magic Numbers**: All gameplay values must be configurable

### 3. Core Systems Architecture (Heaps-Focused)
```
src/
├── Main.hx              # Entry point, app initialization
├── Game.hx              # Core game loop and state management
├── scenes/              # Game scenes (Menu, Gameplay, etc.)
│   ├── GameScene.hx
│   └── MenuScene.hx
├── entities/            # Game objects extending h2d.Object
│   ├── Player.hx
│   ├── Enemy.hx
│   └── Projectile.hx
├── systems/             # Core game systems
│   ├── CombatSystem.hx
│   ├── MovementSystem.hx
│   └── InputSystem.hx
├── components/          # Reusable behaviors/interfaces
├── ui/                  # HUD and menu components
└── utils/               # Helper classes and extensions

res/                     # Resources folder (monitored by Heaps)
├── sprites/
├── sounds/
├── data/                # JSON/CDB files
└── shaders/
```

### 4. Heaps-Specific Best Practices
- **Scene Management**: 
  ```haxe
  class GameScene extends h2d.Scene {
    var player: Player;
    var enemies: h2d.Object; // Container for all enemies
  }
  ```
- **Resource Loading**: Always use `hxd.Res.sprites.player.toTile()`
- **Update Loop**: Override `update(dt:Float)` in your App class
- **Collision Detection**: Use `h2d.col.Bounds` for 2D collision
- **Input Handling**: Use `hxd.Key` for keyboard, `s2d.addEventListener` for mouse

### 5. Version Control Workflow
- **Branch Strategy**: Git Flow
  - `main`: Production-ready builds only
  - `develop`: Integration branch
  - `feature/*`: New features (from develop)
  - `hotfix/*`: Emergency fixes (from main)
- **Commit Messages**: `[Type] Brief description`
  - Types: [Feature], [Fix], [Refactor], [Art], [Audio], [Config]
  - Example: `[Feature] Add dash ability with cooldown`
- **Pull Request Rules**:
  - Must pass all tests
  - Requires code review
  - Update relevant documentation
  - Include gameplay GIF/video for visual changes
- **Heaps-Specific Ignores**:
  ```
  .haxelib/
  bin/
  obj/
  *.hl
  res/.tmp/
  ```

### 6. Asset Pipeline (Heaps-Optimized)
- **Automatic Atlas Generation**: Place sprites in `res/sprites/` for auto-atlasing
- **Sound Format**: OGG for music, WAV for short SFX
- **Tile Properties**: Use power-of-2 dimensions for better GPU performance
- **CastleDB Integration**: Use `.cdb` files for data-driven design
- **Shader Files**: Store HXSL shaders in `res/shaders/`
- **Consistent Naming**: `Type_Name_Variant_State`
  - Example: `Sprite_Player_Dash_01`, `Audio_Sword_Hit_Metal`

### 7. Build Configuration
```hxml
# build.hxml
-lib heaps
-lib hlsdl
-cp src
-main Main
-hl bin/game.hl

# For web build
-lib heaps
-cp src
-main Main
-js bin/game.js
-dce full
```

### 8. Performance Guidelines
- **Object Pooling**: Reuse frequently created objects (projectiles, particles)
- **Batch Rendering**: Use `h2d.SpriteBatch` for many similar objects
- **Texture Atlases**: Let Heaps auto-generate atlases from res folder
- **Update Optimization**: Use `dt` (delta time) for all movement/timers

### 9. Debugging Tools
- **Heaps Inspector**: Press F1 in debug builds
- **Custom Debug Display**: 
  ```haxe
  #if debug
  var debugText = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
  #end
  ```
- **Performance Monitoring**: Use `hxd.Timer.fps()` for FPS display

### 10. Common Patterns

**Entity Creation Pattern**:
```haxe
class Player extends h2d.Object {
    var sprite: h2d.Anim;
    var speed: Float = 100;
    
    public function new(?parent) {
        super(parent);
        sprite = new h2d.Anim(getAnimFrames(), 15, this);
    }
    
    public function update(dt: Float) {
        // Update logic
    }
}
```

**System Pattern**:
```haxe
class CombatSystem {
    public static function dealDamage(target: IHealth, damage: Float) {
        // Damage calculation
    }
}
```

### 11. Testing Approach
- **Unit Tests**: Use `utest` or `munit` for Haxe
- **Hot Reload**: Use HashLink's hot reload during development
- **Debug Shortcuts**: Implement debug keys for common actions
- **Playtest Early**: Vertical slice by first milestone
- **Automated Tests**: For core systems (combat math, save/load)

### 12. Designer Experience
- **Hot Reload**: Support runtime tweaking of values
- **Visual Debugging**: Gizmos for hitboxes, ranges, triggers
- **Prefab Variants**: Base prefabs with easy customization
- **Clear Feedback**: Every action has visual/audio response

### 13. Communication
- **Daily Standup Format**: What I did, what I'll do, blockers
- **Documentation Location**: `/Docs` folder in repo
- **Decision Log**: Record major technical/design decisions with rationale

### 14. Documentation Numbering System
- **Task/Todo Files**: Use format `YYYY-MM-DD-NN-description.md`
  - YYYY: Year (e.g., 2024)
  - MM: Month (01-12)
  - DD: Day (01-31)
  - NN: Sequential number for that day (01, 02, etc.)
  - Example: `2024-01-15-01-implement-player-movement.md`
- **Benefits**:
  - Natural chronological ordering in file explorers
  - Easy to find when tasks were created
  - Multiple tasks per day supported
  - No naming conflicts

## Definition of Done
A feature is complete when:
1. Code is reviewed and merged
2. Has appropriate tests/debug tools
3. Values are designer-configurable
4. Performance impact measured
5. Documentation updated
6. No new warnings/errors

## Red Flags to Avoid
- Hardcoded gameplay values
- Systems with multiple responsibilities
- Uncommitted work > 1 day
- "Temporary" solutions without TODO comments
- Features without designer-facing controls
- Copy-pasted code blocks > 10 lines
- Creating new solutions when existing code can be extended
- Using `new` in update loops without pooling
- Loading resources outside of `hxd.Res`
- Manual sprite sheet management (use auto-atlas)
- Forgetting to multiply by `dt` in update methods
- Not disposing of resources when changing scenes
- Using Flash API instead of Heaps API

## Quick Reference Commands
```bash
# Setup project
haxelib install heaps
haxelib install hlsdl

# Development build (HashLink)
haxe build.hxml
hl bin/game.hl

# Web build
haxe build-web.hxml

# Watch mode (with custom script)
haxe --wait 6000
```

---
*This document is law. Amendments require team consensus.*