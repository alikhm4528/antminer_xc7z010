# Antminer xc7z010
This is a template vivado and petalinux project for antimner xc7z010

**Note:** note that this project was tested for Xilinx Vivado 2019.2 and Petalinux 2019.2

# Build
## Vivado
To create vivado project and open the gui use the following command
```
make create_vivado_project
```

To build vivado project in batch mode and generate xsa file in workspace/build/platform use the following command
```
make vivado_build
```
## Petalinux
To build petalinux use the following command
```
make petalinux_build
```

To run qemu simulation for generated petalinux image use the following command
```
make petalinux_qemu
```

## Vitis
To build vitis project use the following command
```
make vitis_build
```
The resulting images will be copied into workspace/build/images

# Make and Build an Example
## Make
First of all to make an example, make a subdir in examples directory
```
mkdir examples/<example-name>
```
Then make a similar structure to other examples. Use template tcl file (use other examples') and write one for your example and name it `<example-name>.tcl`. Then put it in `<example-name>/scripts` directory.

## Build
To build the example or open vivado projects use the following commands
```
make create_vivado_project EXAMPLE=<example-name> # or
make vivado_build EXAMPLE=<example-name> # or
make vitis_build EXAMPLE=<example_name>
```

# Xilinx Open Source Linux
To build linux without using petalinux, you have to build components separately.
## Generating device tree
To generate a template device tree based on xsa file go through the following procedure.

First clone device tree generator plugin. 
```
git clone https://github.com/Xilinx/device-tree-xlnx.git
```

Do not forget to checkout to the appropriate Xilinx version installed on your computer.
```
git checkout xilinx-v2019.2
```

Then run the following command.
```
make generate_device_tree EXAMPLE=<example-name>
```

This will result `devicetree.dts` and `devicetree.dtb` files in `workspace/build/image/<example-name>/linux` path. 

## Building u-boot and linux kernel
You can use the prebuilt Linux kernel (`uImage`) from the `prebuilt` directory unless you need to add or remove drivers or kernel modules. Since the device tree and bitstream are not involved in the Linux kernel build process, using the prebuilt kernel will work without any issues.

The same applies to u-boot (secondary bootloader). You can simply replace `devicetree.dtb` and the bitstream in `prebuilt` directory, and everything should work fine unless you require additional hardware support during the boot process.

### Building u-boot
To build u-boot go through the following procedure.

First clone u-boot repository.
```
git clone https://github.com/Xilinx/u-boot-xlnx.git
```

Do not forget to checkout to the appropriate Xilinx version installed on your computer.
```
git checkout xilinx-v2019.2
```

Then copy config files and device tree into the project and add two lines to the makefile.

```
u-boot-xlnx/
|
+-- arch/
|	|
| 	+-- arm/
|		|
| 		+-- dts/
|			|
|			+-- antminer.dts
|			+-- Makefile
|				|dtb-$(CONFIG_ARCH_ZYNQ) += \
|				|    antminer.dtb
|	 			`----
|
+-- configs/
|	|
|	+-- xilinx_antminer_defconfig
|	|		|CONFIG_DEFAULT_DEVICETREE="antminer"
|	|		|CONFIG_SYS_CONFIG_NAME="antminer"
|	|		`----
|
+-- include/
	|
 	+-- conf/
		|
		+-- antminer.h
```

Then just build it.
```
export PATH=$PATH:<vitis-install-dir>/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make distclean
make xilinx_antminer_defconfig
make -j$(nproc)
```

You can do additionall configs using the following commands.
```
make menuconfig
```

### Building Linux Kernel
To build linux kernel go through the following procedure.

First clone kernel repository.
```
git clone https://github.com/Xilinx/linux-xlnx.git
```

Do not forget to checkout to the appropriate Xilinx version installed on your computer.
```
git checkout xilinx-v2019.2
```

Then just build it.
```
export PATH=$PATH:<vitis-install-dir>/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make ARCH=arm xilinx_zynq_defconfig
make LOADADDR=0x8000 uImage -j$(nproc)
```

You can do additionall configs using the following commands.
```
make ARCH=arm menuconfig
```

## Building Rootfs
To build the rootfs go through the following procedure.

First extract template rootfs (`prebuilt/rootfs.cpio.gz`) using the following command.
```
make extract_rootfs
```

Then you can modify the `workspace/build/rootfs`. After that just build rootfs.
```
make build_rootfs
```

This command will create `uRamdisk` and `rootfs.cpio.gz` files on `workspace/build/images/rootfs` path.

## Create Linux Package
Finally after you prepared everything, simply use the following command to create linux package and necessary files in `workspace/build/images/<example-dir>/linux/boot`
```
make create_linux_package EXAMPLE=<example-name> ROOTFS=<ramdisk or sddisk>
```

If you use the ramdisk option, the root filesystem will be loaded into ram during boot, and any changes will be lost after reboot. However, if you use the sddisk option, the root filesystem will reside on the second partition of the SD card.

# XVC-Pico
Here is the link to the pico jtag programmer projects
```
https://github.com/kholia/xvc-pico
```
and pico-sdk
```
https://github.com/raspberrypi/pico-sdk
```

# Xilinx Usefull links
* [Xilinx Embedded Software](https://github.com/Xilinx/embeddedsw/tree/master)

# Troubleshoots
* change `XILINX_DIR` and `PETALINUX_DIR` variables in Makefile
* change ip versions in scripts/base.tcl for other vivado versions
* change `CONFIG_PRE_MIRROR_URL` and `CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL` in configs/project-spec/configs/config to your appropriate address 
