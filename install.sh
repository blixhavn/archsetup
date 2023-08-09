#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored text
colorEcho(){
    COLOR=$1
    echo -e "${COLOR}$2${NC}"
}

colorEcho ${CYAN} "
   _____                .__    .___       .__  __   
  /  _  \\_______   ____ |  |__ |   | ____ |__|/  |_ 
 /  /_\\  \\_  __ \\_/ ___\\|  |  \\|   |/    \\|  \\   __\\
/    |    \\  | \\/\\  \\___|   Y  \\   |   |  \\  ||  |  
\\____|__  /__|    \\___  >___|  /___|___|  /__||__|  
        \\/            \\/     \\/         \\/          
"

colorEcho ${GREEN} "Starting..."

# Adding Pacman hooks
colorEcho ${GREEN} "Adding Pacman hooks..."
sudo mkdir -p /etc/pacman.d/hooks
sudo cp ./pacman-hooks/* /etc/pacman.d/hooks/

# Update pacman
colorEcho ${GREEN} "Updating pacman..."
sudo pacman -Syu

# Install latest arch keychain
colorEcho ${GREEN} "Installing latest Arch keychain..."
sudo pacman -S archlinux-keyring

# Install paru
colorEcho ${GREEN} "Installing paru..."
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..

# Use paru to install packages in pkglist.txt
colorEcho ${GREEN} "Installing packages..."
paru -S --needed - < pkglist.txt

# Copy etc files
colorEcho ${GREEN} "Copying etc files..."
cp -R etc/* /etc/

# Copy dotfiles
colorEcho ${GREEN} "Copying dotfiles..."
cp -R dotfiles/* ~

# Call dotfiles/install.sh
colorEcho ${GREEN} "Running dotfiles/install.sh..."
./dotfiles/install.sh

colorEcho ${GREEN} "Dotfiles install complete!"

# Install and enable services
colorEcho ${GREEN} "Installing services..."
sudo cp services/* /etc/systemd/system/
for service in services/*; do
    # Extract the service name from the file path
    service_name=$(basename -- "$service")
    service_name="${service_name%.*}"
    
    colorEcho ${CYAN} "Enabling $service_name.service"
    sudo systemctl enable $service_name.service
    
    colorEcho ${CYAN} "Starting $service_name.service"
    sudo systemctl start $service_name.service
done

# Call custom scripts
for script in ./scripts/*; do
    if [ -f "$script" ] && [ -x "$script" ]
    then
        colorEcho ${GREEN} "Running $script..."
        $script
    fi
done
