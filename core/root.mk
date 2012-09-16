# Component Path Configuration
export TARGET_PRODUCT
export ANDROID_INSTALL_DIR := $(patsubst %/,%, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
export ANDROID_FS_DIR := $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/android_rootfs
export PATH :=$(PATH):$(ANDROID_INSTALL_DIR)/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin

kernel_not_configured := $(wildcard kernel/.config)

ifeq ($(TARGET_PRODUCT), am335xevm_sk)
rowboat: sgx
CLEAN_RULE = sgx_clean kernel_clean clean
else
ifeq ($(TARGET_PRODUCT), beaglebone)
rowboat: sgx
CLEAN_RULE = sgx_clean kernel_clean clean
else
ifeq ($(TARGET_PRODUCT), am335xevm)
rowboat: sgx wl12xx_compat
CLEAN_RULE = sgx_clean wl12xx_compat_clean kernel_clean clean
else
ifeq ($(TARGET_PRODUCT), beagleboard)
rowboat: sgx
CLEAN_RULE = sgx_clean kernel_clean clean
else
ifeq ($(TARGET_PRODUCT), omap3evm)
rowboat: sgx
CLEAN_RULE = sgx_clean kernel_clean clean
else
rowboat: kernel_build
endif
endif
endif
endif
endif

kernel_build: droid
ifeq ($(strip $(kernel_not_configured)),)
ifeq ($(TARGET_PRODUCT), am335xevm_sk)
	$(MAKE) -C kernel ARCH=arm am335x_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), beaglebone)
	$(MAKE) -C kernel ARCH=arm am335x_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), am335xevm)
	$(MAKE) -C kernel ARCH=arm am335x_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), beagleboard)
	$(MAKE) -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), omap3evm)
	$(MAKE) -C kernel ARCH=arm omap3_evm_android_defconfig
endif
endif
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=arm-eabi- uImage

kernel_clean:
	$(MAKE) -C kernel ARCH=arm  distclean

### DO NOT EDIT THIS FILE ###
include build/core/main.mk
### DO NOT EDIT THIS FILE ###

sgx: kernel_build
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR)
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) install

sgx_clean:
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) clean

wl12xx_compat: kernel_build
	$(MAKE) -C hardware/ti/wlan/mac80211/compat_wl12xx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) CROSS_COMPILE=arm-eabi- ARCH=arm install

wl12xx_compat_clean:
	$(MAKE) -C hardware/ti/wlan/mac80211/compat_wl12xx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) CROSS_COMPILE=arm-eabi- ARCH=arm clean

u-boot_build:
ifeq ($(TARGET_PRODUCT), beaglebone)
	$(MAKE) -C u-boot ARCH=arm am335x_evm_config
endif
ifeq ($(TARGET_PRODUCT), am335xevm)
	$(MAKE) -C u-boot ARCH=arm am335x_evm_config
endif
	$(MAKE) -C u-boot ARCH=arm CROSS_COMPILE=arm-eabi-

u-boot_clean:
	$(MAKE) -C u-boot ARCH=arm CROSS_COMPILE=arm-eabi- distclean

# Make a tarball for the filesystem
fs_tarball:
	rm -rf $(ANDROID_FS_DIR)
	mkdir $(ANDROID_FS_DIR)
	cp -r $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/root/* $(ANDROID_FS_DIR)
	cp -r $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/ $(ANDROID_FS_DIR)
	(cd $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT); \
	 ../../../../build/tools/mktarball.sh ../../../host/linux-x86/bin/fs_get_stats android_rootfs . rootfs rootfs.tar.bz2)

rowboat_clean: $(CLEAN_RULE)
