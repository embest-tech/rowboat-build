kernel_not_configured := $(wildcard kernel/.config)
dvsdk_not_installed := $(wildcard external/ti-dsp/already_clean)
DSP_PATH := $(wildcard external/ti-dsp)

OMAPES := 5.x

rowboat: dvsdk sgx

.PHONY: kernel
kernel: droid
ifeq ($(strip $(kernel_not_configured)),)
ifeq ($(TARGET_PRODUCT), beagleboard)
	make -C kernel ARCH=arm omap3_beagle_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), omap3evm)
	make -C kernel ARCH=arm omap3_evm_android_defconfig
endif
ifeq ($(TARGET_PRODUCT), igepv2)
	make -C kernel ARCH=arm igep0020_android_defconfig
endif
endif
	make -C kernel ARCH=arm CROSS_COMPILE=../$($(combo_target)TOOLS_PREFIX) uImage

.PHONY: dvsdk
dvsdk: kernel
ifeq ($(strip $(dvsdk_not_installed)),)
	TOOLS_DIR=$(dir `pwd`/$($(combo_target)TOOLS_PREFIX))../ ./external/ti-dsp/get_tidsp.sh
	touch ./external/ti-dsp/already_clean
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG) clean
endif
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG)
	make -C hardware/ti/omx combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG)

dvsdk_clean:
	make -C external/ti-dsp combo_target=$(combo_target) $(combo_target)TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) HOST_PREBUILT_TAG=$(HOST_PREBUILT_TAG) clean

kernel_clean:
	make -C kernel ARCH=arm clean
	rm kernel/.config

sgx: kernel
	make -C hardware/ti/sgx ANDROID_ROOT_DIR=`pwd` TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) OMAPES=$(OMAPES)
	make -C hardware/ti/sgx ANDROID_ROOT_DIR=`pwd` TOOLS_PREFIX=$($(combo_target)TOOLS_PREFIX) OMAPES=$(OMAPES) install

sgx_clean: 
	make -C hardware/ti/sgx OMAPES=$(OMAPES) clean

rowboat_clean: clean  dvsdk_clean sgx_clean kernel_clean
