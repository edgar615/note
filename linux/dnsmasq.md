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