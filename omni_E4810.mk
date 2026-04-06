# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from our device
$(call inherit-product, device/kyocera/E4810/device.mk)

PRODUCT_DEVICE := E4810
PRODUCT_NAME := omni_E4810
PRODUCT_BRAND := KYOCERA
PRODUCT_MODEL := E4810
PRODUCT_MANUFACTURER := kyocera

PRODUCT_GMS_CLIENTID_BASE := android-kyocera

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="VZW_E4810-user 9 1.603VZ.0200.a 1.603VZ.0200.a release-keys"

BUILD_FINGERPRINT := KYOCERA/VZW_E4810/E4810:9/1.603VZ.0200.a/1.603VZ.0200.a:user/release-keys
