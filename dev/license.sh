#!/bin/bash
# [ASSET PROTECTION] SOVEREIGN INTELLIGENCE - LICENSE UPDATER (v1.2)
# Purpose: Audit, Remove, and Replace license headers in .dart files.

# Define the Master Header
HEADER_TEXT="/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */"

echo "------------------------------------------------------------"
echo "Initializing License Audit & Update: $(date)"
echo "Target: All .dart files in ../lib (Excluding generated files)"
echo "------------------------------------------------------------"

MODIFIED_COUNT=0
UP_TO_DATE_COUNT=0

# Use a specific string from your header to identify existing blocks
IDENTIFIER="root of this project in the file: license.md"

find ../lib -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" | while read -r FILE; do
    
    # 1. Check if the file starts with the EXACT current header
    # We compare the first 6 lines of the file against the header
    FIRST_LINES=$(head -n 6 "$FILE")
    
    if [[ "$FIRST_LINES" == *"$HEADER_TEXT"* ]]; then
        # File is already perfectly aligned
        ((UP_TO_DATE_COUNT++))
        continue
    fi

    # 2. Check if an OLD or DIFFERENT version of the header exists
    # If the first 10 lines contain our 'IDENTIFIER', we assume a header is present
    if head -n 10 "$FILE" | grep -q "$IDENTIFIER"; then
        echo "[UPDATING] $FILE (Old header detected)"
        
        # Strip the existing comment block (from /* to */)
        # We use awk to skip everything until the first closing comment tag
        awk 'BEGIN {skip=0} /\/\*/ {skip=1} /\*\// {if (skip==1) {skip=0; next}} {if (skip==0) print}' "$FILE" > "$FILE.stripped"
        
        # Prepend the new Master Header
        echo "$HEADER_TEXT" > "$FILE.tmp"
        echo "" >> "$FILE.tmp"
        cat "$FILE.stripped" >> "$FILE.tmp"
        
        mv "$FILE.tmp" "$FILE"
        rm "$FILE.stripped"
        ((MODIFIED_COUNT++))
    else
        # 3. No header found at all, perform standard prepension
        echo "[PROTECTING] $FILE (No header found)"
        
        echo "$HEADER_TEXT" > "$FILE.tmp"
        echo "" >> "$FILE.tmp"
        cat "$FILE" >> "$FILE.tmp"
        
        mv "$FILE.tmp" "$FILE"
        ((MODIFIED_COUNT++))
    fi
done

echo "------------------------------------------------------------"
echo "AUDIT & UPDATE COMPLETE"
echo "Total files updated/protected: $MODIFIED_COUNT"
echo "Total files already compliant: $UP_TO_DATE_COUNT"
echo "------------------------------------------------------------"