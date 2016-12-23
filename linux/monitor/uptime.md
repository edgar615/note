http://www.ruanyifeng.com/blog/2011/07/linux_load_average_explained.html

Uptimed 堪称 uptime 命令的守护程序版本，利用它你可以将 Linux 系统每次的 uptime 记录起来，并根据时间长短进行排名。

uptime命令可以显示系统已经运行了多长时间，信息显示依次为：现在时间、系统已经运行了多长时间、目前有多少登陆用户、系统在过去的1分钟、5分钟和15分钟内的平均负载。

# 语法

	[root@ihorn-dev ~]# uptime -h
	
	Usage:
	 uptime [options]
	
	Options:
	 -p, --pretty   show uptime in pretty format
	 -h, --help     display this help and exit
	 -s, --since    system up since
	 -V, --version  output version information and exit


# 示例

	[root@ihorn-dev ~]# uptime
	 13:42:09 up 88 days,  2:14,  4 users,  load average: 0.25, 0.23, 0.23

显示内容说明：
	
	13:42:09          	//系统当前时间
	up 88 days,  2:14   //主机已运行时间,时间越大，说明你的机器越稳定。
	12 user             //用户连接数，是总连接数而不是用户数
	load average        // 系统平均负载，统计最近1，5，15分钟的系统平均负载

那么什么是系统平均负载呢？ 系统平均负载是指在特定时间间隔内运行队列中的平均进程数。

"load average"的值越低，比如等于0.2或0.3，就说明电脑的工作量越小，系统负荷比较轻。

1个CPU表明系统负荷可以达到1.0,2个CPU表明系统负荷可以达到2.0，此时每个CPU都达到100%的工作量。推广开来，n个CPU的电脑，可接受的系统负荷最大为n.0。

在系统负荷方面，多核CPU与多CPU效果类似，所以考虑系统负荷的时候，必须考虑这台电脑有几个CPU、每个CPU有几个核心。然后，把系统负荷除以总的核心数，只要每个核心的负荷不超过1.0，就表明电脑正常运行。

# 最佳观察时长

"load average"一共返回三个平均值----1分钟系统负荷、5分钟系统负荷，15分钟系统负荷，----应该参考哪个值？

如果只有1分钟的系统负荷大于1.0，其他两个时间段都小于1.0，这表明只是暂时现象，问题不大。

如果15分钟内，平均系统负荷大于1.0（调整CPU核心数之后），表明问题持续存在，不是暂时现象。所以，你应该主要观察"15分钟系统负荷"，将它作为电脑正常运行的指标。