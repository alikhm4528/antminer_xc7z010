# Just add tool names

TOOLS= \
	fpgautil

WORKSPACE_DIR=
TOOLS_BUILD_DIR=$(WORKSPACE_DIR)/build/tools

all: build_dir_clean
	mkdir -p $(TOOLS_BUILD_DIR)
	@$(foreach f, $(TOOLS), $(MAKE) -C $(f) all PROJ=$(f); \
		cp -f $(f)/$(f).elf $(TOOLS_BUILD_DIR)/$(f))

build_dir_clean:
	rm -rf $(TOOLS_BUILD_DIR)

clean:
	@$(foreach f, $(TOOLS), $(MAKE) -C $(f) clean PROJ=$(f);)
