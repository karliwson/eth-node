#!/bin/bash

# > prepare-volume.sh
# Author: Kaká Oliveira (kakafka)
#
# Usage:
# <script> DEVICE_NAME=? FILESYSTEM=? MOUNT_POINT=? DATA_OWNER=?

# Parse cli params
# TODO: Validate params
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"
   export "$KEY"="$VALUE"
done

DEVICE_PATH="/dev/${DEVICE_NAME}"
UUID_MATCHER="[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"

# If the volume is already initialized, ignore
inited=$(lsblk -f | grep -E "(${DEVICE_NAME}).*(${UUID_MATCHER})")
if [ $? -eq 0 ]; then
    echo "- The volume is already initialized"
else
    echo "- Initializing data volume"
    set -e
    mkfs -t "${FILESYSTEM}" "${DEVICE_PATH}"
fi

# Abort script on any unsuccessful exitcode
set -e

echo "- Mounting volume to ${MOUNT_POINT}"

# Create mount point
if [ -d "$MOUNT_POINT" ];
then
    echo "- ${MOUNT_POINT} already exists"
else
    mkdir -p "${MOUNT_POINT}"
fi

# Mount volume
if grep -qs "${DEVICE_PATH} " /proc/mounts; then
    echo "- ${DEVICE_PATH} is already mounted"
else
    mount "${DEVICE_PATH}" "${MOUNT_POINT}"
    echo "- Changing owner of '${MOUNT_POINT}/*' to ${DATA_OWNER}"
    chown -R "${DATA_OWNER}" "${MOUNT_POINT}"
fi

# Add volume to fstab so it mounts automatically upon boot
if grep -qs "${MOUNT_POINT} " /etc/fstab; then
    echo "- ${MOUNT_POINT} is already in fstab"
else
    echo "- Adding ${MOUNT_POINT} to fstab"
    NODE_VOLUME_UUID=$(blkid | grep "${DEVICE_NAME}" | grep -Eo "(${UUID_MATCHER})")
    FSTAB_ENTRY="UUID=${NODE_VOLUME_UUID}  ${MOUNT_POINT}  ${FILESYSTEM}  defaults,nofail  0  2"
    echo "- ${FSTAB_ENTRY}" >> /etc/fstab
fi

echo "- Volume successfully configured!"
