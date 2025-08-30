#!/bin/bash

# 添加内存回收补丁
function addSkbRecycler() {
  cat >> $1 <<EOF
# 内存回收补丁
CONFIG_KERNEL_SKB_RECYCLER=y
CONFIG_KERNEL_SKB_RECYCLER_MULTI_CPU=y
EOF
}

# 添加 eBPF
function addEBPF() {
  cat >> $1 <<EOF
# eBPF
CONFIG_DEVEL=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_KERNEL_DEBUG_KERNEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_REDUCED=n
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
EOF
}

# 高通平台添加 NSS 驱动
function addNssDriver() {
  cat >> $1 <<EOF
# NSS 驱动
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
  echo $(sed -n 's/^KERNEL_PATCHVER:=\(.*\)/\1/p' target/linux/qualcommax/Makefile)
}

# 创建配置文件
function createConfig() {
  cat $GITHUB_WORKSPACE/Config/${WRT_CONFIG} > $WRT_ConfigPath
  cat $GITHUB_WORKSPACE/Config/CompileFirmware >> $WRT_ConfigPath
  cat $GITHUB_WORKSPACE/Config/ZeroWrtKernelModules >> $WRT_ConfigPath
  if [[ "$WRT_MODE" == 'PACKAGE' ]]; then
    cat $GITHUB_WORKSPACE/Config/CompilePackage >> $WRT_ConfigPath
  fi
  # 添加内存回收补丁
  addSkbRecycler $WRT_ConfigPath
  # 添加 eBPF
  addEBPF $WRT_ConfigPath
  # 高通平台添加 NSS 驱动
  if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
    addNssDriver $WRT_ConfigPath
  fi
}
