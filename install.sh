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

# Determine script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SKIP_PACKAGES=false
SKIP_SERVICES=false

for arg in "$@"; do
    case $arg in
        --skip-packages)
            SKIP_PACKAGES=true
            shift # Remove --skip-packages from processing
            ;;

        --skip-services)
            SKIP_SERVICES=true
            shift # Remove --skip-packages from processing
            ;;
        *)
            # Handle other arguments if necessary
            shift 
            ;;
    esac
done

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
sudo cp $DIR/pacman-hooks/* /etc/pacman.d/hooks/

if [ "$SKIP_PACKAGES" = false ]; then
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
    rm -rf paru

    # Use paru to install packages in pkglist.txt
    colorEcho ${GREEN} "Installing packages..."
    paru -S --needed - < $DIR/pkglist.txt
else
    colorEcho ${GREEN} "Skipping package installation..."
fi


colorEcho ${GREEN} "Copying etc files..."
sudo cp -R $DIR/etc/* /etc/

colorEcho ${GREEN} "Copying usr/share files..."
sudo cp -R $DIR/usrshare/* /usr/share/

# Copy dotfiles
colorEcho ${GREEN} "Copying dotfiles..."
find $DIR/dotfiles -mindepth 1 -name '.*' -exec cp -r {} ~ \;

# Call dotfiles/install.sh
colorEcho ${GREEN} "Running dotfiles/install.sh..."
bash $DIR/dotfiles/install.sh

colorEcho ${GREEN} "Dotfiles install complete!"

colorEcho ${GREEN} "Copying fonts..."
mkdir -p ~/.local/share/fonts
cp -r $DIR/fonts/* ~/.local/share/fonts/

# Install and enable services

if [ "$SKIP_PACKAGES" = false ]; then
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
    sudo systemctl enable lightdm
else
    colorEcho ${GREEN} "Skipping systemd services..."
fi

# Call custom scripts
for script in ./scripts/*; do
    if [ -f "$script" ] && [ -x "$script" ]
    then
        colorEcho ${GREEN} "Running $script..."
        $script
    fi
done
