#!/bin/bash

# ---------- Terminal Size Check ----------
cols=$(tput cols)
lines=$(tput lines)

if (( cols < 60 || lines < 15 )); then
    clear
    echo "Terminal too small for dialog UI."
    echo "Resize your terminal window and try again."
    exit 1
fi

TMP_NAME="/tmp/folder_name_$$.txt"
TMP_CHOICES="/tmp/choices_$$.txt"
TMP_EXTRA="/tmp/extra_$$.txt"

# ---------- Main Folder Name ----------
dialog --title "Project Setup" \
       --inputbox "Enter folder name:" 0 0 \
       2> "$TMP_NAME"

PARENT_DIR=$(cat "$TMP_NAME")

if [ -z "$PARENT_DIR" ]; then
    clear
    echo "Cancelled."
    exit 1
fi

# ---------- Folder Selection ----------
dialog --separate-output \
       --checklist "Select Options (Space to select):" 0 0 0 \
       "config" "Folder" ON \
       "data" "Folder" ON \
       "logs" "Folder" ON \
       "docker-compose.yml" "File" OFF \
       ".env" "File" OFF \
       "other" "Add custom folders..." OFF \
       2> "$TMP_CHOICES"

CHOICES=$(cat "$TMP_CHOICES")

# ---------- Extra Folders ----------
EXTRA=""
if echo "$CHOICES" | grep -q "other"; then
    dialog --title "Extra Folders" \
           --inputbox "Additional folders (comma separated):" 0 0 \
           2> "$TMP_EXTRA"
    EXTRA=$(cat "$TMP_EXTRA")
fi

clear
echo "Creating structure for: $PARENT_DIR"

# ---------- Creation Phase ----------
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

    echo "---"
    echo "Success! Everything created in $(pwd)"

    cd ..
    sudo chmod -R 777 "$PARENT_DIR"
    echo "---"
    echo "Success! Folders created and permissions set."
else
    echo "Fatal Error: Could not create directory."
fi


# ---------- Cleanup ----------
rm -f "$TMP_NAME" "$TMP_CHOICES" "$TMP_EXTRA"
