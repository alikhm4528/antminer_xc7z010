# Global Variables
PROJECT_NAME=base

# Directory Paths
XILINX_DIR=$(HOME)/Xilinx
PETALINUX_DIR=$(XILINX_DIR)/Petalinux
VIVADO_BIN_DIR=$(XILINX_DIR)/2019.2/bin
WORKSPACE_DIR=$(PWD)/workspace
BUILD_DIR=$(WORKSPACE_DIR)/build
VIVADO_BUILD_DIR=$(BUILD_DIR)/vivado

# TCL Paths
BASE_TCL_PATH=$(PWD)/scripts/base.tcl
BUILD_TCL_PATH=$(PWD)/scripts/build.tcl

add_vivado_to_path:
	PATH=$(PATH):$(VIVADO_BIN_DIR)

source_petalinux_env:
	. $(PETALINUX_DIR)/settings.sh

petalinux_build: source_petalinux_env
	echo $(PATH)

petalinux_clean:


vivado_build: vivado_clean add_vivado_to_path
	mkdir -p $(BUILD_DIR)/platform
	mkdir -p $(BUILD_DIR)/vivado
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
