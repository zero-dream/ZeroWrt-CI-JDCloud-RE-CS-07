# ZeroWrt-CI-JDCloud-RE-CS-07

ZeroWrt 固件，由 ZeroDream 基于 VIKINGYFY 的 ImmortalWrt 源码进行开发

# 固件核心介绍

建议 Kernel Size 为 12288 k

ZeroWrt 固件的初始软件包非常精简，内置了大量 Kernel Modules

能够安装绝大部分的 Openwrt 官方 Package，极少出现内核模块缺失的情况

添加 eBPF 内核，支持 DAED 内核级透明代理

# 目录简要说明

固件文件名的时间为开始编译的时间，方便核对上游源码提交时间

Openwrt ------ 自定义覆盖

Config ------- 自定义配置

Scripts ------ 自定义脚本

# 相关参考项目

https://github.com/davidtall/OpenWRT-CI

https://github.com/VIKINGYFY/OpenWRT-CI
