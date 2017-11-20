# AOF
AOF以独立日志的方式记录每次写命令，重启时再重新执行AOF文件中的命令达到恢复数据的目的。AOF的主要作用是解决了数据持久化的实时性。

## 开启AOF

	appendonly yes #默认为no
	appendfilename "appendonly.aof" #AOF文件名，路径通过dir指定

AOF步骤：

- 命令追加：服务器在执行完一个写命令后，会以协议的格式把其追加到aof_buf缓冲区末尾；
- 文件写入：redis服务器进程就是一个事件循环，在每次事件循环结束，会根据配置文件中的appednfsync属性值决定是否将aof_buf中的数据写入到AOF文件中；
- 文件同步：将内存缓冲区的数据写到磁盘；（由于OS的特性导致）

## 文件同步
redis提供了多种AOF缓冲区同步文件策略，有appendfsync控制

    # appendfsync always #命令写入aof_buf后调用系统fsync同步到AOF文件，fsync完成后线程返回
    appendfsync everysec #命令写入aof_buf后调用系统write操作，write完成后线程返回，fsync同步文件操作由专门的线程没秒调用一次
    # appendfsync no #令写入aof_buf后调用系统write操作，不对AOF文件做fsyunc同步，同步磁盘操作由操作系统负责，通常同步周期最长30秒

## 重写机制
随着运行时间的流逝， AOF 文件会变得越来越大。为了解决这的问题， Redis 需要对 AOF 文件进行重写（rewrite）： 创建一个新的 AOF 文件来代替原有的 AOF 文件， 新 AOF 文件和原有 AOF 文件保存的数据库状态完全一样， 但新 AOF 文件的体积小于等于原有 AOF 文件的体积。
AOF重写降低了文件占用空间，同时更小的AOF文件可以更快地被redis加载

### 手动触发
**bgrewriteaof命令**

### 自动触发

    auto-aof-rewrite-percentage 100 # 当前AOF文件空间和上一次重写后AOF文件空间的比值
    auto-aof-rewrite-min-size 64mb #运行AOF重写文件最小体积，默认为64M

## 其他配置
重写时每次批量写入硬盘的数据量

    # When a child rewrites the AOF file, if the following option is enabled
    # the file will be fsync-ed every 32 MB of data generated. This is useful
    # in order to commit the file to the disk more incrementally and avoid
    # big latency spikes.
    aof-rewrite-incremental-fsync yes

## 重启加载
AOF持久化开启并存在AOF文件时，优先加载AOF文件。AOF关闭或者AOF文件不存在时，加载RDB文件

redis-check-aof --fix命令用于修复AOF文件的错误

AOF文件可能存在结尾不完整的情况，比如机器突然掉电导致AOF尾部文件命令写入不全，redis提供了aof-load-truncated配置来兼容这种情况，默认开启，加载AOF文件时，当遇到此问题时会忽略并继续启动

	aof-load-truncated yes

# 问题定位
当redis做RDB或AOF重写时，一个必不可少的操作就是执行fork操作创建应子进程。对于大多数操作系统来说fork是一个重量级操作。虽然fork创建的子进程不需要拷贝父进程的物理内存空间，但是会复制父进程的空间内存表。例如对于10GB的redis进程，需要复制大约20MB的内存页表，因此fork操作耗时跟进程总内存量息息相关
**fork耗时跟内存量成正比，建议控制每个redis实例的内存**

http://blog.csdn.net/shreck66/article/details/47039937

对于运行在一个linux/AMD64系统上的实例来说，内存会按照每页4KB的大小分页。为了实现虚拟地址到物理地址的转换，每一个进程将会存储一个分页表（树状形式表现），分页表将至少包含一个指向该进程地址空间的指针。所以一个空间大小为24GB的redis实例，需要的分页表大小为  24GB/4KB*8 = 48MB。