#!/bin/bash

# Replace YOUR_USERNAME with your actual GitHub username
GITHUB_USERNAME="bginbey"

echo "Setting up GitHub remote..."
git remote add origin "https://github.com/${GITHUB_USERNAME}/actionRPG.git"

echo "Pushing to GitHub..."
git branch -M main
git push -u origin main

echo "Done! Your project is now on GitHub."
echo "Don't forget to:"
echo "1. Enable GitHub Pages in Settings → Pages → Source: GitHub Actions"
echo "2. Update the badge URL in README.md with your username"
echo "3. Update the repository URL in README.md"
