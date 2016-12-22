sar是System Activity Reporter（系统活动情况报告）的缩写。sar工具将对系统当前的状态进行取样，然后通过计算数据和比例来表达系统的当前运行状态。它的特点是可以连续对系统取样，获得大量的取样数据；取样数据和分析的结果都可以存入文件，所需的负载很小。sar是目前Linux上最为全面的系统性能分析工具之一，可以从14个大方面对系统的活动进行报告，包括文件的读写情况、系统调用的使用情况、串口、CPU效率、内存使用状况、进程活动及IPC有关的活动等，使用也是较为复杂。

先要安装sysstat工具

	sudo apt-get install sysstat

修改配置文件 /etc/default/sysstat，将ENABLED修改为true

	ENABLED="true"
	
重启sysstat服务

	service sysstat restart


sar是查看操作系统报告指标的各种工具中，最为普遍和方便的；它有两种用法；

    追溯过去的统计数据（默认）
    周期性的查看当前数据

# 追溯过去的统计数据
默认情况下，sar从最近的0点0分开始显示数据；如果想继续查看一天前的报告；可以查看保存在/var/log/sysstat/下的sa日志； 使用sar工具查看:

sar -f /var/log/sysstat/sa28

# 参数

	用法: sar [ 选项 ] [ <时间间隔> [ <次数> ] ]
	主选项和报告：
		-B	分页状况
		-b	I/O 和传输速率信息状况
		-d	块设备状况
		-F [ MOUNT ]
			文件系统统计信息
		-H	交换空间利用率
		-I { <中断> | SUM | ALL | XALL }
			中断信息状况
		-m { <关键字> [,...] | ALL }
			电源管理统计信息
			关键字:
			CPU	CPU 频率
			FAN	风扇速度
	\t\tFREQ\tCPU 平均时钟频率
			IN	输入电压
			TEMP	设备温度
	\t\tUSB\t连接的USB 设备
		-n { <关键字> [,...] | ALL }
			网络统计信息
			关键字:
			DEV	网卡
			EDEV	网卡(错误)
			NFS	NFS 客户端
			NFSD	NFS 服务端
			SOCK	Sockets	(v4)
			IP	IP 流	(v4)
			EIP	IP 流	(v4) (错误)
			ICMP	ICMP 流	(v4)
			EICMP	ICMP 流	(v4) (错误)
			TCP	TCP 流	(v4)
			ETCP	TCP 流	(v4) (错误)
			UDP	UDP 流	(v4)
			SOCK6	Sockets	(v6)
			IP6	IP 流	(v6)
			EIP6	IP 流	(v6) (错误)
			ICMP6	ICMP 流	(v6)
			EICMP6	ICMP 流	(v6) (错误)
			UDP6	UDP 流	(v6)
			FC	Fibre channel HBAs
		-q	队列长度和平均负载
		-R	内存状况
		-r [ ALL ]
			内存利用率信息
		-S	交换空间利用率信息
		-u [ ALL ]
			CPU 利用率信息
		-v	内核表统计信息
		-W	交换信息
		-w	任务创建与系统转换信息
		-y	TTY 设备信息

# 查看CPU使用率
sar -u : 默认情况下显示的cpu使用率等信息就是sar -u；

	[root@ihorn-dev ~]# sar -u
	Linux 3.10.0-123.9.3.el7.x86_64 (ihorn-dev)     10/08/2016  _x86_64_    (4 CPU)

	12:00:01 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
	12:10:01 AM     all     44.50      0.00     29.75      0.05      0.00     25.70

显示的内容包括

	%user 用户模式下消耗的CPU时间的比例；
	%nice 通过nice改变了进程调度优先级的进程，在用户模式下消耗的CPU时间的比例
	%system 系统模式下消耗的CPU时间的比例；
	%iowait CPU等待磁盘I/O导致空闲状态消耗的时间比例；
	%steal 利用Xen等操作系统虚拟化技术，等待其它虚拟CPU计算占用的时间比例；
	%idle CPU空闲时间比例；
	
在所有的显示中，我们应主要注意**%iowait**和**%idle**，%wio的值过高，表示硬盘存在I/O瓶颈，%idle值高，表示CPU较空闲，如果%idle值高但系统响应慢时，有可能是CPU等待分配内存，此时应加大内存容量。%idle值如果持续低于10，那么系统的CPU处理能力相对较低，表明系统中最需要解决的资源是CPU。

# 查看平均负载
sar -q: 查看平均负载

指定-q后，就能查看运行队列中的进程数、系统上的进程大小、平均负载等；与其它命令相比，它能查看各项指标随时间变化的情况； 

	[root@ihorn-dev ~]# sar -q 1 60
	Linux 3.10.0-123.9.3.el7.x86_64 (ihorn-dev)     10/08/2016  _x86_64_    (4 CPU)

	03:37:27 PM   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked
	03:37:28 PM         0      1105      0.71      0.92      1.71         0
	03:37:29 PM         0      1105      0.71      0.92      1.71         0
	03:37:30 PM         0      1104      0.71      0.92      1.71         0

显示的内容包括

	runq-sz：运行队列的长度（等待运行的进程数）
	plist-sz：进程列表中进程（processes）和线程（threads）的数量
	ldavg-1：最后1分钟的系统平均负载 ldavg-5：过去5分钟的系统平均负载
	ldavg-15：过去15分钟的系统平均负载
	
load average大意表示当前CPU中有多少任务在排队等待，等待越多说明负载越高，跑数据库的服务器上，一般load值超过5的话，已经算是比较高的了。

引起load高的原因也可能有多种：

	某些进程/服务消耗更多CPU资源（服务响应更多请求或存在某些应用瓶颈）；
	发生比较严重的swap（可用物理内存不足）；
	发生比较严重的中断（因为SSD或网络的原因发生中断）；
	磁盘I/O比较慢（会导致CPU一直等待磁盘I/O请求）；


# 查看内存使用状况

sar -r： 指定-r之后，可查看物理内存使用状况；

	[root@ihorn-dev ~]# sar -r 1 10 
	Linux 3.10.0-123.9.3.el7.x86_64 (ihorn-dev) 10/08/2016 x86_64 (4 CPU)
	03:38:52 PM kbmemfree kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit  kbactive   kbinact   kbdirty
	03:38:53 PM   4712024  11557444     71.04    366220   3931208   9658120     59.36   9274640   1560712       436
	03:38:54 PM   4712024  11557444     71.04    366220   3931224   9658120     59.36   9274640   1560712       452
	03:38:55 PM   4712032  11557436     71.04    366220   3931228   9658120     59.36   9274676   1560720       464
	03:38:56 PM   4712032  11557436     71.04    366220   3931244   9658120     59.36   9274684   1560716       496
	03:38:57 PM   4712032  11557436     71.04    366220   3931244   9658120     59.36   9274692   1560716       50

显示的内容包括

	kbmemfree：这个值和free命令中的free值基本一致,所以它不包括buffer和cache的空间.
	kbmemused：这个值和free命令中的used值基本一致,所以它包括buffer和cache的空间.
	%memused：物理内存使用率，这个值是kbmemused和内存总量(不包括swap)的一个百分比.
	kbbuffers和kbcached：这两个值就是free命令中的buffer和cache.
	kbcommit：保证当前系统所需要的内存,即为了确保不溢出而需要的内存(RAM+swap).
	%commit：这个值是kbcommit与内存总量(包括swap)的一个百分比.

# 查看页面交换发生状况
sar -W：查看页面交换发生状况

页面发生交换时，服务器的吞吐量会大幅下降；服务器状况不良时，如果怀疑因为内存不足而导致了页面交换的发生，可以使用这个命令来确认是否发生了大量的交换；

	[root@ihorn-dev ~]# sar -W 1 10
	Linux 3.10.0-123.9.3.el7.x86_64 (ihorn-dev)     10/08/2016  _x86_64_    (4 CPU)

	03:40:37 PM  pswpin/s pswpout/s
	03:40:38 PM      0.00      0.00
	03:40:39 PM      0.00      0.00
	03:40:40 PM      0.00      0.00
	03:40:41 PM      0.00      0.00
	03:40:42 PM      0.00      0.00
	03:40:43 PM      0.00      0.00

显示的内容包括

	pswpin/s：每秒系统换入的交换页面（swap page）数量
	pswpout/s：每秒系统换出的交换页面（swap page）数量

# inode、文件和其他内核表监控
sar -v 10 3

	edgar@edgar-pc:~$ sar -v 10 3
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	22时44分40秒 dentunusd   file-nr  inode-nr    pty-nr
	22时44分50秒     58890      7360     76480        20
	22时45分00秒     58890      7360     76479        20
	22时45分10秒     58890      7360     76471        20
	平均时间:     58890      7360     76477        20

显示的内容包括

	dentunusd：目录高速缓存中未被使用的条目数量
	file-nr：文件句柄（file handle）的使用数量
	inode-nr：索引节点句柄（inode handle）的使用数量
	pty-nr：使用的pty数量

# 内存分页监控
sar -B 10 3

	edgar@edgar-pc:~$ sar -B 10 3
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	22时47分08秒  pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s pgscand/s pgsteal/s    %vmeff
	22时47分18秒      0.00      4.40    192.90      0.00    818.40      0.00      0.00      0.00      0.00
	22时47分28秒      0.00     14.00    484.00      0.00   1250.00      0.00      0.00      0.00      0.00
	22时47分38秒      0.00      6.80    767.00      0.00    831.40      0.00      0.00      0.00      0.00
	平均时间:      0.00      8.40    481.30      0.00    966.60      0.00      0.00      0.00      0.00

显示的内容包括

	pgpgin/s：表示每秒从磁盘或SWAP置换到内存的字节数(KB)
	pgpgout/s：表示每秒从内存置换到磁盘或SWAP的字节数(KB)
	fault/s：每秒钟系统产生的缺页数,即主缺页与次缺页之和(major + minor)
	majflt/s：每秒钟产生的主缺页数.
	pgfree/s：每秒被放入空闲队列中的页个数
	pgscank/s：每秒被kswapd扫描的页个数
	pgscand/s：每秒直接被扫描的页个数
	pgsteal/s：每秒钟从cache中被清除来满足内存需要的页个数
	%vmeff：每秒清除的页(pgsteal)占总扫描页(pgscank+pgscand)的百分比


**majflts/s**主要显示从硬盘交换区载入物理内存时的异常，如果这个值变高，那么我们可以说系统目前仅仅使用了内存(RAM)

**%vmeff **表示每秒扫描的页面数，如果说当它的值是100%时是正常情况，它是30%以下的时候就可以认为虚拟内存存在一些问题。0值表示在那个时候没有任何一个页面被扫描。

# I/O和传送速率监控
sar -b 10 3

	edgar@edgar-pc:~$ sar -b 10 3
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	22时50分23秒       tps      rtps      wtps   bread/s   bwrtn/s
	22时50分33秒      0.20      0.00      0.20      0.00      4.00
	22时50分43秒      0.00      0.00      0.00      0.00      0.00
	22时50分53秒      0.40      0.00      0.40      0.00     21.60
	平均时间:      0.20      0.00      0.20      0.00      8.53

显示的内容包括

	tps：每秒钟物理设备的 I/O 传输总量
	rtps：每秒钟从物理设备读入的数据总量
	wtps：每秒钟向物理设备写入的数据总量
	bread/s：每秒钟从物理设备读入的数据量，单位为 块/s
	bwrtn/s：每秒钟向物理设备写入的数据量，单位为 块/s

# 设备使用情况监控
sar -d 10 3 

	edgar@edgar-pc:~$ sar -d 10 3 
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	22时53分12秒       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
	22时53分22秒    dev8-0      0.50      4.00     18.40     44.80      0.01     14.40     11.20      0.56

	22时53分22秒       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
	22时53分32秒    dev8-0      0.60      0.00     14.40     24.00      0.00      6.67      6.67      0.40

	22时53分32秒       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
	22时53分42秒    dev8-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

	平均时间:       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
	平均时间:    dev8-0      0.37      1.33     10.93     33.45      0.00     10.18      8.73      0.32

显示的内容包括

	tps:每秒从物理磁盘I/O的次数.多个逻辑请求会被合并为一个I/O磁盘请求,一次传输的大小是不确定的.
	rd_sec/s:每秒读扇区的次数.
	wr_sec/s:每秒写扇区的次数.
	avgrq-sz:平均每次设备I/O操作的数据大小(扇区).
	avgqu-sz:磁盘请求队列的平均长度.
	await:从请求磁盘操作到系统完成处理,每次请求的平均消耗时间,包括请求队列等待时间,单位是毫秒(1秒=1000毫秒).
	svctm:系统处理每次请求的平均时间,不包括在请求队列中消耗的时间.
	%util:I/O请求占CPU的百分比,比率越大,说明越饱和.

avgqu-sz 的值较低时，设备的利用率较高
当%util的值接近 1% 时，表示设备带宽已经占满。

#要判断系统瓶颈问题，有时需几个 sar 命令选项结合起来
怀疑CPU存在瓶颈，可用 sar -u 和 sar -q 等来查看
怀疑内存存在瓶颈，可用 sar -B、sar -r 和 sar -W 等来查看
怀疑I/O存在瓶颈，可用 sar -b、sar -u 和 sar -d 等来查看

# 将结果保存到文件
sar -q 5 10 -o test

如果不带文件名 -o会默认将结果保存到/var/log/sysstat/sa22文件中，其中22是表示当天的日期（我是在22号操作的）

# 读取文件中的结果
sar -f test

# 查看某个CPU核的信息
sar -P ALL

	edgar@edgar-pc:~$ sar -P ALL 1 2
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	23时04分36秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
	23时04分37秒     all      0.75      0.00      0.25      0.00      0.00     98.99
	23时04分37秒       0      0.00      0.00      1.00      0.00      0.00     99.00
	23时04分37秒       1      0.00      0.00      0.00      0.00      0.00    100.00
	23时04分37秒       2      2.04      0.00      0.00      0.00      0.00     97.96
	23时04分37秒       3      0.00      0.00      0.00      0.00      0.00    100.00

	23时04分37秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
	23时04分38秒     all      1.49      0.00      1.24      1.00      0.00     96.27
	23时04分38秒       0      2.00      0.00      1.00      0.00      0.00     97.00
	23时04分38秒       1      0.98      0.00      1.96      0.98      0.00     96.08
	23时04分38秒       2      2.97      0.00      1.98      2.97      0.00     92.08
	23时04分38秒       3      0.99      0.00      0.00      0.00      0.00     99.01

	平均时间:     CPU     %user     %nice   %system   %iowait    %steal     %idle
	平均时间:     all      1.12      0.00      0.75      0.50      0.00     97.62
	平均时间:       0      1.00      0.00      1.00      0.00      0.00     98.00
	平均时间:       1      0.50      0.00      1.00      0.50      0.00     98.00
	平均时间:       2      2.51      0.00      1.01      1.51      0.00     94.97
	平均时间:       3      0.50      0.00      0.00      0.00      0.00     99.50

查看第2个核的信息

	edgar@edgar-pc:~$ sar -P 1 1 2
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	23时05分37秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
	23时05分38秒       1      2.02      0.00      0.00      0.00      0.00     97.98
	23时05分39秒       1      2.02      0.00      1.01      2.02      0.00     94.95
	平均时间:       1      2.02      0.00      0.51      1.01      0.00     96.46

# 网络
sar命令使用-n选项可以汇报网络相关信息，可用的参数包括：DEV、EDEV、SOCK和FULL。

	edgar@edgar-pc:~$ sar -n DEV 1 2
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	23时07分42秒     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
	23时07分43秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时07分43秒      wls1      1.00      0.00      0.05      0.00      0.00      0.00      0.00      0.00
	23时07分43秒      ens5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

	23时07分43秒     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
	23时07分44秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时07分44秒      wls1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时07分44秒      ens5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

	平均时间:     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
	平均时间:        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	平均时间:      wls1      0.50      0.00      0.03      0.00      0.00      0.00      0.00      0.00
	平均时间:      ens5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

如果你使用DEV关键字，那么sar将汇报和网络设备相关的信息，如lo，eth0或eth1等，显示的内容包括

	IFACE：就是网络设备的名称；
	rxpck/s：每秒钟接收到的包数目
	txpck/s：每秒钟发送出去的包数目
	rxbyt/s：每秒钟接收到的字节数
	txbyt/s：每秒钟发送出去的字节数
	rxcmp/s：每秒钟接收到的压缩包数目
	txcmp/s：每秒钟发送出去的压缩包数目
	txmcst/s：每秒钟接收到的多播包的包数目

如果你使用EDEV关键字，那么会针对网络设备汇报其失败情况

	edgar@edgar-pc:~$ sar -n EDEV 1 2
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	23时09分11秒     IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s  txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
	23时09分12秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时09分12秒      wls1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时09分12秒      ens5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

	23时09分12秒     IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s  txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
	23时09分13秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时09分13秒      wls1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	23时09分13秒      ens5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

	平均时间:     IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s  txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
	平均时间:        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	平均时间:      wls1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	平均时间:      ens5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

显示的内容包括

	rxerr/s：每秒钟接收到的损坏的包的数目
	txerr/s：当发送包时，每秒钟发生的错误数
	coll/s：当发送包时，每秒钟发生的冲撞(collisions)数（这个是在半双工模式下才有）
	rxdrop/s：由于缓冲区满，网络设备接收端，每秒钟丢掉的网络包的数目
	txdrop/s：由于缓冲区满，网络设备发送端，每秒钟丢掉的网络包的数目
	txcarr/s：当发送数据包时，每秒钟载波错误发生的次数
	rxfram/s：在接收数据包时，每秒钟发生的帧对齐错误的次数
	rxfifo/s：在接收数据包时，每秒钟缓冲区溢出错误发生的次数
	txfifo/s：在发送数据包时，每秒钟缓冲区溢出错误发生的次数

如果你使用SOCK关键字，则会针对socket连接进行汇报

	edgar@edgar-pc:~$ sar -n SOCK 1 2
	Linux 4.4.0-51-generic (edgar-pc) 	2016年12月22日 	_x86_64_	(4 CPU)

	23时10分28秒    totsck    tcpsck    udpsck    rawsck   ip-frag    tcp-tw
	23时10分29秒       684         5         6         0         0         0
	23时10分30秒       684         5         6         0         0         0
	平均时间:       684         5         6         0         0         0

显示的内容包括

	totsck：被使用的socket的总数目
	tcpsck：当前正在被使用于TCP的socket数目
	udpsck：当前正在被使用于UDP的socket数目
	rawsck：当前正在被使用于RAW的socket数目
	ip-frag：当前的IP分片的数目
	
# sar参数说明

	-A 汇总所有的报告
	-a 报告文件读写使用情况
	-B 报告附加的缓存的使用情况
	-b 报告缓存的使用情况
	-c 报告系统调用的使用情况
	-d 报告磁盘的使用情况
	-g 报告串口的使用情况
	-h 报告关于buffer使用的统计数据
	-m 报告IPC消息队列和信号量的使用情况
	-n 报告命名cache的使用情况
	-p 报告调页活动的使用情况
	-q 报告运行队列和交换队列的平均长度
	-R 报告进程的活动情况
	-r 报告没有使用的内存页面和硬盘块
	-u 报告CPU的利用率
	-v 报告进程、i节点、文件和锁表状态
	-w 报告系统交换活动状况
	-y 报告TTY设备活动状况
