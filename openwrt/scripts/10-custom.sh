#!/bin/bash
# mihomo
if curl -s "$mirror/openwrt/24-config-common" | grep -q "^CONFIG_PACKAGE_luci-app-mihomo=y"; then
    git clone https://$github/morytyann/OpenWrt-mihomo package/new/openwrt-mihomo
    echo -e "untrusted comment: MihomoTProxy\nRWSrAXyIqregizvXvG9kJI/JoTkaCCPDy6CQrrVQ4IZ8Qgu+iWMql0UW" > /etc/opkg/keys/ab017c88aab7a08b
    echo "src/gz mihomo https://raw.e11z.net/$github/morytyann/OpenWrt-mihomo/raw/gh-pages/$branch/$arch/mihomo" >> /etc/opkg/customfeeds.conf
    mkdir -p files/etc/mihomo/run/ui
    curl -skLo files/etc/mihomo/run/Country.mmdb https://$github/NobyDa/geoip/raw/release/Private-GeoIP-CN.mmdb
    curl -skLo files/etc/mihomo/run/GeoIP.dat https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat
    curl -skLo files/etc/mihomo/run/GeoSite.dat https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
    curl -skLo gh-pages.tar.gz https://$github/Zephyruso/zashboard/archive/refs/heads/gh-pages.zip
    tar zxf gh-pages.tar.gz
    mv gh-pages files/etc/mihomo/run/ui/zashboard
fi

# add openclash
git clone -b dev https://github.com/vernesong/OpenClash package/feeds/luci/openclash --depth=1
mv package/feeds/luci/openclash/luci-app-openclash package/feeds/luci/luci-app-openclash
rm -rf package/feeds/luci/openclash
sed -i 's/("OpenClash"), 50/("OpenClash"), 20/' package/feeds/luci/luci-app-openclash/luasrc/controller/openclash.lua

#tailscale
if curl -s "$mirror/openwrt/24-config-common" | grep -q "^CONFIG_PACKAGE_luci-app-tailscale=y"; then
    git clone https://$github/asvow/luci-app-tailscale package/new/luci-app-tailscale
    curl -skLo files/etc/hotplug.d/iface/99-tailscale-needs $mirror/openwrt/files/etc/hotplug.d/iface/99-tailscale-needs
fi

#qosmate
if curl -s "$mirror/openwrt/24-config-common" | grep -q "^CONFIG_PACKAGE_luci-app-qosmate=y"; then
    git clone https://$github/hudra0/qosmate package/new/qosmate
    git clone https://$github/hudra0/luci-app-qosmate package/new/luci-app-qosmate
fi

# sysupgrade keep files
echo "/etc/hotplug.d/iface/*.sh" >>files/etc/sysupgrade.conf
echo "/etc/init.d/beszel-agent" >>files/etc/sysupgrade.conf

# add UE-DDNS
mkdir -p files/usr/bin
curl -skLo files/usr/bin/ue-ddns ddns.03k.org
chmod +x files/usr/bin/ue-ddns

# https://github.com/henrygd/beszel
if [ "$platform" = "rk3568" ]; then
    wget https://$github/henrygd/beszel/releases/latest/download/beszel-agent_linux_arm64.tar.gz
    tar zxvf beszel-agent_linux_arm64.tar.gz
    mv beszel-agent files/usr/bin
else
    wget https://$github/henrygd/beszel/releases/latest/download/beszel-agent_linux_amd64.tar.gz
    tar zxvf beszel-agent_linux_amd64.tar.gz
    mv beszel-agent files/usr/bin
fi

# ghp.ci might not stable
sed -i 's/ghp.ci/raw.e11z.net/g' package/new/default-settings/default/zzz-default-settings

# uci-defaults
curl -skLo files/etc/uci-defaults/99-led $mirror/openwrt/files/etc/uci-defaults/99-led
curl -skLo files/etc/uci-defaults/99-mihomo $mirror/openwrt/files/etc/uci-defaults/99-mihomo
curl -skLo files/etc/uci-defaults/99-watchcat $mirror/openwrt/files/etc/uci-defaults/99-watchcat

# from pmkol/openwrt-plus
# configure default-settings
sed -i 's/openwrt\/luci/JohnsonRan\/opwrt_build_script/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's/openwrt\/luci/JohnsonRan\/opwrt_build_script/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's/openwrt\/luci/JohnsonRan\/opwrt_build_script/g' feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/footer.ut
# comment out the following line to restore the full description
sed -i '/# timezone/i grep -q '\''/tmp/sysinfo/model'\'' /etc/rc.local || sudo sed -i '\''/exit 0/i [ "$(cat /sys\\/class\\/dmi\\/id\\/sys_vendor 2>\\/dev\\/null)" = "Default string" ] \&\& echo "x86_64" > \\/tmp\\/sysinfo\\/model'\'' /etc/rc.local\n' package/new/default-settings/default/zzz-default-settings
sed -i '/# timezone/i sed -i "s/\\(DISTRIB_DESCRIPTION=\\).*/\\1'\''OpenWrt $(sed -n "s/DISTRIB_DESCRIPTION='\''OpenWrt \\([^ ]*\\) .*/\\1/p" /etc/openwrt_release)'\'',/" /etc/openwrt_release\nsource /etc/openwrt_release \&\& sed -i -e "s/distversion\\s=\\s\\".*\\"/distversion = \\"$DISTRIB_ID $DISTRIB_RELEASE ($DISTRIB_REVISION)\\"/g" -e '\''s/distname    = .*$/distname    = ""/g'\'' /usr/lib/lua/luci/version.lua\nsed -i "s/luciname    = \\".*\\"/luciname    = \\"LuCI openwrt-24.10\\"/g" /usr/lib/lua/luci/version.lua\nsed -i "s/luciversion = \\".*\\"/luciversion = \\"v'$(date +%Y%m%d)'\\"/g" /usr/lib/lua/luci/version.lua\necho "export const revision = '\''v'$(date +%Y%m%d)'\'\'', branch = '\''LuCI openwrt-24.10'\'';" > /usr/share/ucode/luci/version.uc\n/etc/init.d/rpcd restart\n' package/new/default-settings/default/zzz-default-settings




