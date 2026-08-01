#!/bin/bash

# Find all files and move them into year-based directory

DESKTOP=~/Desktop

find "$DESKTOP" -maxdepth 1 -type f | while read -r file; do 
    # Extract modification year
    year=$(date -r "$file" +%Y); 

    # Create target folder if it doesn't exist
    target="$DESKTOP/$year"
    mkdir -p "$target"; 

    # Move the file
    echo "Moving: $file to $target/"; 
    mv "$file" "$target/"
done

