#!/bin/bash

echo "Updating LightDM configs..."

LIGHTDM_CONF="/etc/lightdm/lightdm.conf"
WEBKIT2_GREETER_CONF="/etc/lightdm/lightdm-webkit2-greeter.conf"
THEME_NAME="lightdm-webkit-theme-aether" 


# Update lightdm.conf with inline replacement
if grep -qE "^(#)?greeter-session=" "$LIGHTDM_CONF"; then
    sudo sed -i "s/^(#)?greeter-session=.*/greeter-session=lightdm-webkit2-greeter/" "$LIGHTDM_CONF"
else
    echo "greeter-session=lightdm-webkit2-greeter" | sudo tee -a "$LIGHTDM_CONF" > /dev/null
fi

if grep -qE "^(#)?user-session=" "$LIGHTDM_CONF"; then
    sudo sed -i "s/^(#)?user-session=.*/user-session=i3/" "$LIGHTDM_CONF"
else
    echo "user-session=i3" | sudo tee -a "$LIGHTDM_CONF" > /dev/null
fi

# Update lightdm-webkit2-greeter.conf with inline replacement for the webkit theme
if grep -qE "^(#)?webkit-theme=" "$WEBKIT2_GREETER_CONF"; then
    sudo sed -i "s/^(#)?webkit-theme=.*/webkit-theme=\"$THEME_NAME\"/" "$WEBKIT2_GREETER_CONF"
else
    echo "webkit-theme=\"$THEME_NAME\"" | sudo tee -a "$WEBKIT2_GREETER_CONF" > /dev/null
fi

echo "Configurations have been updated!"

