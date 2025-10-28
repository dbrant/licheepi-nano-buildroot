SNES9X_VERSION = 1.53.sdl
SNES9X_SITE = https://github.com/dbrant/snes9x-sdl.git
SNES9X_SITE_METHOD = git
SNES9X_LICENSE = GPL-2.0+
SNES9X_LICENSE_FILES = LICENSE
SNES9X_INSTALL_STAGING = NO
SNES9X_INSTALL_TARGET = YES
SNES9X_DEPENDENCIES = sdl libzlib

SNES9X_SUBDIR = sdl

SNES9X_CONF_ENV = \
    CXXFLAGS="$(TARGET_CXXFLAGS) -std=c++14 -Wno-implicit-fallthrough" \
    CXX="$(TARGET_CXX) -std=c++14 -Wno-implicit-fallthrough" \
    LIBS="$(TARGET_LDFLAGS) -lSDL"

SNES9X_CONF_OPTS += \
    CXXFLAGS="$(TARGET_CXXFLAGS) -std=c++14  -Wno-implicit-fallthrough" \
    cross_compiling=yes \
    snes9x_cv_sdl=yes \
    snes9x_cv_option_o3=yes \
    snes9x_cv_option_omit_frame_pointer=yes \
    snes9x_cv_option_no_exceptions=yes \
    snes9x_cv_option_no_rtti=yes \
    snes9x_cv_option_pedantic=yes \
    snes9x_cv_option_Wall=yes \
    snes9x_cv_option_W=yes \
    snes9x_cv_option_Wno_unused_parameter=yes 

define SNES9X_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/sdl/snes9x-sdl $(TARGET_DIR)/usr/bin/snes9x
endef

$(eval $(autotools-package))
