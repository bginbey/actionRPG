# Action RPG Development Roadmap

## Overview
Progressive milestones to build a Hyper Light Drifter-inspired action RPG using Heaps.io, with 16x16 tile grid and 32x32 player sprite.

---

## Phase 1: Foundation
### Milestone 1.1: Project Setup
- [ ] Initialize Heaps.io project structure
- [ ] Configure build.hxml for HashLink and web targets
- [ ] Setup version control with proper .gitignore
- [ ] Create basic Main.hx entry point
- [ ] Implement core game loop with fixed timestep

### Milestone 1.2: Basic Scene Management
- [ ] Create SceneManager class
- [ ] Implement Scene base class
- [ ] Create SplashScene with fade in/out
- [ ] Create MenuScene with basic UI
- [ ] Add scene transition system

### Milestone 1.3: Resource Pipeline
- [ ] Setup res/ folder structure
- [ ] Add placeholder assets (splash logo, menu bg)
- [ ] Configure automatic atlas generation
- [ ] Add pixel font (8x8 or 16x16 bitmap font)
- [ ] Setup font rendering with hxd.res.Font
- [ ] Create shaders/ folder for HXSL shaders
- [ ] Test resource loading with hxd.Res

---

## Phase 2: Core Systems
### Milestone 2.1: Game Architecture
- [ ] Setup Resurrect 64 color palette system
- [ ] Create ColorPalette utility class
- [ ] Configure all UI elements to use palette colors
- [ ] Create GameScene class
- [ ] Implement entity management system
- [ ] Setup debug overlay (FPS, entity count)
- [ ] Configure debug font for readable output
- [ ] Create base Entity class extending h2d.Object

### Milestone 2.2: Tilemap System
- [ ] Create Tilemap class for 16x16 grid
- [ ] Implement tile rendering with h2d.TileGroup
- [ ] Add collision data to tiles
- [ ] Create level data format (JSON/CDB)
- [ ] Build test level (20x20 tiles minimum)

### Milestone 2.3: Camera System
- [ ] Implement Camera class with bounds
- [ ] Add smooth follow behavior
- [ ] Create camera shake system
- [ ] Add debug camera controls
- [ ] Implement screen boundaries

### Milestone 2.4: Foundation Systems
- [ ] Create basic particle system manager
- [ ] Implement object pooling for particles
- [ ] Setup shader system with hot reload
- [ ] Create simple color/tint shader for testing

---

## Phase 3: Player Implementation
### Milestone 3.1: Player Foundation
- [ ] Create Player class (32x32 sprite)
- [ ] Implement basic sprite rendering
- [ ] Add input handling system
- [ ] Create player state machine

### Milestone 3.2: Core Movement
- [ ] Implement 8-directional movement
- [ ] Add acceleration/deceleration
- [ ] Create collision detection with tilemap
- [ ] Add collision response (sliding)
- [ ] Tune movement feel (speed: ~150-200 px/s)

### Milestone 3.3: Dash Mechanic
- [ ] Implement dash ability (HLD signature move)
- [ ] Add dash cooldown system
- [ ] Create dash ghost/trail effect using shaders
- [ ] Add dash particle effects (dust clouds)
- [ ] Add dash invincibility frames
- [ ] Implement chain dashing

---

## Phase 4: Combat System
### Milestone 4.1: Melee Combat
- [ ] Create sword swing animation
- [ ] Implement hitbox system
- [ ] Add combo system (3-hit chain)
- [ ] Create hit pause/screen freeze
- [ ] Add directional attacks
- [ ] Add sword trail shader effect

### Milestone 4.2: Health & Damage
- [ ] Implement health component
- [ ] Create damage/knockback system
- [ ] Add temporary invincibility
- [ ] Create health UI display
- [ ] Implement death/respawn
- [ ] Add damage flash shader

### Milestone 4.3: Visual Feedback
- [ ] Add hit particles (sparks, blood)
- [ ] Implement screen shake on hit
- [ ] Create damage numbers with game font
- [ ] Add combat sound effects
- [ ] Implement hit flash effect
- [ ] Create impact shockwave shader

---

## Phase 5: Enemy AI
### Milestone 5.1: Basic Enemy
- [ ] Create Enemy base class
- [ ] Implement simple patrol AI
- [ ] Add line-of-sight detection
- [ ] Create chase behavior
- [ ] Add collision avoidance

### Milestone 5.2: Combat AI
- [ ] Implement attack patterns
- [ ] Add telegraphed attacks with shader highlights
- [ ] Create enemy health system
- [ ] Add death animations/particles
- [ ] Implement loot drops
- [ ] Create enemy dissolve death shader

### Milestone 5.3: Enemy Variety
- [ ] Create ranged enemy type
- [ ] Add projectile system with particle trails
- [ ] Implement different movement patterns
- [ ] Balance enemy stats
- [ ] Add spawn system with spawn particles

---

## Phase 6: Polish & Game Feel
### Milestone 6.1: Advanced Particles
- [ ] Create fire/smoke particle effects
- [ ] Add environmental particles (dust, leaves)
- [ ] Implement GPU particles for performance
- [ ] Create particle editor tool
- [ ] Add weather particle systems

### Milestone 6.2: Advanced Shaders
- [ ] Implement screen-space effects (bloom, chromatic aberration)
- [ ] Create distortion shaders for heat/energy
- [ ] Add outline shaders for important objects
- [ ] Implement palette swap shaders
- [ ] Create transition shaders (pixelate, dissolve)

### Milestone 6.3: Audio
- [ ] Integrate sound manager
- [ ] Add ambient music
- [ ] Create dynamic music system
- [ ] Implement 3D positional audio
- [ ] Add audio options menu

### Milestone 6.4: UI/UX
- [ ] Create pause menu with stylized font
- [ ] Add settings screen
- [ ] Implement save/load system
- [ ] Create minimap
- [ ] Add controller support
- [ ] Polish all text rendering with consistent font usage

---

## Technical Benchmarks

### Performance Targets
- 60 FPS with 50+ enemies on screen
- < 16ms frame time
- < 100ms level load time
- < 50MB memory usage
- < 1000 active particles without frame drops

### Code Metrics
- No methods > 50 lines
- No classes > 300 lines
- Test coverage > 70% for systems
- Zero runtime errors in release

### Asset Specifications
- Sprites: 16x16 or 32x32, PNG
- Tilesets: 256x256 max, power of 2
- Audio: 44.1kHz, OGG/WAV
- Levels: 100x100 tiles max
- Fonts: Bitmap fonts, 8x8 or 16x16 pixels
- Shaders: HXSL format, documented parameters

---

## Definition of Demo Complete
1. ✓ Splash → Menu → Game flow
2. ✓ Player can move and dash
3. ✓ Player can attack with combos
4. ✓ At least 2 enemy types with AI
5. ✓ One complete level (3-5 minutes)
6. ✓ Camera follow with shake
7. ✓ Basic audio (SFX + BGM)
8. ✓ Pause functionality
9. ✓ Particle effects for all major actions
10. ✓ No critical bugs
11. ✓ Runs at 60 FPS

---

## Risk Mitigation
- **Scope Creep**: Stick to HLD core mechanics only
- **Performance**: Profile early, optimize later
- **Art Pipeline**: Use placeholder art until Phase 6
- **Input Lag**: Test on target hardware regularly
- **Save System**: Implement early to avoid retrofitting
- **Shader Complexity**: Start with simple shaders, iterate

---

*Progressive development for vertical slice demo*