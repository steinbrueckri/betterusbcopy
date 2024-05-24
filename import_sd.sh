#!/bin/bash
################################################################################
# TODOs
# - Notifications
################################################################################

###############################################################################
# config
################################################################################
SRC="/volumeUSB1/usbshare/"             # Path to the SD card
DEST="/volume1/Speicherkarten_import/"  # Destination directory on the NAS

################################################################################
# functions
################################################################################
beep() {
    # type can be 2 or 3
    # 2 - Emit a short beep tone
    # 3 - Emit a long beep sound
    local type=$1
    local count=$2
    for ((i=0; i<count; i++)); do
        echo "$type" > /dev/ttyS1
        sleep 0.5
    done
}

################################################################################
# main script
################################################################################

# Ensure the destination directory exists
mkdir -p "$DEST"

# Play a tone when the script starts (2x short beep)
beep 2 2

# Turn on the USBCopy LED (flashing green)
echo A > /dev/ttyS1

# Create folder
DATETIME=$(date '+%d%m%Y%H%M%S')
FINALDEST="$DEST/$DATETIME"
mkdir "$FINALDEST"

# Wait for the source directory to be mounted (max 60 seconds)
for i in {1..60}; do
    if mount | grep "$SRC" > /dev/null; then
        break
    fi
    sleep 1
done

# Copy all files without overwriting existing files
rsync -a "$SRC/" "$FINALDEST/"
RESULT=$?
if [ $RESULT -eq 0 ]; then
    # Turn the USBCopy LED solid green
    echo 9 >/dev/ttyS1 # USBCopy LED on solid green
    sleep 10
    # Play a tone when the script successfully ends (2x short beep)
    beep 2 2
else
    # Play a tone in case of an error (5x long beep)
    beep 3 5
fi

umount $SRC

# Turn off the USBCopy LED
echo 8 > /dev/ttyS1
