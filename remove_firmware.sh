#!/bin/sh

FW_DIR=/lib/firmware
FIRMWARE_FILES=systec_can-*.fw

rm -f ${FW_DIR}/${FIRMWARE_FILES}
echo "Firmware files removed from ${FW_DIR}"
