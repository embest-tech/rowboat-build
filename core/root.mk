### DO NOT EDIT THIS FILE ###
include build/core/main.mk
### DO NOT EDIT THIS FILE ###

.PHONY: kernel
kernel: droid
ifeq ($(TARGET_PRODUCT), beagleboard)
 	make -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), omap3evm)
	make -C kernel ARCH=arm omap3_evm_android_defconfig
endif
	make -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) uImage

.PHONY: dvsdk
dvsdk: kernel
	./external/ti-dsp/get_tidsp.sh
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG)
