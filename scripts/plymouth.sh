#!/bin/bash

FILE="/etc/mkinitcpio.conf"
HOOKS="plymouth"

# Add plymoth to initramfs hooks
if grep -q "^HOOKS=" $FILE; then
    if ! grep -q "plymouth" $FILE; then
        sudo sed -i '/^HOOKS=/ s/\(udev\)/\1 '"$HOOKS"'/' $FILE
        echo "Plymouth added to HOOKS. Regenerating initramfs..."
        sudo mkinitcpio -P
    else
        echo "Plymouth already exists in HOOKS."
    fi
else
    echo "No HOOKS line found."
    exit 1
fi

# Add "splash" to boot params

FILE="/efi/loader/entries/arch.conf"

if grep -q "^options" $FILE; then
    if ! grep -q "splash" $FILE; then
        sudo sed -i '/^options/ s/$/ splash/' $FILE
        echo "splash added to options."
    else
        echo "splash already exists in options."
    fi
else
    echo "No options line found."
    exit 1
fi
