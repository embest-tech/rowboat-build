# Component Path Configuration
export TARGET_PRODUCT
export ANDROID_INSTALL_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../..
export ANDROID_FS_DIR := $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/android_rootfs

kernel_not_configured := $(wildcard kernel/.config)

ifeq ($(TARGET_PRODUCT), ti814xevm)
export SYSLINK_VARIANT_NAME := TI814X
rowboat: droid sgx kernel_modules
droid:   build_kernel install_mc_dsp
else
ifeq ($(TARGET_PRODUCT), ti816xevm)
export SYSLINK_VARIANT_NAME := TI816X
rowboat: droid sgx kernel_modules
droid:   build_kernel install_mc_dsp
else
ifeq ($(TARGET_PRODUCT), omap3evm)
rowboat: sgx wl12xx_compat
else
ifneq ($(TARGET_PRODUCT), am1808evm)
rowboat: sgx
else 
rowboat: build_kernel
endif
endif
endif
endif


build_kernel:
	@echo "in kernel rule"
ifeq ($(strip $(kernel_not_configured)),)
ifeq ($(TARGET_PRODUCT), beagleboard)
	$(MAKE) -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), omap3evm)
	$(MAKE) -C kernel ARCH=arm omap3_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), igepv2)
	$(MAKE) -C kernel ARCH=arm igep0020_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), am3517evm)
	$(MAKE) -C kernel ARCH=arm am3517_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), ti814xevm)
	$(MAKE) -C kernel ARCH=arm ti8148_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), ti816xevm)
	$(MAKE) -C kernel ARCH=arm ti8168_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), am1808evm)
	$(MAKE) -C kernel ARCH=arm ti8168_evm_android_defconfig #TBD
endif
ifeq ($(TARGET_PRODUCT), am45xevm)
	$(MAKE) -C kernel ARCH=arm am4530_evm_android_defconfig
endif
endif
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) uImage

sgx: build_kernel droid
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) 
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) install

wl12xx_compat: build_kernel
	$(MAKE) -C hardware/ti/wlan/WL1271_compat ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) ARCH=arm install

# Build VPSS / HDMI modules
kernel_modules:	build_kernel
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) modules
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) INSTALL_MOD_PATH=$(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/ modules_install
	
# Install Media Controller / DSP Software Components for TI81xx
install_mc_dsp: hardware/ti/ti81xx/.mc_dsp_components_installed
hardware/ti/ti81xx/.mc_dsp_components_installed:
	(cd hardware/ti/ti81xx; ./install_mc_dsp_components.sh)

# Make a tarball for the filesystem
fs_tarball: 
	rm -rf $(ANDROID_FS_DIR)
	mkdir $(ANDROID_FS_DIR)	
	cp -r $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/root/* $(ANDROID_FS_DIR)
	cp -r $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/ $(ANDROID_FS_DIR)
	(cd $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT); \
	 ../../../../build/tools/mktarball.sh ../../../host/linux-x86/bin/fs_get_stats android_rootfs . rootfs rootfs.tar.bz2)

kernel_clean:
	$(MAKE) -C kernel ARCH=arm clean
	rm kernel/.config

sgx_clean: 
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) clean

# Remove filesystem
fs_clean:
	rm -rf $(ANDROID_FS_DIR)
	rm -f $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/rootfs.tar.bz2

rowboat_clean: clean sgx_clean kernel_clean fs_clean
