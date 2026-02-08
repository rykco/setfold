#!/bin/bash

APP_PATH="/usr/local/bin/setfold"
RAW_URL="https://raw.githubusercontent.com/rykco/setfold/main/setfold.sh"

# Install dialog if missing
if ! command -v dialog &> /dev/null; then
    echo "Installing dialog..."
    sudo apt install -y dialog || (sudo apt update && sudo apt install -y dialog)
fi

# Setup /rykco
if [ ! -d "/rykco" ]; then
    sudo mkdir -p /rykco
    sudo chown -R $USER:$USER /rykco
fi

# Install setfold
sudo wget -qO "$APP_PATH" "$RAW_URL"
sudo chmod +x "$APP_PATH"

echo "-----------------------------------------------"
echo "Success! setfold is installed."
echo "Run it with: setfold"
echo "-----------------------------------------------"
