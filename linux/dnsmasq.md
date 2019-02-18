CentOS

https://www.pcsuggest.com/configure-dnsmasq-caching-dns-server-linux/

http://blog.51cto.com/yanconggod/1977598

https://www.linux.com/learn/intro-to-linux/2018/2/advanced-dnsmasq-tips-and-tricks

```bash
yum install dnsmasq -y
```

默认会从/etc/hosts,/etc/resolv.conf读取文件。

/etc/hosts 会读取到本地域名配置文件（不支持泛域名）

/etc/resolv.conf 会读取上游DNS配置文件，如果读取不到/etc/hosts的地址解析，就会转发给resolv.conf进行解析地址

如果你想使用泛指域名的话，可以在/etc/dnsmasq.d编辑一个配置文件

```bash
[root@node dnsmasq.d]# cat /etc/dnsmasq.d/address.conf 
address=/xxxlocal.com/10.0.40.247
```

下面是网上找到的一个例子，仅作参考：

```bash
address=/www.taobao.com/127.0.0.1　　#正向解析
ptr-record=127.0.0.1.in-addr.arpa,www.taobao.com    #反向解析（可选）

address=/baidu.com/127.0.0.1    #泛域名解析
```

也可以在/etc/hosts中修改，也可以时间修改dnsmasq.conf文件

```
 [root@dlp ~]# vim /etc/hosts

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# add records
10.0.0.30   dlp.srv.world dlp 

[root@dlp ~]# systemctl restart dnsmasq 

```



设置防火墙

```
[root@dlp ~]# firewall-cmd --add-service=dns --permanent
success
[root@dlp ~]# firewall-cmd --reload
success 
```



最后可选项：

配置日志轮询

```bash
#配置日志轮转，编辑/etc/logrotate.d/dnsmasq
/var/log/dnsmasq.log {
    daily
    copytruncate
    missingok
    rotate 30
    compress
    notifempty
    dateext
    size 200M
}
```

重启服务

命令：

```bash
systemctl enable dnsmasq
systemctl start dnsmasq
systemctl restart dnsmasq
#查看dnsmasq是否启动正常，查看系统日志：
journalctl -u dnsmasq
```

测试dns缓存，要测试查询速度，请访问一个 dnsmasq 启动后没有访问过的网站，执行

```bash
[root@node ~]# dig archlinux.org | grep "Query time"
;; Query time: 212 msec
[root@node ~]# dig archlinux.org | grep "Query time"
;; Query time: 2 msec
```



再次运行命令，因为使用了缓存，查询时间应该大大缩短。100倍



http://heylinux.com/archives/2231.html

dnsmasq是一个轻量的支持DNS,DHCP以及TFTP协议的小工具，可以解决小范围的dns查询问题，譬如机房内网。

## 安装
1.安装
```
sudo apt-get install dnsmasq
```
2.配置hosts
```
172.19.XX.XX test1.edgar615.inner
172.19.XX.XX test2.edgar615.inner
```
3.配置上级DNS，负责公网的域名解析（不在内网使用的域名由它负责）
```
vim /etc/resolv.conf   #可以是当地运营商的或者阿里等其他公共DNS

nameserver 8.8.8.8 
nameserver 8.8.4.4
```
4.重启服务  
```
service dnsmasq restart
```
5.将内网所有客户端机器的DNS地址换成服务器的IP
```
nameserver 172.19.XX.XX
```
6. 测试内网DNS
```
ping test1.edgar615.inner
```
7.测试反解析
```
dig PTR 10.10.168.192.in-addr.arpa.
```

dnsmasq默认使用了/etc/hosts和/etc/resolv.conf，这样DNS本机也可以共享这些配置，但如果想要分开专门进行维护的话，可以在/etc/dnsmasq.conf中指定。
dnsmasq默认还集成了DHCP与TFTP服务器，默认如果不配置的话服务不会启动。
dnsmasq的优点在于快捷方便并易于维护，如果想实现比如多IP轮询，根据IP源做智能解析等高级功能，毫无疑问，安心上bind9吧。

**因为现在只要一台机器可以做测试，所以暂时无法测试内网DNS**



## ubuntu下安装dnsmasq

安装命令:

```
sudo apt-get install dnsmasq
```

帮助:

```
man dnsmasq
```

README位置

```
/etc/dnsmasq.d/README
```

默认配置位置:

```
/etc/dnsmasq.conf
```

重启方式:

```
sudo /etc/init.d/dnsmasq restart
```

或者

```
sudo service dnsmasq restart
```

查看默认启动命令:

```
ps aux | grep dnsmasq
```

看到下面的输出:

```
$ ps aux | grep dnsmasq
nobody    1245  0.0  0.0  35240  1528 ?        S    09:56   0:00 /usr/sbin/dnsmasq --no-resolv --keep-in-foreground --no-hosts --bind-interfaces --pid-file=/run/sendsigs.omit.d/network-manager.dnsmasq.pid --listen-address=127.0.1.1 --conf-file=/var/run/NetworkManager/dnsmasq.conf --cache-size=0 --proxy-dnssec --enable-dbus=org.freedesktop.NetworkManager.dnsmasq --conf-dir=/etc/NetworkManager/dnsmasq.d
dnsmasq   5977  0.0  0.0  35240   908 ?        S    10:40   0:00 /usr/sbin/dnsmasq -x /var/run/dnsmasq/dnsmasq.pid -u dnsmasq -r /var/run/dnsmasq/resolv.conf -7 /etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new
```

nobody用户的输出不用管, 其中

```
-r /var/run/dnsmasq/resolv.conf
```

是dnsmasq用到的dns, 我们运营商提供的dns,例如

```
nameserver 180.76.76.76
nameserver 114.114.114.114
```







## 如何使用本地DNS加速网络访问

本文作者：dogfox ibm7279@126.com

适用版本：ubuntu fasty & hardy
安装 dnsmasq

```
sudo apt-get install dnsmasq
```

配置 dnsmasq

man dnsmasq

其中有这么一段描述： In order to configure dnsmasq to act as cache for the host on which it is running, put "nameserver 127.0.0.1" in /etc/resolv.conf to force local processes to send queries to dnsmasq. Then either specify the upstream servers directly to dnsmasq using --server options or put their addresses real in another file, say /etc/resolv.dnsmasq and run dnsmasq with the -r /etc/resolv.dnsmasq option.

大意是如果想让dnsmasq作为dns缓存，需要将“nameserver 127.0.0.1”放到/etc/resolv.conf文件中，通常是第一条非注释语句，然后将真正的dns服务器信息放到另外一个文件中，如“/etc/resolv.dnsmasq”，最后执行命令：

```
dnsmasq -r /etc/resolv.dnsmasq
```

第一步

按照帮助文档的提示，需要修改/etc/resolv.conf文件。 可以手动修改，如使用vi，可以将原有的内容全部注释，然后在第一行写上

```
nameserver 127.0.0.1；
```

第二步

在/etc目录下新建resolv.dnsmasq文件。文件的内容为DNS服务器的地址，是真正的DNS服务器，如我的文件内容是：

```
nameserver 210.47.0.1
nameserver 202.98.5.68
```

第三步

可以不按帮助文档所说的执行“dnsmasq -r /etc/resolv.dnsmasq”命令，如果这样，岂不是每次都得在命令行里输入，非常麻烦，当然，可以考虑把这个命令写入“/etc/rc.local”文件中，让系统每次启动时帮你运行。 我所使用的方法是编辑“/etc/dnsmasq.conf”文件。找到下面这一项

#resolv-file=

用下面的一条语句替换

```
resolv-file=/etc/resolv.dnsmasq
```

其实也就是执行dnsmasq命令中-r参数后面的内容。

编辑 /etc/dhcp3/dhclient.conf

找到下面这一项

#prepend domain-name-servers 127.0.0.1;

将前面的“#”删除。这么做的目的是为了在使用自动连接时，能在/etc/resolv.conf文件的第一行添加上“nameserver 127.0.0.1”，这样，dns缓存依然有效

编辑 /etc/ppp/peers/dsl-provider

可能有的系统没有“/etc/ppp/peers/dsl-provider”文件，而是“/etc/ppp/peers/provider”文件，找到下面这一项

usepeerdns

在前面增加“#”，也就是把这条语句注释掉。以防resolv.conf的设置被pppoe复盖。

对于12.04版本 由于该版本已经安装dnsmasq-base，则必须先修改/etc/NetworkManager/NetworkManager.conf文件，注释dns=dnsmasq 修改/etc/default/dnsmasq文件，取消IGNORE_RESOLVCONF=yes注释
测试

重启服务：

sudo /etc/init.d/dnsmasq restart
或者 sudo service dnsmasq restart

测试，执行两次就能看出查询时间的差异了：

dig g.cn