THEOS_DEVICE_IP = 192.168.1.141
ARCHS = armv7 arm64
TARGET = iphone:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SGNavi
UberHack_FILES = Tweak.xm SgLocationManagerDelegate.m FixedLocationData.m SgLocationCacheManager.m
UberHack_FRAMEWORKS = CoreLocation UIKit Foundation
UberHack_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
