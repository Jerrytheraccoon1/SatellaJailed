TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SatellaJailed
SatellaJailed_FILES = Tweak.swift
SatellaJailed_SWIFTFLAGS = -isysroot $(THEOS)/sdks/iPhoneOS14.5.sdk # Ensure this matches your SDK

include $(THEOS_MAKE_PATH)/tweak.mk
