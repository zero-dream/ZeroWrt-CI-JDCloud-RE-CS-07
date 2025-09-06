#!/bin/bash

# --------------------------------------------------

cd "$GITHUB_WORKSPACE/$WRT_DIR/"

# --------------------------------------------------

# 修改设备内核大小
function modifyKernelSize() {
  image_file='./target/linux/qualcommax/image/ipq60xx.mk'
  sed -i "/^define Device\/jdcloud_re-ss-01/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" $image_file
  sed -i "/^define Device\/jdcloud_re-cs-02/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" $image_file
  sed -i "/^define Device\/jdcloud_re-cs-07/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" $image_file
  sed -i "/^define Device\/redmi_ax5-jdcloud/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" $image_file
  sed -i "/^define Device\/linksys_mr/,/^endef/ { /KERNEL_SIZE := 8192k/s//KERNEL_SIZE := 12288k/ }" $image_file
}

# 添加内存回收补丁
function addSkbRecycler() {
  cat >> $1 <<EOF
# SKB Recycler
CONFIG_KERNEL_SKB_RECYCLER=y
CONFIG_KERNEL_SKB_RECYCLER_MULTI_CPU=y
EOF
}

# 添加高通平台的 NSS 驱动
function addNssDriver() {
  cat >> $1 <<EOF
# NSS Driver
CONFIG_PACKAGE_kmod-qca-nss-macsec=y
CONFIG_PACKAGE_kmod-qca-nss-drv-vlan=y
CONFIG_PACKAGE_kmod-qca-nss-dp=y
CONFIG_PACKAGE_kmod-qca-nss-drv=y
CONFIG_PACKAGE_kmod-qca-nss-drv-bridge-mgr=y
CONFIG_PACKAGE_kmod-qca-nss-drv-igs=y
CONFIG_PACKAGE_kmod-qca-nss-drv-map-t=y
CONFIG_PACKAGE_kmod-qca-nss-drv-pppoe=y
CONFIG_PACKAGE_kmod-qca-nss-drv-pptp=y
CONFIG_PACKAGE_kmod-qca-nss-drv-qdisc=y
CONFIG_PACKAGE_kmod-qca-nss-ecm=y
CONFIG_PACKAGE_kmod-qca-nss-drv-l2tpv2=y
CONFIG_PACKAGE_kmod-qca-nss-drv-lag-mgr=y
EOF
}

# 获取内核版本
function getKernelVersion() {
  echo $(sed -n 's/^KERNEL_PATCHVER:=\(.*\)/\1/p' './target/linux/qualcommax/Makefile')
}

# 创建配置文件
function createConfig() {
  cat "$GITHUB_WORKSPACE/Config/$WRT_CONFIG" > $WRT_ConfigPath
  cat "$GITHUB_WORKSPACE/Config/CompileFirmware" >> $WRT_ConfigPath
  cat "$GITHUB_WORKSPACE/Config/ZeroWrtKernelModules" >> $WRT_ConfigPath
  # Hook
  source "$ZD_ScriptLibPath/Hook.sh"
  bashHook 'FirmwareConfig/CreateConfig'
  # 修改设备内核大小
  modifyKernelSize
  # 添加内存回收补丁
  addSkbRecycler $WRT_ConfigPath
  # 添加高通平台的 NSS 驱动
  if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
    addNssDriver $WRT_ConfigPath
  fi
}
