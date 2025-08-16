#!/bin/bash

function catKernelConfig() {
  if [ -f $1 ]; then
    cat >> $1 <<EOF
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUPS=y
CONFIG_KPROBES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_ACT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
CONFIG_DEBUG_INFO_BTF=y
CONFIG_KPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_SCHED_CLASS_EXT=y
CONFIG_PROBE_EVENTS_BTF_ARGS=y
CONFIG_IMX_SCMI_MISC_DRV=y
CONFIG_ARM64_CONTPTE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
# CONFIG_TRANSPARENT_HUGEPAGE_NEVER is not set
EOF
    echo "catKernelConfig to $1 done"
  fi
}

function catEbpfConfig() {
  cat >> $1 <<EOF
# EBPF
CONFIG_DEVEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_REDUCED=n
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
EOF
}

function catUsbNet() {
  cat >> $1 <<EOF
# USB CPE Driver
CONFIG_PACKAGE_kmod-usb-net=y
CONFIG_PACKAGE_kmod-usb-net-cdc-eem=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y
CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y
CONFIG_PACKAGE_kmod-usb-net-cdc-subset=y
CONFIG_PACKAGE_kmod-usb-net-huawei-cdc-ncm=y
CONFIG_PACKAGE_kmod-usb-net-ipheth=y
CONFIG_PACKAGE_kmod-usb-net-rndis=y
CONFIG_PACKAGE_kmod-usb-net-rtl8150=y
CONFIG_PACKAGE_kmod-usb-net-rtl8152=y
EOF
# 6.12 内核不包含以下驱动
if echo "$CI_NAME" | grep -v "6.12" > /dev/null; then
  cat >> $1 <<EOF
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan-fibocom=y
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan-quectel=y
EOF
fi
}

function setNssDriver() {
  cat >> $1 <<EOF
# NSS 驱动相关
CONFIG_NSS_FIRMWARE_VERSION_11_4=n
# CONFIG_NSS_FIRMWARE_VERSION_12_5 is not set
CONFIG_NSS_FIRMWARE_VERSION_12_2=y
CONFIG_PACKAGE_kmod-qca-nss-dp=y
CONFIG_PACKAGE_kmod-qca-nss-drv=y
CONFIG_PACKAGE_kmod-qca-nss-drv-bridge-mgr=y
CONFIG_PACKAGE_kmod-qca-nss-drv-vlan=y
CONFIG_PACKAGE_kmod-qca-nss-drv-igs=y
# CONFIG_PACKAGE_kmod-qca-nss-drv-map-t=y
CONFIG_PACKAGE_kmod-qca-nss-drv-pppoe=y
CONFIG_PACKAGE_kmod-qca-nss-drv-pptp=y
CONFIG_PACKAGE_kmod-qca-nss-drv-qdisc=y
CONFIG_PACKAGE_kmod-qca-nss-ecm=y
CONFIG_PACKAGE_kmod-qca-nss-macsec=y
CONFIG_PACKAGE_kmod-qca-nss-drv-l2tpv2=y
CONFIG_PACKAGE_kmod-qca-nss-drv-lag-mgr=y
EOF
}

function kernelVersion() {
  echo $(sed -n 's/^KERNEL_PATCHVER:=\(.*\)/\1/p' target/linux/qualcommax/Makefile)
}

function removeWifi() {
  local target=$1
  # 去除依赖
  sed -i 's/\(ath11k-firmware-[^ ]*\|ipq-wifi-[^ ]*\|kmod-ath11k-[^ ]*\)//g' ./target/linux/qualcommax/Makefile
  sed -i 's/\(ath11k-firmware-[^ ]*\|ipq-wifi-[^ ]*\|kmod-ath11k-[^ ]*\)//g' ./target/linux/qualcommax/${target}/target.mk
  sed -i 's/\(ath11k-firmware-[^ ]*\|ipq-wifi-[^ ]*\|kmod-ath11k-[^ ]*\)//g' ./target/linux/qualcommax/image/${target}.mk
  sed -i 's/\(ath10k-firmware-[^ ]*\|kmod-ath10k [^ ]*\|kmod-ath10k-[^ ]*\)//g' ./target/linux/qualcommax/image/${target}.mk
  # 删除无线组件
  rm -rf package/network/services/hostapd
  rm -rf package/firmware/ipq-wifi
}

function setKernelSize() {
  # 修改 JDCloud 的内核大小为 12M
  image_file='./target/linux/qualcommax/image/ipq60xx.mk'
  sed -i "/^define Device\/jdcloud_re-cs-07/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" $image_file
}

# 开启内存回收补丁
function enableSkbRecycler() {
  cat >> $1 <<EOF
CONFIG_KERNEL_SKB_RECYCLER=y
CONFIG_KERNEL_SKB_RECYCLER_MULTI_CPU=y
EOF
}

function generateConfig() {
  configFile=".config"
  # 如配置文件已存在
  cat $GITHUB_WORKSPACE/Config/${WRT_CONFIG} > $configFile
  cat $GITHUB_WORKSPACE/Config/CompileFirmware >> $configFile
  if [[ "$WRT_MODE" == 'PACKAGE' ]]; then
    cat $GITHUB_WORKSPACE/Config/CompilePackage >> $configFile
  fi
  # 删除 WiFi 依赖
  local target=$(echo $WRT_ARCH | cut -d'_' -f2)
  if [[ "$WRT_CONFIG" == *"WiFi_NO"* ]]; then
    removeWifi $target
  fi
  # IPK 仓库
  if [[ "${GITHUB_REPOSITORY,,}" == *"openwrt-ci-ipk"* ]]; then
    echo "CONFIG_USE_APK=n" >> $configFile
  fi
  setNssDriver $configFile
  # 增加 EBPF
  catEbpfConfig $configFile
  enableSkbRecycler $configFile
  setKernelSize
  # 增加内核选项
  catKernelConfig "target/linux/qualcommax/${target}/config-default"
}
