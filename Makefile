#
# Copyright (C) 2014 OpenWrt.org  
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# updated to work with latest source from abrasive
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shairport-sync
PKG_VERSION:=HEAD
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/mikebrady/shairport-sync.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

PKG_BUILD_DEPENDS:= +libpthread +libopenssl +libpolarssl +libavahi-client +alsa-lib +libdaemon +libsoxr

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS+= \
	--with-alsa

ifeq ($(CONFIG_USE_OPENSSL),y)
CONFIGURE_ARGS+= \
	--with-ssl=openssl
endif

ifeq ($(CONFIG_USE_POLARSSL),y)
CONFIGURE_ARGS+= \
  --with-ssl=polarssl
endif

ifeq ($(CONFIG_USE_AVAHI),y)
CONFIGURE_ARGS+= \
  --with-avahi
endif

ifeq ($(CONFIG_USE_TINYSVCMDNS),y)
CONFIGURE_ARGS+= \
  --with-tinysvcmdns
endif

ifeq ($(CONFIG_USE_SOXR),y)
CONFIGURE_ARGS+= \
  --with-soxr
endif

define Package/shairport-sync
  SECTION:=sound
  CATEGORY:=Sound
  URL:=https://github.com/mikebrady/shairport-sync
  MAINTAINER:=Mike Brady <mikebrady@eircom.net>
  TITLE:=iTunes/AirPlay compatible Audio Player with sync
  DEPENDS:= +libpthread +alsa-lib +libdaemon +libpopt @AUDIO_SUPPORT +kmod-sound-core
ifeq ($(CONFIG_USE_OPENSSL),y)
  DEPENDS += +libopenssl
endif
ifeq ($(CONFIG_USE_POLARSSL),y)
  DEPENDS += +libpolarssl
endif
ifeq ($(CONFIG_USE_AVAHI),y)
  DEPENDS += +libavahi-client
endif
ifeq ($(CONFIG_USE_SOXR),y)
  DEPENDS += +libsoxr
endif
  MENU:=1
endef

define Package/shairport-sync/config
	source "$(SOURCE)/Config.in"
endef

define Package/shairport-sync/description
  Shairport Sync emulates an AirPort Express for audio playback from remote clients
  such as the iPhone, iTunes, Apple TV, Quicktime Player or forked-daapd.
  
  Shairport Sync implements audio synchronisation and supports multi-room use.
  Hardware mute and volume controls are also supported.
  
  You should add [Kernel Modules > Sound Support > kmod-usb-audio]
  if you want to support USB-based sound cards.
  
  After installation, edit /etc/config/shairport-sync to suit your sound card,
  then execute "/etc/init.d/shairport-sync restart", or simply reboot the machine.
  
  Get more information at https://github.com/mikebrady/shairport-sync
endef

define Package/shairport-sync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/shairport-sync $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/init.d/shairport-sync $(1)/etc/init.d/
ifeq ($(CONFIG_USE_TINYSVCMDNS),y)
	$(INSTALL_BIN) ./files/init.d/add-multicast-route $(1)/etc/init.d/
endif
	$(INSTALL_DATA) ./files/config/shairport-sync $(1)/etc/config/
	$(INSTALL_DATA) ./files/asound.conf $(1)/etc/
endef

$(eval $(call BuildPackage,shairport-sync))
