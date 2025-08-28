#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

TIME=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="$DIR/screenshot_$TIME.png"

# Take region screenshot
grim -g "$(slurp)" "$FILE"

# Copy to clipboard
wl-copy < "$FILE"
