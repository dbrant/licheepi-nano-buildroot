DOSBOX_STAGING_VERSION = v0.82.2.licheepi
DOSBOX_STAGING_SITE = https://github.com/dbrant/dosbox-staging.git
DOSBOX_STAGING_SITE_METHOD = git
DOSBOX_STAGING_LICENSE = GPL-2.0+
DOSBOX_STAGING_LICENSE_FILES = COPYING
DOSBOX_STAGING_DEPENDENCIES = sdl2 libzlib libpng iir opusfile speex speexdsp

DOSBOX_STAGING_CONF_OPTS = \
	-Duse_opengl=false \
	-Duse_mt32emu=false \
    -Duse_sdl2_net=false \
    -Duse_fluidsynth=false \
    -Duse_slirp=false \
    -Dtracy=false \
    -Duse_zlib_ng=false \
    -Duse_alsa=false \
    -Dpagesize=4096

define DOSBOX_STAGING_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/build/dosbox $(TARGET_DIR)/usr/bin/dosbox
endef

$(eval $(meson-package))
