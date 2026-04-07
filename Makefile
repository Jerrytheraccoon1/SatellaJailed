TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = CarParking

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SatellaJailed

# Since the file is now in the same folder as the Makefile:
SatellaJailed_FILES = Tweak.swift
SatellaJailed_CFLAGS = -fobjc-arc
SatellaJailed_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
