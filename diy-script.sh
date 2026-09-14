
#!/bin/bash
set -e

echo "Updating OpenWrt feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# This build intentionally contains no proxy core or proxy UI.
rm -rf package/feeds/nikki/mihomo-alpha package/feeds/nikki/mihomo-meta 2>/dev/null || true

# Keep package Makefiles compatible with this source tree.
find package/*/ -maxdepth 2 -path "*/Makefile" 2>/dev/null | xargs -r sed -i 's#../../luci.mk#$(TOPDIR)/feeds/luci/luci.mk#g'

echo "ZN M2 DIY configuration completed: Kernel 6.12 / NSS / No WiFi / No USB / no proxy core"
