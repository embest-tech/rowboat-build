# This is a generic product that isn't specialized for a specific device.
# It includes the base Android platform. If you need Google-specific features,
# you should derive from generic_with_google.mk

PRODUCT_PACKAGES := \
    AlarmClock \
    AlarmProvider \
    DrmProvider \
    Camera \
    LatinIME \
    Email \
    Music \
    Settings \
    Sync \
    Updater \
    SubscribedFeedsProvider \
    SyncProvider

$(call inherit-product, $(SRC_TARGET_DIR)/product/ea-core.mk)

# Overrides
PRODUCT_BRAND := generic
PRODUCT_DEVICE := generic
PRODUCT_NAME := generic
