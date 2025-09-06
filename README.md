# ZeroWrt-Firmware-CI

ZeroWrt 固件，由 ZeroDream 基于 VIKINGYFY 的 ImmortalWrt 源码进行开发

# 固件核心介绍

ZeroWrt 固件的初始软件包非常精简，内置了大量 Kernel Modules

能够安装绝大部分的 Openwrt 官方 Package，极少出现内核模块缺失的情况

# 目录简要说明

固件文件名的时间为开始编译的时间，方便核对上游源码提交时间

Hook ------ ZeroDream-CI 专用

ZeroDream ------ ZeroDream-CI 私有

Application ------ 应用程序目录

Config ------- 构建 ZeroWrt 的核心配置

Openwrt ------ 将数据覆盖到 ZeroWrt 编译目录

Script ------ 编译 ZeroWrt 的脚本文件夹

# 相关参考项目

https://github.com/davidtall/OpenWRT-CI

https://github.com/VIKINGYFY/OpenWRT-CI
