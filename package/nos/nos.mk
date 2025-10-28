NOS_VERSION = fb2e29744a17b3d91327192cc9a7199a1baf3b38
NOS_SITE = https://github.com/olivecc/nos.git
NOS_SITE_METHOD = git
NOS_LICENSE = GPL-2.0+
NOS_LICENSE_FILES = LICENSE
NOS_INSTALL_STAGING = YES
NOS_INSTALL_TARGET = YES
NOS_DEPENDENCIES = sdl2

define NOS_BUILD_CMDS
	$(TARGET_CXX) \
		$(shell $(PKG_CONFIG_HOST_BINARY) sdl2 --cflags) \
		-I$(@D)/core -I$(@D)/ines \
		$(@D)/test/main.cpp $(@D)/ines/ines.cpp \
		$(shell $(PKG_CONFIG_HOST_BINARY) sdl2 --libs) \
		-std=c++17 -O3 -Wno-overflow \
		-o $(@D)/nos
endef

define NOS_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/nos $(TARGET_DIR)/usr/bin/nos
endef

$(eval $(generic-package))
