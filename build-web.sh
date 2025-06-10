#!/bin/bash

echo "Building Action RPG for web..."

# Build web version
echo "Building JavaScript version..."
haxe build-web.hxml

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Open bin/index.html in a web browser to play"
else
    echo "Build failed!"
    exit 1
fi