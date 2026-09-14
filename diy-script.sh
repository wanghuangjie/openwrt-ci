#!/bin/bash
set -e

# Add Nikki's feed, then install the normal base feeds so all package dependencies exist.
grep -q '^src-git nikki ' feeds.conf.default || echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >> feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

# Nikki ships two mutually exclusive Mihomo providers. Remove alpha after feed installation.
rm -rf feeds/nikki/mihomo-alpha package/feeds/nikki/mihomo-alpha

# Keep only the stable Mihomo meta provider and the Nikki LuCI packages.
./scripts/feeds install -p nikki nikki luci-app-nikki luci-i18n-nikki-zh-cn mihomo-meta
if [ -f package/feeds/nikki/mihomo-meta/Makefile ]; then
    sed -i '/^[[:space:]]*CONFLICTS:=mihomo-alpha[[:space:]]*$/d' package/feeds/nikki/mihomo-meta/Makefile
fi

# Generate the final Kconfig after the provider set is fixed.
make defconfig
printf '%s\n' \
  'Nikki feed ready; base feeds installed; stable Mihomo meta provider selected.' \
  'ZN M2 / Kernel 6.12 / NSS / No WiFi / No USB / Nikki'

