# 网络设置
## 如果IP和网关不再同一个网段上

1. 先将网关IP当成一个主机加进来，这样在这两个IP直接建立一个连接,并且不设置掩码，即能到达所有其他网段。

	route add -host 10.4.0.1 dev eth0

2. 然后再将网关IP加成网关

	route add default gw 10.4.0.1 dev eth0

注： 10.4.0.1 是网关IP，机器的IP是 10.4.7.14

上面两件需要加到/etc/rc.local文件中

	#!/bin/sh -e
	#
	# rc.local
	#
	# This script is executed at the end of each multiuser runlevel.
	# Make sure that the script will "exit 0" on success or any other
	# value on error.
	#
	# In order to enable or disable this script just change the execution
	# bits.
	#
	# By default this script does nothing.
	
	route add -host 10.4.0.1 dev eth0
	route add default gw 10.4.0.1 dev eth0
	
	exit 0

## 设置静态ip
1. vim /etc/network/interfaces，原内容如下：

	auto lo
	iface lo inet loopback
	
	auto eth0
	iface eth0 inet dhcp

dhcp表示使用DHCP分配IP

改为如下：

	auto lo
	iface lo inet loopback
	
	# The primary network interface
	auto eth0
	#iface eth0 inet dhcp
	iface eth0 inet static
	address 10.4.7.14
	netmask 255.255.255.0
	gateway 192.4.0.1


2. 手动设置DNS服务器：# vim /etc/resolv.conf
添加如下内容

	nameserver 10.4.0.1
	nameserver 8.8.8.8

执行resolv -u

注意：重启Ubuntu后发现又不能上网了，问题出在/etc/resolv.conf。重启后，此文件配置的dns又被自动修改为默认值。所以需要永久性修改DNS。方法如下：

	# vim /etc/resolvconf/resolv.conf.d/base
	nameserver 192.168.80.2
	nameserver 8.8.8.8

或者

	# vim /etc/resolvconf/resolv.conf.d/tail
	nameserver 192.168.80.2
	nameserver 8.8.8.8

3).重启networking服务使其生效

	/etc/init.d/networking restart

