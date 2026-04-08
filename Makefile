TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = CarParking

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MaxHostSatella
MaxHostSatella_FILES = Tweak.swift
MaxHostSatella_FRAMEWORKS = UIKit Foundation StoreKit
MaxHostSatella_SWIFTFLAGS = -isysroot $(THEOS)/sdks/iPhoneOS14.5.sdk

include $(THEOS_MAKE_PATH)/tweak.mk
