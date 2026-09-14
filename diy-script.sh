#!/bin/bash
set -e

# Add only Nikki's feed. Installing the complete feed exposes two mutually
# exclusive Mihomo providers and can trigger a recursive Kconfig dependency.
grep -q '^src-git nikki ' feeds.conf.default ||   echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >> feeds.conf.default
./scripts/feeds update nikki

# Remove the alpha provider before creating package links.
rm -rf feeds/nikki/mihomo-alpha package/feeds/nikki/mihomo-alpha

# Install exactly the packages required by Nikki and the stable Mihomo core.
./scripts/feeds install -p nikki nikki luci-app-nikki luci-i18n-nikki-zh-cn mihomo-meta

# Validate feed selection before Kconfig runs.
test -f package/feeds/nikki/mihomo-meta/Makefile
test ! -e package/feeds/nikki/mihomo-alpha
sed -i '/^[[:space:]]*CONFLICTS:=mihomo-alpha[[:space:]]*$/d'   package/feeds/nikki/mihomo-meta/Makefile

make defconfig
printf '%s\n' \
  'Nikki feed ready; stable Mihomo meta provider selected.' \
  'ZN M2 / Kernel 6.12 / NSS / No WiFi / No USB / Nikki'

