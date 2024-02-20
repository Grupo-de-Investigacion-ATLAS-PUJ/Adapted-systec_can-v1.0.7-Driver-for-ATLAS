# V1.0.7_ATLAS_DIST
* Support for AlmaLinux 9.3 (kernel 5.14.0-362.18.1.el9_3.x86_64)
* Remove CAN LED support (Some CAN devices might not have LED support, depending on th efirmware of it)

# v1.0.7
* Support Linux kernel 5.19 and newer (remove CAN LED support)

# v1.0.6
* Fix CI for Arch Linux and newer versions of DKMS
* Support Linux kernel 5.17 and newer

# v1.0.5
* Update CI, new Ubuntu version, fixes creation of release archive

# v1.0.4
* Support Linux kernel 5.13 and newer (like it is used in ArchLinux)

# v1.0.3
* Support Linux kernel 5.12 and newer (like it is used in ArchLinux)

# v1.0.2
* Support Linux kernel 5.11 and newer (like it is used in Ubuntu 21.04)

# v1.0.1
* Fix unexpected behavior, which caused the use of the wrong bitrate for a device.

# v1.0.0
* Add support for specific baudrate settings for generation 4 modules.
* Add support for high-performance mode (+25% clock speed).
* Add DKMS support.
* Change to BUS-OFF handling: remove dependency on internals of can_dev.ko.
  Instead use can_bus_off() function.

# v0.9.10
* Add known issue regarding rare, but possible out-of-ordering issue on SMP systems
* Make KDIR overwriteable upon make call
* Split documentation and changelog into separate markdown files
* Fix sending CAN frames in a very fast manner (queue stalled until a new
  CAN frame had been queued)

# v0.9.9
* Update firmware files for PIDs 0x1121, 0x1122, 0x1123, 0x1125
* New feature for PIDs 0x1121, 0x1122, 0x1123, 0x1125: **one-shot mode**<br>
  No automatic retransmit of CAN message if Acknowledge error occurs
  (no other device on bus)

# v0.9.8
* Update firmware files for PIDs 0x1121, 0x1122, 0x1123, 0x1125

# v0.9.7
* Update firmware files for PIDs 0x1121, 0x1122, 0x1123, 0x1125

# v0.9.6
* Update firmware files for PIDs 0x1121, 0x1122, 0x1123, 0x1125

# v0.9.5
* Use devm_kzalloc rather than devm_kmalloc to support kernels < v3.13
* Add support for PID 0x1123 and 0x1125
* Update firmware files to version 5.14

# v0.9.4
* Fix potential use after free
* Add LED trigger support<br>
  This also workarounds a problem of linux 3.9-3.15 if interfaces are renamed
  e.g. by using udev rules
* Do not use stack memory for URB transfers, it is not DMA capable

# v0.9.3
* Fix compilation for >= linux 4.8
* Do not open-code msecs_to_jiffies()

# v0.9.2
* Removed obsolete support for PID 0x1144 and 0x1162
* Updates firmware files to version 5.13
* Fix compilation for >= linux 4.7

# v0.9.1
* Update firmware files
* Add support for PID 0x1162

# v0.9
* Added support of bootloader update
  * required for newer firmware versions
  * bootloader files from /lib/firmware/ are used
  * only update is done, no downgrade
* Loosen the driver <-> firmware coupling
  * firmware on modules is updated/downgraded to the firmware files located
    in /lib/firmware/
  * firmware file names have changed: version number removed from name
* Added support for kernels up to 3.18
* Fix a kernel warning upon interface startup
