#!/bin/bash
set -e

echo "Adding Nikki feed..."
grep -q '^src-git nikki ' feeds.conf.default || echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> feeds.conf.default

echo "Updating OpenWrt feeds..."
./scripts/feeds update -a
./scripts/feeds install -a
# Keep package Makefiles compatible with this source tree.
find package/*/ -maxdepth 2 -path "*/Makefile" 2>/dev/null | xargs -r sed -i 's#../../luci.mk#$(TOPDIR)/feeds/luci/luci.mk#g'
# Defer package compilation to the workflow's full firmware build, after the
# target toolchain has produced libgcc_s.so and all required staging files.
make defconfig
echo "Nikki feed and configuration ready; package build is deferred to firmware compilation."
echo "ZN M2 DIY configuration completed: Kernel 6.12 / NSS / No WiFi / No USB / Nikki"
