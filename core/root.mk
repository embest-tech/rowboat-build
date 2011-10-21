# Component Path Configuration
export TARGET_PRODUCT
export ANDROID_INSTALL_DIR := $(patsubst %/,%, $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
export ANDROID_FS_DIR := $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/android_rootfs
export SYSLINK_INSTALL_DIR := $(ANDROID_INSTALL_DIR)/hardware/ti/ti81xx/syslink_vpss/syslink_2_00_00_78
export IPC_INSTALL_DIR := $(ANDROID_INSTALL_DIR)/hardware/ti/ti81xx/syslink_vpss/ipc_1_23_01_26
export IPC_DIR := $(ANDROID_INSTALL_DIR)/hardware/ti/ti81xx/syslink_vpss/ipc_1_23_01_26

kernel_not_configured := $(wildcard kernel/.config)

ifeq ($(TARGET_PRODUCT), ti814xevm)
export SYSLINK_VARIANT_NAME := TI814X
rowboat: sgx
else
ifeq ($(TARGET_PRODUCT), ti816xevm)
export SYSLINK_VARIANT_NAME := TI816X
rowboat: sgx
else
ifeq ($(TARGET_PRODUCT), omap3evm)
rowboat: sgx wl12xx_compat
else
ifeq ($(TARGET_PRODUCT), flashboard)
rowboat: sgx wl12xx_compat
else
ifeq ($(TARGET_PRODUCT), am335xevm)
rowboat: sgx wl12xx_compat am335xevm_modules
else
ifeq ($(TARGET_PRODUCT), beaglebone)
rowboat: sgx beaglebone_modules
else
ifneq ($(TARGET_PRODUCT), am1808evm)
rowboat: sgx
else 
rowboat: build_kernel
endif
endif
endif
endif
endif
endif
endif

### DO NOT EDIT THIS FILE ###
include build/core/main.mk
### DO NOT EDIT THIS FILE ###

build_kernel: droid
	@echo "in kernel rule"
ifeq ($(strip $(kernel_not_configured)),)
ifeq ($(TARGET_PRODUCT), beagleboard)
	$(MAKE) -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), omap3evm)
	$(MAKE) -C kernel ARCH=arm omap3_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), flashboard)
	$(MAKE) -C kernel ARCH=arm flashboard_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), igepv2)
	$(MAKE) -C kernel ARCH=arm igep0020_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), am3517evm)
	$(MAKE) -C kernel ARCH=arm am3517_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), am3517crane)
	$(MAKE) -C kernel ARCH=arm am3517_crane_android_defconfig
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
ifeq ($(TARGET_PRODUCT), am335xevm)
	$(MAKE) -C kernel ARCH=arm am335x_evm_android_defconfig
endif

ifeq ($(TARGET_PRODUCT), beaglebone)
	$(MAKE) -C kernel ARCH=arm beaglebone_android_defconfig
endif

ifeq ($(TARGET_PRODUCT), overo)
	$(MAKE) -C kernel ARCH=arm overo_android_defconfig
endif
endif
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) uImage
ifeq ($(TARGET_PRODUCT), igepv2)
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) modules
	$(MAKE) -f device/ti/$(TARGET_PRODUCT)/AndroidKernel.mk
endif

ifeq ($(TARGET_PRODUCT),ti816xevm)
sgx: build_kernel kernel_modules
else
ifeq ($(TARGET_PRDUCT),ti814xevm)
sgx: build_kernel kernel_modules
else
sgx: build_kernel
endif
endif
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) 
	$(MAKE) -C hardware/ti/sgx ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) install

wl12xx_compat: build_kernel
	$(MAKE) -C hardware/ti/wlan/WL1271_compat/drivers ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) ARCH=arm install

am335xevm_modules: build_kernel
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) modules
	$(MAKE) -f device/ti/$(TARGET_PRODUCT)/AndroidKernel.mk

beaglebone_modules: build_kernel
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) modules
	$(MAKE) -f device/ti/$(TARGET_PRODUCT)/AndroidKernel.mk

# Build Syslink
syslink:
	$(MAKE) -C $(SYSLINK_INSTALL_DIR) clean

	$(MAKE) -C $(SYSLINK_INSTALL_DIR) ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) syslink_driver
	$(MAKE) -C $(SYSLINK_INSTALL_DIR) ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) syslink_hlos

	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/packages/ti/syslink/samples/hlos/common/usr/Linux/ ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR)/packages IPC_DIR=$(IPC_INSTALL_DIR)/packages  SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME) clean

	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/packages/ti/syslink/samples/hlos/common/usr/Linux/ ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR)/packages IPC_DIR=$(IPC_INSTALL_DIR)/packages SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME)

	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/packages/ti/syslink/samples/hlos/slaveLoader/usr/Linux ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR)/packages IPC_DIR=$(IPC_INSTALL_DIR)/packages SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME)  clean

	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/packages/ti/syslink/samples/hlos/slaveLoader/usr/Linux ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR)/packages IPC_DIR=$(IPC_INSTALL_DIR)/packages SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME)

	cp -r $(ANDROID_INSTALL_DIR)/device/ti/$(TARGET_PRODUCT)/syslink $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/bin

	cp -r $(SYSLINK_INSTALL_DIR)/packages/ti/syslink/bin/$(SYSLINK_VARIANT_NAME)/syslink.ko $(SYSLINK_INSTALL_DIR)/packages/ti/syslink/bin/$(SYSLINK_VARIANT_NAME)/samples/slaveloader_release $(ANDROID_INSTALL_DIR)/hardware/ti/ti81xx/syslink_vpss/hdvpss/$(SYSLINK_VARIANT_NAME)/* $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/bin/syslink/


# Build VPSS / HDMI modules
kernel_modules:	syslink
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) KBUILD_EXTRA_SYMBOLS=$(SYSLINK_INSTALL_DIR)/packages/ti/syslink/utils/hlos/knl/Linux/Module.symvers SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR)/packages IPC_DIR=$(IPC_INSTALL_DIR)/packages modules
	$(MAKE) -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) KBUILD_EXTRA_SYMBOLS=$(SYSLINK_INSTALL_DIR)/packages/ti/syslink/utils/hlos/knl/Linux/Module.symvers SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR)/packages IPC_DIR=$(IPC_INSTALL_DIR)/packages INSTALL_MOD_PATH=$(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/system/ modules_install
	

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

wl12xx_compat_clean:
	$(MAKE) -C hardware/ti/wlan/WL1271_compat/drivers ANDROID_ROOT_DIR=$(ANDROID_INSTALL_DIR) TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) ARCH=arm clean

# Clean Syslink
syslink_clean:
	@echo "syslink clean"
	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/ti/syslink/utils/hlos/knl/Linux ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR) IPC_DIR=$(IPC_INSTALL_DIR)/packages SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME) clean
	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/ti/syslink/utils/hlos/usr/Linux ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR) IPC_DIR=$(IPC_INSTALL_DIR)/packages SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME)  clean
	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/ti/syslink/samples/hlos/common/usr/Linux/ ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR) IPC_DIR=$(IPC_INSTALL_DIR)/packages  SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME) clean
	$(MAKE) -C $(SYSLINK_INSTALL_DIR)/ti/syslink/samples/hlos/procMgr/usr/Linux ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) SYSLINK_PLATFORM=TI81XX ANDROID_ROOT=$(ANDROID_INSTALL_DIR) SYSLINK_ROOT=$(SYSLINK_INSTALL_DIR) IPC_DIR=$(IPC_INSTALL_DIR)/packages SYSLINK_VARIANT=$(SYSLINK_VARIANT_NAME)  clean

# Remove filesystem
fs_clean:
	rm -rf $(ANDROID_FS_DIR)
	rm -f $(ANDROID_INSTALL_DIR)/out/target/product/$(TARGET_PRODUCT)/rootfs.tar.bz2

rowboat_clean: clean wl12xx_compat_clean sgx_clean kernel_clean fs_clean syslink_clean
