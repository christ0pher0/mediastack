#!/bin/bash
# cbr_to_cbz.sh - Convert all CBR files to CBZ format
# Usage: ./cbr_to_cbz.sh /path/to/comics

COMICS_DIR="${1:-/mnt/plex/Comics}"
LOG_FILE="/tmp/cbr_to_cbz.log"
TEMP_DIR="/tmp/cbr_convert"
SUCCESS=0
FAILED=0
SKIPPED=0

echo "Starting CBR to CBZ conversion in: $COMICS_DIR" | tee "$LOG_FILE"
echo ""

mkdir -p "$TEMP_DIR"

while IFS= read -r cbr_file; do
    dir=$(dirname "$cbr_file")
    base=$(basename "$cbr_file" .cbr)
    cbz_file="$dir/$base.cbz"

    if [ -f "$cbz_file" ]; then
        echo "SKIP: $base" | tee -a "$LOG_FILE"
        SKIPPED=$((SKIPPED + 1))
        rm -rf "$TEMP_DIR"/*
        continue
    fi

    echo "Converting: $base" | tee -a "$LOG_FILE"

    rm -rf "$TEMP_DIR"/*
    mkdir -p "$TEMP_DIR"

    if unrar e -o+ "$cbr_file" "$TEMP_DIR/" >> "$LOG_FILE" 2>&1; then
        if zip -j "$cbz_file" "$TEMP_DIR"/* >> "$LOG_FILE" 2>&1; then
            rm -f "$cbr_file"
            echo "SUCCESS: $base" | tee -a "$LOG_FILE"
            SUCCESS=$((SUCCESS + 1))
        else
            echo "FAILED (zip): $base" | tee -a "$LOG_FILE"
            rm -f "$cbz_file"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "FAILED (unrar): $base" | tee -a "$LOG_FILE"
        FAILED=$((FAILED + 1))
    fi

    rm -rf "$TEMP_DIR"/*

done < <(find "$COMICS_DIR" -name "*.cbr" -type f | sort)

rm -rf "$TEMP_DIR"

echo "" | tee -a "$LOG_FILE"
echo "===============================" | tee -a "$LOG_FILE"
echo "Conversion complete!" | tee -a "$LOG_FILE"
echo "  Converted: $SUCCESS" | tee -a "$LOG_FILE"
echo "  Failed:    $FAILED" | tee -a "$LOG_FILE"
echo "  Skipped:   $SKIPPED" | tee -a "$LOG_FILE"
echo "===============================" | tee -a "$LOG_FILE"

