# GitHub Pages Deployment Guide

This guide explains how to deploy the Action RPG game to GitHub Pages.

## Live Game URL

The game is playable at: https://bginbey.github.io/actionRPG/

## Initial Setup (Already Complete)

The gh-pages branch has already been created and configured. This section is for reference only.

1. Created orphan gh-pages branch: `git checkout --orphan gh-pages`
2. Removed all files: `git rm -rf .`
3. Copied web build files from `bin/` directory
4. Committed and pushed to GitHub
5. Enabled GitHub Pages in repository settings with gh-pages branch as source

## Updating the Live Game

To deploy new changes to the live game:

### 1. Build the Game for Web

```bash
# From the main branch
./build-web.sh
```

This creates the web build files in the `bin/` directory:
- `index.html`
- `game.js`
- `game.js.map`

### 2. Switch to gh-pages Branch

```bash
git checkout gh-pages
```

### 3. Copy Updated Files

```bash
# Copy the latest build files to the root
cp bin/index.html bin/game.js bin/game.js.map .
```

### 4. Commit and Push Changes

```bash
git add index.html game.js game.js.map
git commit -m "Update game build"
git push origin gh-pages
```

### 5. Return to Main Branch

```bash
git checkout main
```

## Deployment Notes

- Changes typically take 1-5 minutes to appear live
- GitHub Pages serves files from the root of the gh-pages branch
- The deployment is automatic once changes are pushed to gh-pages
- Check deployment status at: https://github.com/bginbey/actionRPG/actions

## Troubleshooting

If the game isn't loading:
1. Check browser console for errors
2. Ensure all files (index.html, game.js, game.js.map) are present in gh-pages branch
3. Verify GitHub Pages is enabled in repository settings
4. Clear browser cache and try again