kernel_not_configured := $(wildcard kernel/.config)
dvsdk_not_installed := $(wildcard external/ti-dsp/dvsdk_3_00_02_44)

### DO NOT EDIT THIS FILE ###
include build/core/main.mk
### DO NOT EDIT THIS FILE ###

.PHONY: kernel
kernel: droid
ifeq ($(strip $(kernel_not_configured)),)
ifeq ($(TARGET_PRODUCT), beagleboard)
	make -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), omap3evm)
	make -C kernel ARCH=arm omap3_evm_android_defconfig
endif
endif
	make -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) uImage

.PHONY: dvsdk
dvsdk: kernel
ifeq ($(strip $(dvsdk_not_installed)),)
	./external/ti-dsp/get_tidsp.sh
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG) clean
endif
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG)

.PHONY: dvsdk_clean
dvsdk_clean:
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG) clean
