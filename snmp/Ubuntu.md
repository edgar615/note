ubuntu的snmp配置

http://xpleaf.blog.51cto.com/9315560/1757333

## 安装

安装


我们需要安装下面三个软件包：

    snmpd：snmp服务端软件
    snmp：snmp客户端软件
    snmp-mibs-downloader：用来下载更新本地mib库的软件

虽然最后我会用另一台主机来进行远程的测试，不过刚开始时，还是在服务端也把snmp客户端软件安装好，方便做一些基本的测试。

执行下面的命令安装这三个软件：
	
	ubuntu@leaf:~$ sudo apt-get install snmpd snmp snmp-mibs-downloader

需要注意的是，在安装snmp-mibs-downloader的过程中，程序会帮我们自动下载mib库，并保存在/usr/share/mibs目录中：
	
	ubuntu@leaf:/usr/share/mibs$ ls
	iana  ietf

如果发现没有些目录或文件的话，在安装完snmp-mibs-downloader后也可以手动执行下面的命令来下载mib库：
	
	ubuntu@leaf:~$ sudo download-mibs

会有很多输出信息。

这样的话，第一步安装工作也就完成了。

## 配置


其实在安装完snmpd软件后，系统是为我们自动开启了这个服务的：

	ubuntu@leaf:~$ sudo service snmpd status
 	* snmpd is running

在开始配置前，我们先来进行一些简单的测试，看看服务是否正常：
	
	ubuntu@leaf:~$ snmpwalk -v 2c -c public localhost 1.3.6.1.2.1.1.1
	iso.3.6.1.2.1.1.1.0 = STRING: "Linux leaf 4.2.0-34-generic #39-Ubuntu SMP Thu Mar 10 22:13:01 UTC 2016 x86_64

**配置节点**

修改/etc/snmp/snmpd.conf文件，大概在45行，将下面的两行注释掉：
	
	view   systemonly  included   .1.3.6.1.2.1.1
	view   systemonly  included   .1.3.6.1.2.1.25.1

增加下面一行：

	view   systemonly  included   .1

这样的话，我们就可以获取更多的节点信息，因为如果不这样做，我们能够获取的信息，仅仅是上面两个注释掉的节点所包含的信息。
修改之后，重启snmp服务，再使用命令观察一下：
	
	ubuntu@leaf:/etc/snmp$ sudo service snmpd restart
	xpleaf@leaf:/etc/snmp$ snmpwalk -v 2c -c public localhost .1.3.6.1.4.1.2021.4.3.0
	iso.3.6.1.4.1.2021.4.3.0 = INTEGER: 1950716

**配置MIB库**

虽然上面已经可以正常获取我们想要的信息，但是输出结果很不直观，这时我们配置一下MIB库就可以了，不过需要注意的是，这个配置是对客户端软件的配置（只不过现在还是在我的同一台服务器主机上进行操作）。

修改/etc/snmp/snmp.conf配置文件，将下面这一行注释掉：

	mibs :

然后重启snmp服务，再通过命令观察：
	
	ubuntu@leaf:/etc/snmp$ sudo service snmpd restart
	ubuntu@leaf:/etc/snmp$ snmpwalk -v 2c -c public localhost .1.3.6.1.4.1.2021.4.3.0
	UCD-SNMP-MIB::memTotalSwap.0 = INTEGER: 1950716 kB

**配置共同体**

其实所谓共同体，把它理解为一个密码就行了，前面我们在使用snmpwalk命令获取主机的信息时，有一个-c public的参数，其实就是指定了这个共同体为public，这是默认的配置，当然在实际中，我们不可能使用默认的值，因此需要把它修改一下。

修改配置文件/etc/snmp/snmpd.conf，大概在52行，将下面的两行：
	
	rocommunity public  default    -V systemonly
	rocommunity6 public  default   -V systemonly

那么这里就把共同体修改为xpleaf123了，重启snmp服务，通过命令观察一下：
	
	ubuntu@leaf:/etc/snmp$ snmpwalk -v 2c -c public localhost memTotalReal.0
	Timeout: No Response from localhost
	ubuntu@leaf:/etc/snmp$ snmpwalk -v 2c -c xpleaf123 localhost memTotalReal.0
	UCD-SNMP-MIB::memTotalReal.0 = INTEGER: 8093524 kB

可以看到第一次获取信息不成功，因为我们已经更新了共同体，旧的public将不能再使用，否则认证失败就无法获取snmp提供的主机信息。

**允许远程主机访问**

默认情况下，snmp服务只是对本地开启，是无法通过远程获取该主机的snmp信息的：

	ubuntu@leaf:/etc/snmp$ sudo netstat -antup | grep 161  
	udp        0      0 127.0.0.1:161           0.0.0.0:*                           11615/snmpd

可以看到，161端口只对本机开放（161端口号是snmp服务的端口号），我们需要修改一下，让snmp服务对外开放。

修改/etc/snmp/snmpd.conf配置文件，大概在15行，将下面一行注释掉：
	
	agentAddress  udp:127.0.0.1:161

同时去掉下面这一行的注释：
	
	#agentAddress udp:161,udp6:[::1]:161

重新启动snmp服务，再通过命令观察：
	
	ubuntu@leaf:/etc/snmp$ sudo netstat -antup | grep 161
	udp        0      0 0.0.0.0:161             0.0.0.0:*                           11656/snmpd     
	udp6       0      0 ::1:161                 :::*                                11656/snmpd

（远程）测试


在服务器本地我们已经做过测试，并且没有问题，下面我们要做的是在远程主机进行测试。

我另一台远程主机上的操作系统也是Ubuntu 15.04，并且已经安装了snmp客户端软件和mib库下载软件，同时配置了MIB库，下面就直接进行远程的测试：
	
	xpleaf@leaf:~$ snmpwalk -v 2c -c xpleaf123 115.159.*.* memTotalSwap.0
	UCD-SNMP-MIB::memTotalSwap.0 = INTEGER: 1950716 kB
	xpleaf@leaf:~$ snmpwalk -v 2c -c xpleaf123 115.159.*.* memTotalReal.0
	UCD-SNMP-MIB::memTotalReal.0 = INTEGER: 8093524 kB
	xpleaf@leaf:~$ snmpwalk -v 2c -c xpleaf123 115.159.*.* .1.3.6.1.4.1.2021.9.1.6.1
	UCD-SNMP-MIB::dskTotal.1 = INTEGER: 8123832

可以看到，测试完全没有问题！并且获取的值和前面有服务器本地得到的一样。

当然，如果你发现还是获取不了的，那么你就需要考虑一下在服务器的主机上防火墙的设置有没有问题了。