#!/bin/bash
set -e

# Add Nikki feed and install its packages.
grep -q '^src-git nikki ' feeds.conf.default || echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

# Nikki feed ships two mutually exclusive Mihomo providers. Keep only the
# stable meta provider; otherwise Kconfig creates a recursive CONFLICTS loop.
rm -rf package/feeds/nikki/mihomo-alpha feeds/nikki/mihomo-alpha
if [ -f package/feeds/nikki/mihomo-meta/Makefile ]; then
    sed -i '/^[[:space:]]*CONFLICTS:=mihomo-alpha[[:space:]]*$/d' package/feeds/nikki/mihomo-meta/Makefile
fi

# Generate the package configuration only after the provider set is fixed.
make defconfig
echo "Nikki feed ready; Mihomo meta selected; package build deferred to firmware compilation."
echo "ZN M2 / Kernel 6.12 / NSS / No WiFi / No USB / Nikki"
