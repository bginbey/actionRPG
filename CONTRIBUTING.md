# Contributing to Action RPG

Thank you for your interest in contributing! This guide will help you get started.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/[your-username]/actionRPG.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Commit with meaningful messages: `git commit -m "[Feature] Add dash ability"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Open a Pull Request

## 📋 Before You Submit

### Code Style
- Follow the conventions in [DEVELOPMENT_PHILOSOPHY.md](DEVELOPMENT_PHILOSOPHY.md)
- Use camelCase for methods and variables (Haxe convention)
- Keep methods under 50 lines
- No magic numbers - use constants or config values

### Testing
- Run `./build-web.sh` to ensure your changes compile
- Test your changes in multiple browsers if modifying UI/rendering
- Check that existing features still work

### Commit Messages
Format: `[Type] Brief description`

Types:
- `[Feature]` - New functionality
- `[Fix]` - Bug fixes
- `[Refactor]` - Code improvements without changing functionality
- `[Art]` - Asset additions or modifications
- `[Audio]` - Sound/music changes
- `[Config]` - Configuration changes
- `[Docs]` - Documentation updates

## 🔄 Pull Request Process

1. **Title**: Use the same format as commit messages
2. **Description**: Explain what changes you made and why
3. **Screenshots**: Include before/after screenshots for visual changes
4. **Testing**: Describe how you tested your changes
5. **Related Issues**: Link any related issues with `Fixes #123`

## 🎮 Development Workflow

### For New Features
1. Check [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md) for planned features
2. Discuss major features in an issue first
3. Keep PRs focused - one feature per PR
4. Update documentation if needed

### For Bug Fixes
1. Check if the bug is already reported
2. Include steps to reproduce in your PR
3. Add a test if possible to prevent regression

### For Performance Improvements
1. Include benchmarks showing the improvement
2. Ensure no functionality is broken
3. Document any trade-offs

## 🏗️ Project Structure

```
src/
├── scenes/      # Game scenes (Menu, Game, etc.)
├── entities/    # Game objects (Player, Enemy, etc.)
├── systems/     # Core systems (Combat, Movement, etc.)
├── components/  # Reusable components
├── ui/          # UI elements
└── utils/       # Helper functions
```

## 🔧 Local Development

### ARM Mac (Apple Silicon)
Use web builds for development:
```bash
./build-web.sh
open bin/index.html
```

### Intel Mac / Windows / Linux
You can use native HashLink builds:
```bash
./build.sh
```

## ❓ Questions?

- Check existing issues and discussions
- Ask in the PR or create a new issue
- Be patient and respectful

## 📜 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Have fun and make games!

Thank you for contributing to make this project better! 🎮✨