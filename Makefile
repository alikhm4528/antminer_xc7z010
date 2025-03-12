# Global Variables
PROJECT_NAME=base

# Directory Paths
XILINX_DIR=$(HOME)/Xilinx
PETALINUX_DIR=$(XILINX_DIR)/Petalinux
VIVADO_BIN_DIR=$(XILINX_DIR)/2019.2/bin

WORKSPACE_DIR=$(PWD)/workspace
BUILD_DIR=$(WORKSPACE_DIR)/build
PLATFORM_DIR=$(BUILD_DIR)/platform
VIVADO_BUILD_DIR=$(BUILD_DIR)/vivado
PETALINUX_BUILD_DIR=$(BUILD_DIR)/petalinux
PETALINUX_PROJECT_NAME=ax_peta
PETALINUX_PROJECT_DIR=$(PETALINUX_BUILD_DIR)/$(PETALINUX_PROJECT_NAME)

# TCL Paths
BASE_TCL_PATH=$(PWD)/scripts/base.tcl
BUILD_TCL_PATH=$(PWD)/scripts/build.tcl

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
	@cd $(PETALINUX_PROJECT_DIR) && \
	. $(PETALINUX_DIR)/settings.sh &> /dev/null && \
	petalinux-config --silentconfig --get-hw-description $(PLATFORM_DIR)
	@echo "********* Info: config hardware done *********"

petalinux_replace_configs:
	cp -rf $(PWD)/configs/* $(PETALINUX_PROJECT_DIR)
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
	vivado -mode batch -log $(VIVADO_BUILD_DIR)/vivado.log \
		-journal $(VIVADO_BUILD_DIR)/vivado.jou \
		-source $(BUILD_TCL_PATH) -tclargs --project_name $(PROJECT_NAME) \
		--origin_dir $(PWD)

vivado_clean:
	rm -rf $(VIVADO_BUILD_DIR)

create_vivado_project: vivado_clean add_vivado_to_path
	mkdir -p $(VIVADO_BUILD_DIR)
	cd $(VIVADO_BUILD_DIR)
	vivado -mode gui -log $(VIVADO_BUILD_DIR)/vivado.log \
		-journal $(VIVADO_BUILD_DIR)/vivado.jou \
		-source $(BASE_TCL_PATH) -tclargs --origin_dir $(PWD)
