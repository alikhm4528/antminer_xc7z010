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

# XVC-Pico
Here is the link to the pico jtag programmer projects
```
https://github.com/kholia/xvc-pico
```
and pico-sdk
```
https://github.com/raspberrypi/pico-sdk
```

# Troubleshoots
* change `XILINX_DIR` and `PETALINUX_DIR` variables in Makefile
* change ip versions in scripts/base.tcl for other vivado versions
* change `CONFIG_PRE_MIRROR_URL` and `CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL` in configs/project-spec/configs/config to your appropriate address 
