# Quick Reference Guide

## Key Documents
- **Philosophy**: DEVELOPMENT_PHILOSOPHY.md - Core principles, conventions, patterns
- **Roadmap**: DEVELOPMENT_ROADMAP.md - Development phases and milestones

## Core Principles
1. **Reuse First** - Always check for existing code before creating new
2. **Heaps Conventions** - Use h2d.Object hierarchy, hxd.Res for resources
3. **DRY** - No duplication, extract common functionality
4. **Data-Driven** - Expose values to designers, no magic numbers

## Project Structure
```
src/         # Source code
res/         # Resources (auto-monitored by Heaps)
bin/         # Build output
```

## Naming Conventions
- Classes: `PascalCase`
- Methods: `camelCase` (Haxe style)
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Assets: `Type_Name_Variant_State`

## Current Specs
- Tile size: 16x16 pixels
- Player size: 32x32 pixels
- Target FPS: 60

## Git Workflow
- Feature branches from develop
- Commit format: `[Type] Description`
- Types: [Feature], [Fix], [Refactor], [Art], [Audio], [Config]

## Common Heaps Patterns
```haxe
// Entity pattern
class MyEntity extends h2d.Object {
    public function update(dt: Float) { }
}

// Resource loading
var sprite = hxd.Res.sprites.player.toTile();

// Scene management
class MyScene extends h2d.Scene { }
```

## Performance Targets
- 60 FPS with 50+ enemies
- < 100ms level load
- < 1000 particles without drops

## Next Phase: Foundation (Phase 1)
- Project setup
- Scene management
- Resource pipeline