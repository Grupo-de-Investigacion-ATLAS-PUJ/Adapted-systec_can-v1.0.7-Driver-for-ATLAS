#!/bin/sh

FW_DIR=/lib/firmware
FIRMWARE_FILES=systec_can-*.fw

mkdir -p ${FW_DIR}
install --mode=644 ${FIRMWARE_FILES} ${FW_DIR}
echo "Firmware files installed to ${FW_DIR}"
