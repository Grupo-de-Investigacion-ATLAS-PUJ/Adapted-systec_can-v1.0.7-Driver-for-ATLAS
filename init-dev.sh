#!/bin/bash

# Default values
DEV="can0"
BITRATE=125000

# Help message
function print_help {
    echo "Usage: $0 [-d device] [-b bitrate]"
    echo "Options:"
    echo "  -d device   Specify the CAN device (default: can0)"
    echo "  -b bitrate  Specify the bitrate (default: 125000)"
    exit 1
}

# Parse command-line arguments
while getopts "d:b:h" opt; do
  case ${opt} in
    d )
      DEV=$OPTARG
      ;;
    b )
      BITRATE=$OPTARG
      ;;
    h )
      print_help
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      print_help
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      print_help
      ;;
  esac
done
shift $((OPTIND -1))

# Check if device exists
if ! ip link show $DEV > /dev/null 2>&1; then
    echo "Device $DEV does not exist"
    exit 1
fi

# Set up device
ip link set $DEV type can bitrate $BITRATE
ifconfig $DEV up