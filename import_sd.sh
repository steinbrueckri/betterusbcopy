#!/bin/bash

###############################################################################
# config
###############################################################################
SRC="/volumeUSB1/usbshare"               # Path to the SD card without trailing slash
DEST="/volume1/Speicherkarten_import/"   # Destination directory on the NAS
EMAIL="r.steinbrueck@pixel-combo.de"     # Email address for error notifications
TIMEOUT=120                              # Timeout for waiting the source directory to be mounted

###############################################################################
# functions
###############################################################################
log() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOGFILE"
}

send_mail() {
    local status=$1
    local message=$2
    local hostname=$(hostname)
    local script_name=$(basename "$0")
    echo -e "Subject: $script_name $status on $hostname\n\n$message" | ssmtp "$EMAIL"
    # Reset the LED to the default state
    echo 8 > /dev/ttyS1
}

beep() {
    local type=$1
    local count=$2
    for ((i=0; i<count; i++)); do
        echo "$type" > /dev/ttyS1
        sleep 0.5
    done
}

check_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        log "Directory $dir does not exist."
        beep 3 5
        send_mail "Error" "Directory $dir does not exist."
        exit 1
    fi
}

create_directory() {
    local dir=$1
    mkdir -p "$dir"
    if [ $? -ne 0 ]; then
        log "Failed to create directory $dir."
        beep 3 5
        send_mail "Error" "Failed to create directory $dir."
        exit 1
    fi
}

wait_for_mount() {
    local dir=$1
    for i in $(seq 1 "$TIMEOUT"); do
        if mount | grep "$dir" > /dev/null; then
            return
        fi
        sleep 1
    done
    log "Failed to detect mount of $dir within $TIMEOUT seconds."
    beep 3 5
    send_mail "Error" "Failed to detect mount of $dir within $TIMEOUT seconds."
    exit 1
}

handle_exit() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        send_mail "Crash Report" "Script exited with status $exit_code. Check the log file at $LOGFILE for details."
    fi
    exit $exit_code
}

trap handle_exit EXIT

###############################################################################
# main script
###############################################################################

# Ensure the destination directory exists
check_directory "$SRC"
check_directory "$DEST"

# Create folder with datetime
DATETIME=$(date '+%d%m%Y%H%M%S')
FINALDEST="$DEST/$DATETIME"
LOGFILE="$FINALDEST/usbcopy.log"
create_directory "$FINALDEST"

log "Script started."

# Play a tone when the script starts (2x short beep)
beep 2 2

# Turn on the USBCopy LED (flashing green)
echo A > /dev/ttyS1

# Wait for the source directory to be mounted
wait_for_mount "$SRC"

# Copy all files without overwriting existing files and log the output with progress
rsync -a --info=progress2 "$SRC/" "$FINALDEST/" &>> "$LOGFILE"
RESULT=$?
if [ $RESULT -eq 0 ]; then
    log "Files copied successfully to $FINALDEST."
    # Turn the USBCopy LED solid green
    echo 9 >/dev/ttyS1
    sleep 10
    # Play a tone when the script successfully ends (2x short beep)
    beep 2 2
else
    log "Error during file copy. rsync exited with status $RESULT."
    send_mail "Error" "Error during file copy. rsync exited with status $RESULT. Check the log file at $LOGFILE for details."
    # Play a tone in case of an error (5x long beep)
    beep 3 5
    exit 1
fi

umount $SRC
log "Unmounted $SRC."

# Turn off the USBCopy LED
echo 8 > /dev/ttyS1

log "Script ended."
