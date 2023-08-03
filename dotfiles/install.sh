#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print colored text
colorEcho(){
    COLOR=$1
    echo -e "${COLOR}$2${NC}"
}

colorEcho ${GREEN} "Starting dotfiles install..."

# Here you can add commands for installing other parts of your dotfiles
# For example, you might want to create symlinks for your configuration files
# ln -s ~/dotfiles/vimrc ~/.vimrc

colorEcho ${GREEN} "Restoring VS Code extensions..."
while read extension; do
    colorEcho ${GREEN} "Installing $extension..."
    code --install-extension $extension
done < .vscode/extensions.txt

colorEcho ${GREEN} "Dotfiles install complete!"

