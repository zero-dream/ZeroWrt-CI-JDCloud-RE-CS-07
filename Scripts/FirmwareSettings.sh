#!/bin/bash

# 修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
# 修改 immortalwrt.lan 关联 IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
# 添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ ZeroWrt-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	# 修改 WIFI 名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	# 修改 WIFI 密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	# 修改 WIFI 名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	# 修改 WIFI 密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	# 修改 WIFI 地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	# 修改 WIFI 加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
# 修改默认 IP 地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
# 修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_HOST'/g" $CFG_FILE

# 配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> "$WRT_ConfigPath"
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> "$WRT_ConfigPath"
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> "$WRT_ConfigPath"
# echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> "$WRT_ConfigPath"

# 手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> "$WRT_ConfigPath"
fi

# 高通平台调整
DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
	# 取消 NSS 相关 Feed
	echo "CONFIG_FEED_nss_packages=n" >> "$WRT_ConfigPath"
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> "$WRT_ConfigPath"
	# 开启 sqm-nss 插件
	echo "CONFIG_PACKAGE_luci-app-sqm=y" >> "$WRT_ConfigPath"
	echo "CONFIG_PACKAGE_sqm-scripts-nss=y" >> "$WRT_ConfigPath"
	# 设置 NSS 版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> "$WRT_ConfigPath"
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> "$WRT_ConfigPath"
	# 无 WIFI 配置调整 Q6 大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi
