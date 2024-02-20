&copy; SYSTEC electronic AG, D-08468 Heinsdorfergrund, Am Windrad 2<br>
www.systec-electronic.com

# ATLAS Modified SocketCAN Driver for USB-CANmodul series

## Requirements

* USB-CANmodul series generation 3 and 4
* AlmaLinux 9.3 instalation with kernel 5.14.0-362.18.1.el9_3.x86_64
* CAN utilities from the ATLAS repository (It is included in this repository)
* Following kernel options have to be set:
```
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
```
```shell
$ sudo rpm -i CANUtilities.rpm
```

## Supported features

* CAN frame reception and transmission:
  + standard frame format (11 bit identifier)
  + extended frame format (29 bit identifier)
  + remote transmit request frames (RTR)

* Supported CAN controller states:
  + `CAN_STATE_ERROR_ACTIVE`  (CAN bus runs error-free)
  + `CAN_STATE_ERROR_WARNING` (error counters reached warning limit)
  + `CAN_STATE_ERROR_PASSIVE` (node sends passive error frames)
  + `CAN_STATE_BUS_OFF`       (node does not send any frames,
                             i.e. it is virtually disconnected from bus)

* Supported SocketCAN error frame flags
  (not to mix up with CAN error frames according to CAN specification)
```c
    struct can_frame frame;
    ....
    if (frame.can_id & CAN_ERR_FLAG) {
      if (frame.can_id & CAN_ERR_BUSOFF) {
        /* BUS OFF */ }
      if (frame.can_id & CAN_ERR_RESTARTED) {
        /* recover from BUS OFF */ }
      if (frame.can_id & CAN_ERR_CRTL) {
        if (frame.data[1] & (CAN_ERR_CRTL_RX_WARNING |
            CAN_ERR_CRTL_TX_WARNING)) {
          /* warning limit reached */ }
        if (frame.data[1] & (CAN_ERR_CRTL_RX_PASSIVE |
            CAN_ERR_CRTL_TX_PASSIVE)) {
          /* error passive state entered */ }
        if (frame.can_id & CAN_ERR_PROT) {
          if (frame.data[2] & CAN_ERR_PROT_ACTIVE) {
            /* error active state entered */ }
        }
      }
    }
```

* Supported CAN controller modes
  + `CAN_CTRLMODE_3_SAMPLES`  (Triple sampling mode)
  + `CAN_CTRLMODE_LISTENONLY` (Listen-only mode)
  + `CAN_CTRLMODE_ONE_SHOT` (One-Shot mode, only for PIDs 0x1121, 0x1122, 0x1123 and 0x1125)

* Tx echo is implemented in driver and there is optional support for
  hw based Tx echo.


## Limitations

* Firmware version >=4.06 must be installed on USB-CANmodul.
  In case of an older firmware version, please connect the USB-CANmodul to a
  Windows PC with a recent driver version. The Windows driver will update the
  firmware. Afterwards also this driver is capable of updating the firmware.
* There is currently no way to read out or set the digital I/Os of the
  user port or the CAN port (signals EN, /STB, /ERR, /TRM).
* No support for the obsolete modules GW-002 and GW-001.
  This is not planned at all.
* Planned CAN controller modes
  + `CAN_CTRLMODE_LOOPBACK`   (Loopback mode)
* After an update of firmware files, the Linux system has to be restarted
  for the system to use the newer ones, as the kernel caches firmware files
  on filename base.
* **TO TAKE INTO ACCOUNT!!!!**
* The original version of the driver was compatible with kernel 5.15. This kernel
    is not available in the AlmaLinux 9.3 repository. The driver was modified to be
    compatible with the 5.14.0-362.18.1.el9_3.x86_64 kernel. The driver was tested
    with this kernel and it worked correctly. The driver was not tested with other
    kernel versions. 
*  This modified driver (because the feature was introduced in 5.15, and does not exist in 5.14) 
***does not support the can_led_event mode.*** Therefore, **THE CAN LEDS WILL NOT WORK ON CERTAIN FIRMWARES**.


## Installation

### Install the CAN utilities

```shell
$ sudo rpm -i CANUtilities.rpm
```

### Check that they're installed

```shell
$ lsmod | grep can
```

### Build the driver

Run make within the source directory
```shell
$ cd systec_can
$ make all
```

### Loading the driver from the local source directory

1. If the CAN modules are not loaded, load basic CAN drivers
```shell
$ sudo modprobe can_raw
$ sudo modprobe can_dev
```

2. Install firmware

```shell
$ sudo make firmware_install
```

3. Load USB-CANmodul driver

```shell
$ sudo insmod systec_can.ko
```

## Module parameters

The driver has the following module parameters:

* debug (type int)

  This is a bitmask enabling/disabling different parts of debug messages at
  module load time or during runtime.<br>
  It can be set during a manual insmod: e.g. `insmod systec_can.ko debug=0x1`
  or use `/etc/modprobe.d/` (actual path may depend on used version and/or
  distribution) for usage with modprobe and/or automatically load with udev.<br>
  All messages are still send with debug level, so a system logger may need to be
  configured accordingly.

  Available Bits:
  + Bit 0: Generic driver debug message for module load/unload and interface up/down
  + Bit 1: USB command message dump
  + Bit 2: USB status message dump
  + Bit 3: USB data message dump
  + Bit 4: Tx related events (start and finish of USB transfer)
  + Bit 5: Bittiming related output (e.g. settings like bitrate and sample point)
  + Bit 6: USB command message events
  + Bit 7: Error handling events
  + Bit 8: Disconnect related events

* hw_txecho (type boolean)

  If set the CAN frame will be echoed when actually sent by the hardware. Any change
  to this flags will become effective when the interface is (re-)started.

## Known Issues

* When updating the bootloader from version 1.01 r2 it might happen that the
  device will not reconnect properly. LEDs are not indicating this.
  Workaround: Disconnect the device physically and reconnect it afterwards.
* Rare, but possible out-of-order issues on SMP systems. See
  * https://marc.info/?l=linux-can&m=148000256801316&w=2
  * https://marc.info/?l=linux-can&m=143637774606287&w=2

  **Workaround**: Write a bitmask (a bit for each CPU available being set) to `/sys/class/net/can0/queues/rx-0/rps_cpus`. e.g. `echo f > /sys/class/net/can0/queues/rx-0/rps_cpus` for a system with 4 CPUs (both logical and physical)

## Run basic tests

1. Connect the USB-CANmodul to the PC

    Note: Some of the following commands require the capability `CAP_NET_ADMIN`.
      So those commands should be executed as root (e.g. via sudo).

2. Set bitrate to 125kBit/s
    ```shell
    $ ip link set can0 type can bitrate 125000
    ```
    *OR* if `CONFIG_CAN_CALC_BITTIMING` is undefined
    ```shell
    $ ip link set can0 type can tq 500 prop-seg 6 phase-seg1 7 phase-seg2 2
    ```

3. Start up the CAN interface

    ```shell
    $ ip link set can0 up
    ```

4. Dump the traffic on the CAN bus

    ```shell
    $ cd can-utils
    $ ./candump can0
    ```
    to display error frames (option -e is supported in newer candump versions only):

    ```shell
    $ ./candump -e can0,0:0,#FFFFFFFF
    ```
5. Transmit one CAN frame

    ```shell
    $ cd can-utils
    $ ./cangen -n 1 -I 640 -L 8 -D 4000100000000000 can0
    ```

6. Print out some statistics

    ```shell
    $ ip -details -statistics link show can0
    ```

7. Restart CAN channel manually in case of bus-off (i.e. short circuit)

    ```shell
    $ ip link set can0 type can restart
    ```
    Automatically restart the CAN channel 1000 ms after bus-off occurs

    ```shell
    $ ip link set can0 type can restart-ms 1000
    ```

8. Increase the transmit queue length from default value 10 to 1000.
   10 is the size of one CAN message.

    ```shell
    $ ip link set can0 txqueuelen 1000
    ```

## Hardware address

The hardware address (like the MAC address of Ethernet controllers)
of each CAN channel as shown with
`ip link show can0` or `ifconfig can0` is formed the following way:

`S0:S1:S2:S3:DN:CN`

* Sx - Serial Number in Hex with S0 contains the most significant byte
* DN - Device Number
* CN - Channel Number (00 - CAN1, 01 - CAN2)

The unique hardware address can be used by a special udev rule to
assign stable interface names and numbers.

**Note:** The usage of hardware address for serial numbers to identify devices
is discouraged by Kernel developers and might change.

## sysfs attributes

### devicenr

The Device Number can be changed via the sysfs attribute `devicenr` under
`/sys/class/net/*/device/devicenr` (where * corresponds to the interface name like
`can0`) or `/sys/bus/usb/devices/*/devicenr` (where * corresponds to the USB device
path like `3-1:1.0`). Please note the hardware address will change after device
reset.

### dual_channel

This USB interface attribute shows 0 for a single-channel device and 1 for a dual-channel device.

### reset

Any write to this USB interface reset the device.

### channel

This CAN interface attribute shows the channel number on the device.

### tx_timeout_ms

This CAN interface attribute on a dual-channel device configures a timeout when
a message shall be dropped, if it cannot be sent due to
e.g. low CAN-ID priority, not connected bus, ...

In this case the other channel is blocked due to firmware restrictions.
Using this timeout the other, correctly connected, channel can still be used.

### status_timeout

This USB device attribute can read/write the status timeout in ms. When a
CAN interface is active the status request URB must be send within this
limit after the last one or the device will disconnect and reconnect itself.

A timeout of 0 means the check is disabled.

Any change will only take effect after power-on the USB-CAN-Module!

### high_performance

This USB device attribute can read/write the CAN clock speed. It shows 0
for slower clock speed (24 MHz) and 1 for higher performance (+25% clock speed = 30 MHz).
To use the new setting, the device must be restarted (see sysfs attribute reset).

## udev rules examples

Example for udev rule (file `/etc/udev/rules.d/20-systec-can.rules`):

```udev
# USB device 0x0878:0x1101 (systec_can)
# device number 01, first CAN channel -> can10
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="systec_can", \
ATTR{address}=="??:??:??:??:01:00", KERNEL=="can*", NAME="can10"

# USB device 0x0878:0x1101 (systec_can)
# device number 01, second CAN channel -> can11
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="systec_can", \
ATTR{address}=="??:??:??:??:01:01", KERNEL=="can*", NAME="can11"

# USB device 0x0878:0x1101 (systec_can)
# device connected at USB port 3-1:1.0, first CAN channel -> can20
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="systec_can", KERNELS=="3-1:1.0", \
ATTR{address}=="??:??:??:??:??:00", KERNEL=="can*", NAME="can20"

# USB device 0x0878:0x1101 (systec_can)
# device connected at USB port 3-1:1.0, second CAN channel -> can21
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="systec_can", KERNELS=="3-1:1.0", \
ATTR{address}=="??:??:??:??:??:01", KERNEL=="can*", NAME="can21"

# USB device 0x0878:0x1101 (systec_can)
# only set the timeout on dual channel devices
ACTION=="add", SUBSYSTEM=="net", DRIVERS=="systec_can", \
ATTRS{dual_channel}=="1", ATTR{tx_timeout_ms}="1000"
```

## Further information

* CAN utilities

    <http://github.com/linux-can/can-utils/>

* Linux Kernel Source Code Documentation/networking/can.txt

    <http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=blob;f=Documentation/networking/can.txt;hb=HEAD>

* Talk about SocketCAN - CAN Driver Interface under Linux
    (German, but slides in English)

    <http://chemnitzer.linux-tage.de/2012/vortraege/1044>

* libsocketcan V0.0.9
    Helper library for CAN interface configuration (e.g. bitrate)
    over netlink API.

    <http://www.pengutronix.de/software/libsocketcan/download/>
