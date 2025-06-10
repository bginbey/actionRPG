#!/bin/bash

echo "Building Action RPG..."

# Set HL path
HL_PATH="./hl"
if [ ! -f "$HL_PATH" ]; then
    HL_PATH="hl"
fi

echo "Building HashLink version..."
haxe build.hxml

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Running game..."
    if [ -f "./run-hl.sh" ]; then
        ./run-hl.sh bin/game.hl
    else
        $HL_PATH bin/game.hl
    fi
else
    echo "Build failed!"
    exit 1
fi