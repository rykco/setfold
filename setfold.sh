#!/bin/bash

TMP_NAME="/tmp/folder_name_$$.txt"
TMP_CHOICES="/tmp/choices_$$.txt"
TMP_EXTRA="/tmp/extra_$$.txt"

dialog --title "Project Setup" --inputbox "Enter folder name:" 8 40 2> "$TMP_NAME"
PARENT_DIR=$(cat "$TMP_NAME")

if [ -z "$PARENT_DIR" ]; then
    clear; echo "Cancelled."; exit 1
fi

dialog --separate-output --checklist "Select Options (Space to select):" 15 50 7 \
    "config" "Folder" ON \
    "data" "Folder" ON \
    "logs" "Folder" ON \
    "docker-compose.yml" "File" OFF \
    ".env" "File" OFF \
    "other" "Add custom folders..." OFF 2> "$TMP_CHOICES"

CHOICES=$(cat "$TMP_CHOICES")

EXTRA=""
if echo "$CHOICES" | grep -q "other"; then
    dialog --title "Extra Folders" --inputbox "Additional folders (comma separated):" 8 45 2> "$TMP_EXTRA"
    EXTRA=$(cat "$TMP_EXTRA")
fi

clear
echo "Creating structure for: $PARENT_DIR"

if mkdir -p "$PARENT_DIR"; then
    cd "$PARENT_DIR" || exit

    while read -r item; do
        if [[ "$item" == "docker-compose.yml" || "$item" == ".env" ]]; then
            touch "$item"
            echo "  [FILE]   Created $item"
        elif [[ "$item" != "other" && -n "$item" ]]; then
            mkdir -p "$item"
            echo "  [FOLDER] Created $item/"
        fi
    done < "$TMP_CHOICES"

    if [ -n "$EXTRA" ]; then
        IFS=',' read -ra ADDS <<< "$EXTRA"
        for folder in "${ADDS[@]}"; do
            clean_folder=$(echo "$folder" | xargs)
            if [ -n "$clean_folder" ]; then
                mkdir -p "$clean_folder"
                echo "  [CUSTOM] Created $clean_folder/"
            fi
        done
    fi

    echo "---"
    echo "Success! Everything created in $(pwd)"
else
    echo "Fatal Error: Could not create directory."
fi

rm -f "$TMP_NAME" "$TMP_CHOICES" "$TMP_EXTRA"
