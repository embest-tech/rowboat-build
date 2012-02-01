# Component Path Configuration
export TARGET_PRODUCT
export ANDROID_INSTALL_DIR := $(patsubst %/,%, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
export ANDROID_FS_DIR := $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/android_rootfs

kernel_not_configured := $(wildcard kernel/.config)

ifeq ($(TARGET_PRODUCT), omap3evm)
rowboat: sgx
CLEAN_RULE = sgx_clean kernel_clean clean
else
ifeq ($(TARGET_PRODUCT), beagleboard)
rowboat: sgx
CLEAN_RULE = sgx_clean kernel_clean clean
else
rowboat: kernel_build
endif
endif

kernel_build: droid
ifeq ($(strip $(kernel_not_configured)),)
ifeq ($(TARGET_PRODUCT), omap3evm)
	$(MAKE) -C kernel ARCH=arm omap3_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), beagleboard)
	$(MAKE) -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
endif
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) uImage

kernel_clean:
	$(MAKE) -C kernel ARCH=arm  distclean

### DO NOT EDIT THIS FILE ###
include build/core/main.mk
### DO NOT EDIT THIS FILE ###

sgx: kernel_build
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX)
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) install

sgx_clean:
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) clean


# Make a tarball for the filesystem
fs_tarball:
	rm -rf $(ANDROID_FS_DIR)
	mkdir $(ANDROID_FS_DIR)
	cp -r $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/root/* $(ANDROID_FS_DIR)
	cp -r $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/ $(ANDROID_FS_DIR)
	(cd $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT); \
	 ../../../../build/tools/mktarball.sh ../../../host/linux-x86/bin/fs_get_stats android_rootfs . rootfs rootfs.tar.bz2)

rowboat_clean: $(CLEAN_RULE)
