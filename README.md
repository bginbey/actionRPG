# Action RPG (Hyper Light Drifter Inspired)

[![Build Action RPG](https://github.com/[username]/actionRPG/actions/workflows/build.yml/badge.svg)](https://github.com/[username]/actionRPG/actions/workflows/build.yml)

A pixel-art action RPG built with Heaps.io, inspired by Hyper Light Drifter's fluid combat and movement mechanics.

## 🎮 Project Status

### ✅ Phase 1: Foundation (Complete)
- Project structure with Heaps.io
- Fixed timestep game loop (60 FPS logic)
- Scene management system with transitions
- Splash screen with fade effects
- Main menu with keyboard/mouse navigation
- Resource pipeline configuration
- Pixel-perfect text rendering

### 🚧 Upcoming Phases
- Phase 2: Core Systems (Tilemap, Camera, Entity system)
- Phase 3: Player Implementation (Movement, Dash, Combat)
- Phase 4: Combat System
- Phase 5: Enemy AI
- Phase 6: Polish & Effects

## 🛠️ Setup

### Prerequisites
- Haxe 4.x
- Heaps.io library
- HashLink VM (for native builds)

### Installation
```bash
# Install dependencies
haxelib install heaps
haxelib install hlsdl

# Clone the repository
git clone [repository-url]
cd actionRPG
```

### Building & Running

**Web (Recommended for ARM Macs):**
```bash
./build-web.sh
# or manually:
haxe build-web.hxml
# Open bin/index.html in a web browser
```

**HashLink (Native - x86_64 only):**
```bash
./build.sh
# or manually:
haxe build.hxml
hl bin/game.hl
```

**Note for Apple Silicon (M1/M2/M3) Users:**
Due to HashLink JIT limitations on ARM64, native builds don't currently work on Apple Silicon Macs. Use the web build for development, which provides full functionality and fast iteration.

## 📁 Project Structure
```
actionRPG/
├── src/                  # Source code
│   ├── scenes/          # Game scenes
│   ├── entities/        # Game objects
│   ├── systems/         # Core systems
│   ├── ui/              # UI components
│   └── Main.hx          # Entry point
├── res/                  # Resources
│   ├── sprites/         # Sprite assets
│   ├── sounds/          # Audio files
│   ├── data/            # Game data (JSON)
│   └── shaders/         # HXSL shaders
├── bin/                  # Build output
└── docs/                 # Documentation
```

## 🎯 Core Features (Planned)
- **Movement**: 8-directional movement with acceleration
- **Dash**: Chain-dash mechanic with ghost trails
- **Combat**: 3-hit combo system with directional attacks
- **Enemies**: AI with patrol, chase, and attack behaviors
- **Effects**: Particle systems, screen shake, shader effects

## 📖 Development Guidelines
See [DEVELOPMENT_PHILOSOPHY.md](DEVELOPMENT_PHILOSOPHY.md) for coding standards and best practices.

## 🗺️ Roadmap
See [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) for detailed development phases.

## 🎨 Art Style
- 16x16 pixel tile grid
- 32x32 pixel character sprites
- Limited color palette
- Pixel-perfect rendering

## 🔧 Debug Controls
- **F1**: Heaps inspector (debug builds)
- **ESC**: Return to menu (in game)