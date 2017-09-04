
https://linux.cn/article-2352-1.html

http://cn.linux.vbird.org/linux_basic/0440processcontrol.php#top

top命令是Linux下常用的性能分析工具，能够实时显示系统中各个进程的资源占用状况，类似于Windows的任务管理器。top是一个动态显示过程,即可以通过用户按键来不断刷新当前状态.如果在前台执行该命令,它将独占前台,直到用户终止该程序为止.比较准确的说,top命令提供了实时的对系统处理器的状态监视.它将显示系统中CPU最“敏感”的任务列表.该命令可以按CPU使用.内存使用和执行时间对任务进行排序；而且该命令的很多特性都可以通过交互式命令或者在个人定制文件中进行设定。


语法

	[root@ihorn-dev ~]# top -h
	  procps-ng version 3.3.9
	Usage:
	  top -hv | -bcHiOSs -d secs -n max -u|U user -p pid(s) -o field -w [cols]

参数

	-b：以批处理模式操作； 
	-c：显示完整的治命令； 
	-d：屏幕刷新间隔时间； 
	-I：忽略失效过程； 
	-s：保密模式； 
	-S：累积模式； 
	-i<时间>：设置间隔时间； 
	-u<用户名>：指定用户名； 
	-p<进程号>：指定进程； 
	-n<次数>：循环显示的次数。

交互命令

	h：显示帮助画面，给出一些简短的命令总结说明；
	k：终止一个进程； 
	i：忽略闲置和僵死进程，这是一个开关式命令； 
	q：退出程序； 
	r：重新安排一个进程的优先级别； 
	S：切换到累计模式； 
	s：改变两次刷新之间的延迟时间（单位为s），如果有小数，就换算成ms。输入0值则系统将不断刷新，默认值是5s； 
	f或者F：从当前显示中添加或者删除项目； 
	o或者O：改变显示项目的顺序； 
	l：切换显示平均负载和启动时间信息；
	m：切换显示内存信息； 
	t：切换显示进程和CPU状态信息； 
	c：切换显示命令名称和完整命令行； 
	M：根据驻留内存大小进行排序； 
	P：根据CPU使用百分比大小进行排序； 
	T：根据时间/累计时间进行排序； 
	w：将当前设置写入~/.toprc文件中。


示例：

	[root@ihorn-dev]# top
	top - 14:58:36 up 12 days,  3:30,  5 users,  load average: 0.09, 0.11, 0.19
	Tasks: 194 total,   1 running, 193 sleeping,   0 stopped,   0 zombie
	%Cpu(s):  1.8 us,  0.8 sy,  0.0 ni, 96.9 id,  0.4 wa,  0.0 hi,  0.1 si,  0.0 st
	KiB Mem:  16269468 total, 10890328 used,  5379140 free,   366196 buffers
	KiB Swap:        0 total,        0 used,        0 free.  3264548 cached Mem
	
	  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                                                                                                              
	11718 root      20   0 1215464  72080   9988 S   5.0  0.4 662:01.56 node /alidata/s                                                                                                                      
	 2636 root      20   0 5508804 1.155g  11220 S   2.0  7.4   2538:52 java                                                                                                                                 
	 3483 root      20   0 4076364 615016  15572 S   1.7  3.8  10:51.64 java                                                                                                                                 
	 1410 root      20   0    1544    576    500 S   0.7  0.0   8:46.74 aliyun-service                                                                                                                       
	 3577 root      20   0 3988360 598268  15708 S   0.7  3.7   9:39.25 java                                                                                                                                 
	 3783 root      20   0 3925748 360156  15724 S   0.7  2.2  51:17.43 java                                                                                                                                 
	 3924 root      20   0 3918884 336540  15252 S   0.7  2.1   1:11.29 java                                                                                                                                 
	15040 root      20   0 3934708 372284  11760 S   0.7  2.3 366:27.80 java

第一行(top...)：这一行显示的资讯分别为：

    目前的时间，亦即是 17:03:09 那个项目；
    启动到目前为止所经过的时间，亦即是 up 12days, 3:30；
    已经登陆系统的使用者人数，亦即是 5 users项目；
    系统在 1, 5, 15 分钟的平均工作负载。系统平均要负责运行几个程序(工作)的意思。 越小代表系统越闲置，若高於 1 得要注意你的系统程序是否太过繁复了  

第二行(Tasks...)：显示的是目前程序的总量与个别程序在什么状态(running, sleeping, stopped, zombie)。 比较需要注意的是最后的 zombie 那个数值，如果不是 0 ！好好看看到底是那个 process 变成僵尸了吧？ 


第三行(Cpus...)：显示的是 CPU 的整体负载，每个项目可使用 ? 查阅。需要特别注意的是 %wa ，那个项目代表的是 I/O wait， 通常你的系统会变慢都是 I/O 产生的问题比较大！因此这里得要注意这个项目耗用 CPU 的资源喔！ 另外，如果是多核心的设备，可以按下数字键『1』来切换成不同 CPU 的负载率。


    us, user： 运行(未调整优先级的) 用户进程的CPU时间
    sy，system: 运行内核进程的CPU时间
    ni，niced：运行已调整优先级的用户进程的CPU时间
    wa，IO wait: 用于等待IO完成的CPU时间
    hi：处理硬件中断的CPU时间
    si: 处理软件中断的CPU时间
    st：这个虚拟机被hypervisor偷去的CPU时间（译注：如果当前处于一个hypervisor下的vm，实际上hypervisor也是要消耗一部分CPU处理时间的）。

-


	top - 15:04:10 up 12 days,  3:36,  5 users,  load average: 0.07, 0.13, 0.18
	Tasks: 195 total,   1 running, 194 sleeping,   0 stopped,   0 zombie
	%Cpu0  :  2.7 us,  0.7 sy,  0.0 ni, 96.3 id,  0.0 wa,  0.0 hi,  0.3 si,  0.0 st
	%Cpu1  :  3.0 us,  0.7 sy,  0.0 ni, 96.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
	%Cpu2  :  2.4 us,  0.3 sy,  0.0 ni, 97.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
	%Cpu3  :  4.4 us,  0.3 sy,  0.0 ni, 95.0 id,  0.0 wa,  0.0 hi,  0.3 si,  0.0 st
	KiB Mem:  16269468 total, 10941652 used,  5327816 free,   366196 buffers
	KiB Swap:        0 total,        0 used,        0 free.  3269396 cached Mem

第四行与第五行：表示目前的实体内存与虚拟内存 (Mem/Swap) 的使用情况。 再次重申，要注意的是 swap 的使用量要尽量的少！如果 swap 被用的很大量，表示系统的实体内存实在不足！

物理内存显示如下:全部可用内存、已使用内存、空闲内存、缓冲内存。相似地：交换部分显示的是：全部、已使用、空闲和缓冲交换空间。

	Mem: 191272k total 	物理内存总量
	173656k used 	使用的物理内存总量
	17616k free 	空闲内存总量
	22052k buffers 	用作内核缓存的内存量
	Swap: 192772k total 	交换区总量
	0k used 	使用的交换区总量
	192772k free 	空闲交换区总量
	123988k cached 	缓冲的交换区总量。
	内存中的内容被换出到交换区，而后又被换入到内存，但使用过的交换区尚未被覆盖，
	该数值即为这些内容已存在于内存中的交换区的大小。
	相应的内存再次被换出时可不必再对交换区写入。

**注意:**

（一）：used这个统计量，并不是用户线程占用内存之和，而是Linux系统总共消耗的内存，用户线程是“寄生”于Linux OS之上的；
（二）：对于free统计量，是“干净的”可以直接分配的内存，但是cached和buffered这两种状态的内存，主要是映射到磁盘的缓冲，也能够被继续分配
（三）：真正被使用的内存real free memory ＝ used - buffers - cached；真正可用的内存real free memory = total - real free memory

使用free命令一样

	[root@ihorn-product ~]# free -h
	             total       used       free     shared    buffers     cached
	Mem:           15G        15G       189M       328M       274M       8.4G
	-/+ buffers/cache:       6.7G       8.8G
	Swap:           0B         0B         0B

第六行：这个是当在 top 程序当中输入命令时，显示状态的地方。

至於 top 下半部分的画面，则是每个 process 使用的资源情况。比较需要注意的是：

    PID ：进程ID！
    USER：该 process 所属的使用者；
    PR ：Priority 的简写，程序的优先运行顺序，越小越早被运行；
    NI ：Nice 的简写，与 Priority 有关，也是越小越早被运行；
    %CPU：CPU 的使用率；
    %MEM：内存的使用率；
    TIME+：CPU 使用时间的累加；

更改显示内容

通过 f 键可以选择显示的内容。按 f 键之后会显示列的列表，按 a-z 即可显示或隐藏对应的列，最后按回车键确定。

按 o 键可以改变列的显示顺序。按小写的 a-z 可以将相应的列向右移动，而大写的 A-Z 可以将相应的列向左移动。最后按回车键确定。

按大写的 F 或 O 键，然后按 a-z 可以将进程按照相应的列进行排序。而大写的 R 键可以将当前的排序倒转

	a 	PID 	进程id
	b 	PPID 	父进程id
	c 	RUSER 	Real user name
	d 	UID 	进程所有者的用户id
	e 	USER 	进程所有者的用户名
	f 	GROUP 	进程所有者的组名
	g 	TTY 	启动进程的终端名。不是从终端启动的进程则显示为 ?
	h 	PR 	进程的调度优先级。这个字段的一些值是'rt'。这意味这这些进程运行在实时态。
	i 	NI 	进程的nice值（优先级）。越小的值意味着越高的优先级。
	j 	P 	最后使用的CPU，仅在多CPU环境下有意义
	k 	%CPU 	上次更新到现在的CPU时间占用百分比
	l 	TIME 	进程使用的CPU时间总计，单位秒
	m 	TIME+ 	任务启动后到现在所使用的全部CPU时间，精确到百分之一秒
	n 	%MEM 	进程使用的物理内存百分比
	o 	VIRT 	进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
	p 	SWAP 	进程使用的虚拟内存中，被换出的大小，单位kb。
	q 	RES 	驻留内存大小。驻留内存是任务使用的非交换物理内存大小。单位kb。RES=CODE+DATA
	r 	CODE 	可执行代码占用的物理内存大小，单位kb
	s 	DATA 	可执行代码以外的部分(数据段+栈)占用的物理内存大小，单位kb
	t 	SHR 	进程使用的共享内存，单位kb
	u 	nFLT 	页面错误次数
	v 	nDRT 	最后一次写入到现在，被修改过的页面数。
	w 	S 	进程状态。	D=不可中断的睡眠状态	R=运行	S=睡眠	T=跟踪/停止	Z=僵尸进程
	x 	COMMAND 	运行进程所使用的命令
	y 	WCHAN 	若该进程在睡眠，则显示睡眠中的系统函数名
	z 	Flags 	任务标志，参考 sched.h

top 默认使用 CPU 使用率 (%CPU) 作为排序的重点，如果你想要使用内存使用率排序，则可以按下『M』， 若要回复则按下『P』即可。如果想要离开 top 则按下『 q 』吧！如果你想要将 top 的结果输出成为文件时， 可以这样做：

范例二：将 top 的资讯进行 2 次，然后将结果输出到 /tmp/top.txt
[root@www ~]# top -b -n 2 > /tmp/top.txt


top命令默认在一个特定间隔(3秒)后刷新显示。要手动刷新，用户可以输入回车或者空格。

### 'A': 切换交替显示模式

这个命令在全屏和交替模式间切换。在交替模式下会显示4个窗口（译注：分别关注不同的字段）:

    Def （默认字段组）
    Job （任务字段组）
    Mem （内存字段组）
    Usr （用户字段组）

这四组字段共有一个独立的可配置的概括区域和它自己的可配置任务区域。4个窗口中只有一个窗口是当前窗口。当前窗口的名称显示在左上方。（译注：只有当前窗口才会接受你键盘交互命令）

我们可以用'a'和'w'在4个 窗口间切换。'a'移到后一个窗口，'w'移到前一个窗口。用'g'命令你可以输入一个数字来选择当前窗口。

### ‘B’: 触发粗体显示
一些重要信息会以加粗字体显示。这个命令可以切换粗体显示。

### ‘d’ 或‘s’: 设置显示的刷新间隔
当按下'd'或's'时，你将被提示输入一个值（以秒为单位），它会以设置的值作为刷新间隔。如果你这里输入了


# 执行 sar -d 确认磁盘I/O是否真的较大：

	sar -d 1
	Linux 3.10.0-123.9.3.el7.x86_64 (ihorn-dev) 	10/08/2016 	_x86_64_	(4 CPU)
	
	03:24:06 PM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
	03:24:07 PM  dev253-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	03:24:07 PM dev253-16     35.00      0.00  27568.00    787.66      2.79     79.71      3.00     10.50
	03:24:07 PM  dev252-0     45.00      0.00  27568.00    612.62      2.81     62.47      2.33     10.50
	03:24:07 PM  dev252-1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	03:24:07 PM  dev252-2      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	03:24:07 PM  dev252-3      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	03:24:07 PM  dev252-4      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
	03:24:07 PM  dev252-5      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

# 再利用 iotop 确认到底哪些进程消耗的磁盘I/O资源最多：



## 找到最耗CPU的进程

top -c然后用P（大写p）按CPU使用率排序

## 找到最耗CPU的线程

top -Hp <PID> 线程一个进程的线程运行信息

P(大写P)按CPU使用率排序

## 将线程PID转换为16进制

printf "%x\n" <PID>
	
	114f

查看堆栈
pstack，jstatck

	$ jstack 4420 | grep '114f' -C5 --color
	   java.lang.Thread.State: RUNNABLE
	
	"C1 CompilerThread2" #7 daemon prio=9 os_prio=0 tid=0x00007ff6280b2800 nid=0x1150 waiting on condition [0x0000000000000000]
	   java.lang.Thread.State: RUNNABLE
	
	"C2 CompilerThread1" #6 daemon prio=9 os_prio=0 tid=0x00007ff6280b0800 nid=0x114f waiting on condition [0x0000000000000000]
	   java.lang.Thread.State: RUNNABLE
	
	"C2 CompilerThread0" #5 daemon prio=9 os_prio=0 tid=0x00007ff6280ad800 nid=0x114e waiting on condition [0x0000000000000000]
	   java.lang.Thread.State: RUNNABLE