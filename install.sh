#!/bin/bash

################################################################################
# config
################################################################################
UDEV_RULES_FILE="/lib/udev/rules.d/99-usb.rules"

################################################################################
# functions
################################################################################

install_udev_rule() {
    echo "Creating udev rule..."
    echo 'ACTION=="add", KERNEL=="sd[a-z][0-9]", RUN+="/usr/local/bin/import_photos.sh"' | sudo tee $UDEV_RULES_FILE
    echo "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "udev rule installed and reloaded."
}

################################################################################
# main installation process
################################################################################
install_udev_rule

echo "Installation completed successfully."
