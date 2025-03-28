# Global Variables
PROJECT_NAME=base

# Directory Paths
XILINX_DIR=$(HOME)/Xilinx
PETALINUX_DIR=$(XILINX_DIR)/Petalinux
VIVADO_BIN_DIR=$(XILINX_DIR)/2019.2/bin
DEVICE_TREE_GEN_DIR=$(XILINX_DIR)/device-tree-xlnx

WORKSPACE_DIR=$(PWD)/workspace
BUILD_DIR=$(WORKSPACE_DIR)/build
PLATFORM_DIR=$(BUILD_DIR)/platform
VIVADO_BUILD_DIR=$(BUILD_DIR)/vivado

PETALINUX_BUILD_DIR=$(BUILD_DIR)/petalinux
PETALINUX_PROJECT_NAME=ax_peta
PETALINUX_PROJECT_DIR=$(PETALINUX_BUILD_DIR)/$(PETALINUX_PROJECT_NAME)

VITIS_BUILD_DIR=$(BUILD_DIR)/vitis
DT_BUILD_DIR=$(BUILD_DIR)/device_tree
IMAGES_DIR=$(BUILD_DIR)/images

# Device Tree Gen
FSBL_PATH=$(DT_BUILD_DIR)/device_tree_plat/export/device_tree_plat/sw/device_tree_plat/boot
DT_PATH=$(DT_BUILD_DIR)/device_tree_plat/ps7_cortexa9_0/device_tree_domain/bsp
BITSTREAM_PATH=$(DT_BUILD_DIR)/device_tree_plat/hw

# TCL Paths
PROJECT_TCL_PATH=$(PWD)/scripts/base.tcl
BUILD_TCL_PATH=$(PWD)/scripts/build.tcl
VITIS_TCL_PATH=$(PWD)/scripts/vitis_build.tcl
DTG_TCL_PATH=$(PWD)/scripts/dtg.tcl

EXAMPLE=
EXAMPLE_DIR=
EXAMPLE_SRC_DIR=$(PWD)/src/application

# choose between ramdisk and sddisk
ROOTFS=ramdisk

ifneq ($(EXAMPLE),)
	PROJECT_NAME=$(EXAMPLE)
	EXAMPLE_DIR=$(PWD)/examples/$(EXAMPLE)
	PROJECT_TCL_PATH=$(EXAMPLE_DIR)/scripts/$(EXAMPLE).tcl
	EXAMPLE_SRC_DIR=$(EXAMPLE_DIR)/src
endif

add_vivado_to_path:
	PATH=$(PATH):$(VIVADO_BIN_DIR)

check_xsa_file_exists:
	@if [ ! -f "$(PLATFORM_DIR)/$(PROJECT_NAME).xsa" ]; then \
		echo "Error: There is no xsa file in $(PLATFORM_DIR)"; \
		exit 1; \
	fi

# Petalinux Steps ------------------------------
petalinux_create_project:
	@cd $(PETALINUX_BUILD_DIR) && \
	. $(PETALINUX_DIR)/settings.sh &> /dev/null && \
	petalinux-create --type project --template zynq \
		--name $(PETALINUX_PROJECT_NAME)
	@echo "********* Info: project created *********"

petalinux_config_hw:
	rm -rf $(PLATFORM_DIR)/tmp
	mkdir -p $(PLATFORM_DIR)/tmp/
	cp $(PLATFORM_DIR)/$(PROJECT_NAME).xsa $(PLATFORM_DIR)/tmp/system.xsa
	@cd $(PETALINUX_PROJECT_DIR) && \
	. $(PETALINUX_DIR)/settings.sh &> /dev/null && \
	petalinux-config --silentconfig --get-hw-description $(PLATFORM_DIR)/tmp
	@echo "********* Info: config hardware done *********"

petalinux_replace_configs:
	cp -rf $(PWD)/configs/project-spec/* $(PETALINUX_PROJECT_DIR)/project-spec
	@echo "********* Info: replace configs done *********"
# Petalinux Steps ------------------------------

petalinux_build: check_xsa_file_exists petalinux_clean petalinux_create_dir petalinux_create_project petalinux_config_hw petalinux_replace_configs
	@cd $(PETALINUX_PROJECT_DIR) && \
	. $(PETALINUX_DIR)/settings.sh &> /dev/null && \
	petalinux-build && \
	petalinux-package --boot --fsbl \
		$(PETALINUX_PROJECT_DIR)/images/linux/zynq_fsbl.elf \
		--fpga $(PETALINUX_PROJECT_DIR)/images/linux/system.bit --u-boot
	@echo "********* Info: petalinux build done *********"

petalinux_prebuild:
	@cd $(PETALINUX_PROJECT_DIR) && \
	. $(PETALINUX_DIR)/settings.sh &> /dev/null && \
	petalinux-package --prebuilt --fpga images/linux/system.bit

petalinux_qemu: petalinux_prebuild
	@cd $(PETALINUX_PROJECT_DIR) && \
	. $(PETALINUX_DIR)/settings.sh &> /dev/null && \
	petalinux-boot --qemu --prebuilt 3

petalinux_create_dir:
	mkdir -p $(PLATFORM_DIR)
	mkdir -p $(PETALINUX_BUILD_DIR)

petalinux_clean:
	rm -rf $(PETALINUX_BUILD_DIR)

vivado_build: vivado_clean add_vivado_to_path
	mkdir -p $(PLATFORM_DIR)
	mkdir -p $(VIVADO_BUILD_DIR)
	@if [ -z "$(EXAMPLE)" ]; then \
		vivado -mode batch -log $(VIVADO_BUILD_DIR)/vivado.log \
			-journal $(VIVADO_BUILD_DIR)/vivado.jou \
			-source $(BUILD_TCL_PATH) -tclargs --project_name $(PROJECT_NAME) \
			--origin_dir $(PWD) --base_script $(PROJECT_TCL_PATH); \
	else \
		vivado -mode batch -log $(VIVADO_BUILD_DIR)/vivado.log \
			-journal $(VIVADO_BUILD_DIR)/vivado.jou \
			-source $(BUILD_TCL_PATH) -tclargs --project_name $(PROJECT_NAME) \
			--origin_dir $(PWD) --base_script $(PROJECT_TCL_PATH) \
			--example_dir $(EXAMPLE_DIR); \
	fi

platform_clean:
	rm -rf $(PLATFORM_DIR)

vivado_clean:
	rm -rf $(VIVADO_BUILD_DIR)

create_vivado_project: vivado_clean add_vivado_to_path
	mkdir -p $(VIVADO_BUILD_DIR)
	@if [ -z "$(EXAMPLE)" ]; then \
		vivado -mode gui -log $(VIVADO_BUILD_DIR)/vivado.log \
			-journal $(VIVADO_BUILD_DIR)/vivado.jou \
			-source $(PROJECT_TCL_PATH) \
			-tclargs --origin_dir $(PWD) \
			--project_name $(PROJECT_NAME); \
	else \
		vivado -mode gui -log $(VIVADO_BUILD_DIR)/vivado.log \
			-journal $(VIVADO_BUILD_DIR)/vivado.jou \
			-source $(PROJECT_TCL_PATH) \
			-tclargs --origin_dir $(PWD) \
			--project_name $(PROJECT_NAME) \
			--example_dir $(EXAMPLE_DIR); \
	fi

vitis_build: vitis_clean
	mkdir -p $(VITIS_BUILD_DIR)
	xsct $(VITIS_TCL_PATH) -tclargs \
	 	--src $(EXAMPLE_SRC_DIR) \
		--hw $(PLATFORM_DIR)/$(PROJECT_NAME).xsa \
		--workspace $(VITIS_BUILD_DIR) \
		--project_name $(PROJECT_NAME)
	mkdir -p $(IMAGES_DIR)/$(PROJECT_NAME)
	cp -f $(VITIS_BUILD_DIR)/$(PROJECT_NAME)_system/Debug/sd_card/BOOT.BIN \
		$(IMAGES_DIR)/$(PROJECT_NAME)
	cp -f $(VITIS_BUILD_DIR)/$(PROJECT_NAME)/Debug/$(PROJECT_NAME).elf \
		$(IMAGES_DIR)/$(PROJECT_NAME)

vitis_clean:
	rm -rf $(VITIS_BUILD_DIR)

generate_device_tree: add_vivado_to_path device_tree_clean
	mkdir -p $(DT_BUILD_DIR)
	xsct $(DTG_TCL_PATH) -tclargs \
	 	--dt_dir $(DEVICE_TREE_GEN_DIR) \
		--hw $(PLATFORM_DIR)/$(PROJECT_NAME).xsa \
		--workspace $(DT_BUILD_DIR) \
		--project_name $(PROJECT_NAME)
	mkdir -p $(IMAGES_DIR)/$(PROJECT_NAME)/linux
	cp -f $(FSBL_PATH)/fsbl.elf \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux
	cp -f $(DT_PATH)/system-top.dts $(DT_PATH)/*.dtsi \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux
	cp -f $(BITSTREAM_PATH)/$(PROJECT_NAME).bit \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux/system.bit
	# flatten device tree
	@cd $(IMAGES_DIR)/$(PROJECT_NAME)/linux && \
	gcc -I my_dts -E -nostdinc -undef -D__DTS__ \
		-x assembler-with-cpp -o devicetree.dts system-top.dts && \
	dtc -I dts -O dtb -o devicetree.dtb devicetree.dts

create_linux_package: boot_clean
	mkdir -p $(IMAGES_DIR)/$(PROJECT_NAME)/linux/boot
	# copy bif and u-boot script
	cp -f $(PWD)/scripts/boot.bif \
		$(PWD)/prebuilt/u-boot.elf \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux
	# create BOOT.bin
	@cd $(IMAGES_DIR)/$(PROJECT_NAME)/linux && \
	bootgen -image boot.bif -arch zynq -o BOOT.bin -w
	# copy kernel image
	cp -f $(PWD)/prebuilt/uImage \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux/BOOT.bin \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux/devicetree.dtb \
		$(IMAGES_DIR)/$(PROJECT_NAME)/linux/boot
	@if [ "$(ROOTFS)" = "ramdisk" ]; then \
		echo "Copying Ramdisk into boot" && \
		cp -f $(BUILD_DIR)/images/rootfs/uRamdisk \
			$(PWD)/scripts/ramdisk/uEnv.txt \
			$(IMAGES_DIR)/$(PROJECT_NAME)/linux/boot; \
	else \
		cp -f $(PWD)/scripts/sddisk/uEnv.txt \
			$(IMAGES_DIR)/$(PROJECT_NAME)/linux/boot; \
	fi

boot_clean:
	rm -rf $(IMAGES_DIR)/$(PROJECT_NAME)/linux/boot

device_tree_clean:
	rm -rf $(DT_BUILD_DIR)

extract_rootfs: rootfs_clean
	mkdir -p $(BUILD_DIR)/rootfs
	cd $(BUILD_DIR)/rootfs && \
	gunzip -c $(PWD)/prebuilt/rootfs.cpio.gz | cpio -idmv

build_rootfs: rootfs_image_clean
	mkdir -p $(BUILD_DIR)/images/rootfs
	cd $(BUILD_DIR)/rootfs && \
	fakeroot sh -c 'chown -R 0:0 . && \
		find . | cpio -o -H newc | gzip > \
		$(BUILD_DIR)/images/rootfs/rootfs.cpio.gz'
	cd $(BUILD_DIR)/images/rootfs && \
	mkimage -A arm -O linux -T ramdisk -C gzip -d rootfs.cpio.gz uRamdisk

rootfs_clean:
	rm -rf $(BUILD_DIR)/rootfs

rootfs_image_clean:
	rm -rf $(BUILD_DIR)/images/rootfs
