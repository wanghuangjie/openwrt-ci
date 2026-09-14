#!/bin/bash

# ============================================================
# ZN M2 / IPQ60xx
# Kernel 6.12 / NSS / No WiFi / No USB
#
# Minimal DIY Script
# Nikki + Mihomo
# ============================================================

set -e


# ============================================================
# 1. 默认设置
# ============================================================

# 默认 LAN IP
# 保持 192.168.1.1，不修改
#
# 如以后需要修改：
# sed -i 's/192.168.1.1/10.0.0.1/g' \
# package/base-files/files/bin/config_generate


# ============================================================
# 2. TTYD
# ============================================================

# 默认保持正常登录方式。
# 不建议开启免密码 root 登录。
#
# 如以后明确需要：
# sed -i 's|/bin/login|/bin/login -f root|g' \
# feeds/packages/utils/ttyd/files/ttyd.config


# ============================================================
# 3. Nikki / Mihomo Feed
# ============================================================

echo "Adding Nikki feed..."

sed -i '/^src-git nikki /d' feeds.conf.default
echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git^3799926b147d7065ac98508f16951f8714e53659' \
    >> feeds.conf.default


# ============================================================
# 4. Update Feeds
# ============================================================

echo "Updating feeds..."

./scripts/feeds update -a


# ============================================================
# 5. Install Feeds
# ============================================================

echo "Installing feeds..."

./scripts/feeds install -a

# Nikki 同时提供 mihomo-meta 和 mihomo-alpha；两者互相 CONFLICTS，
# 在部分 OpenWrt Kconfig 版本中会被展开成递归依赖。此固件固定使用
# stable 的 mihomo-meta，因此在生成 .config 前移除 alpha 包入口。
rm -rf package/feeds/nikki/mihomo-alpha


# ============================================================
# 6. Lucky
# ============================================================

echo "Adding Lucky packages..."

LUCKY_COMMIT='c1730565c6df4ab30d345cf73584f03f5cc7bc8f'
rm -rf package/lucky
git init package/lucky
git -C package/lucky remote add origin \
    https://github.com/gdy666/luci-app-lucky.git
git -C package/lucky fetch --depth 1 origin "$LUCKY_COMMIT"
git -C package/lucky checkout --detach FETCH_HEAD


# ============================================================
# 7. 清理不需要的代理软件
#
# 防止其他 feed / 默认配置把它们选进来。
# 最终是否进入固件仍以 .config 为准。
# ============================================================

rm -rf package/luci-app-passwall 2>/dev/null || true
rm -rf package/luci-app-passwall2 2>/dev/null || true
rm -rf package/luci-app-openclash 2>/dev/null || true
rm -rf package/luci-app-ssr-plus 2>/dev/null || true


# ============================================================
# 8. 修正部分第三方 LuCI Makefile 路径
#
# Nikki 通常不需要，但保留这一兼容处理成本很低。
# ============================================================

find package/*/ -maxdepth 2 -path "*/Makefile" 2>/dev/null | \
    xargs -r sed -i \
    's#../../luci.mk#$(TOPDIR)/feeds/luci/luci.mk#g'


# ============================================================
# 9. 修改版本显示
#
# 示例：
# OpenWrt R26.09.13 ZN-M2
# ============================================================

date_version=$(date +"%y.%m.%d")

if [ -f package/lean/default-settings/files/zzz-default-settings ]; then

    orig_version=$(
        grep "DISTRIB_REVISION=" \
        package/lean/default-settings/files/zzz-default-settings \
        | awk -F "'" '{print $2}'
    )

    if [ -n "$orig_version" ]; then
        sed -i \
            "s/${orig_version}/R${date_version} ZN-M2/g" \
            package/lean/default-settings/files/zzz-default-settings
    fi

fi


# ============================================================
# 10. 完成
# ============================================================

echo "============================================"
echo " ZN M2 DIY configuration completed"
echo " Kernel 6.12 / NSS"
echo " No WiFi"
echo " No USB"
echo " Nikki + Mihomo"
echo " WireGuard"
echo " Mosquitto"
echo "============================================"


# Mihomo core only: remove alpha package and its conflict declaration
rm -rf package/feeds/nikki/mihomo-alpha
if [ -f package/feeds/nikki/mihomo-meta/Makefile ]; then
    sed -i '/^[[:space:]]*CONFLICTS:=mihomo-alpha[[:space:]]*$/d' package/feeds/nikki/mihomo-meta/Makefile
    fi
    
