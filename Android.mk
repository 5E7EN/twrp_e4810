LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),E4810)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
