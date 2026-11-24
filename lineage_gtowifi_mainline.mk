#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit from device
$(call inherit-product, device/samsung/gtowifi_mainline/device.mk)

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_NAME := lineage_gtowifi_mainline
PRODUCT_DEVICE := gtowifi_mainline
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_MODEL := SM-T290

# Experimental low-memory profile for the 2 GiB SM-T290.
# Opt in at build time; baseline remains unchanged for A/B testing.
ifeq ($(GTOWIFI_LOW_RAM),true)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.low_ram=true
endif
