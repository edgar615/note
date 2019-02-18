vim /etc/sysconfig/network-scripts/ifcfg-网卡

```
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="dhcp" #改为 BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="yes"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="enp0s3"
UUID="b9d5e543-f36d-4200-ae8f-7815384951d7"
DEVICE="enp0s3"
ONBOOT="yes"
# 静态IP
BROADCAST=192.168.1.255 #前三位要和主机的ip地址一致，后一位为255
DNS1=8.8.8.8 #会覆盖 /etc/resolv.conf
DNS2=192.168.1.201
IPADDR=192.168.1.200
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DEFROUTE=yes
PEERDNS=yes #如果要重启后不还原resolv.conf，设为no，测试不起作用
PEERROUTES=yes

```

service network restart