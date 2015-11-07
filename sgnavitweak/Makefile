THEOS_DEVICE_IP = 192.168.1.156
ARCHS = armv7 arm64
TARGET = iphone:8.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = UberHack
UberHack_FILES = Tweak.xm SgLocationManagerDelegate.m
UberHack_FRAMEWORKS = CoreLocation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
