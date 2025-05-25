#!/bin/bash

# Temporary screenshot file
IMG=$(mktemp /tmp/screenocr_XXXX.png)

# Select area and capture
grim -g "$(slurp)" "$IMG"

# OCR the image
TEXT=$(tesseract "$IMG" - -l eng)

# Copy to clipboard (optional)
echo "$TEXT" | wl-copy

# Clean up
rm "$IMG"
