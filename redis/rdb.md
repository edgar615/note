RDB持久化是把当前进程数据生成快照保存到硬盘的过程，触发RDB持久化过程分为手动触发和被动触发

http://redisbook.readthedocs.io/en/latest/internal/rdb.html

## 手动触发

**save命令**

阻塞当前redis服务器，直到RDB过程完成为止。
只有在上一个 SAVE 执行完毕、 Redis 重新开始接受请求之后， 新的 SAVE 、 BGSAVE 或 BGREWRITEAOF 命令才会被处理。

执行save命令时对应的redis日志如下：

	13737:M 20 Nov 14:18:39.398 * DB saved on disk

**bgsave命令**

Redis进程执行fork操作创建子进程，RDB持久化过程由子进程复杂，完成后自动结束，阻塞只发生在fork阶段，一般时间很短.

执行bgsave命令时，日志如下

    13737:M 20 Nov 14:20:01.823 * Background saving started by pid 13756
    13756:C 20 Nov 14:20:01.827 * DB saved on disk
    13756:C 20 Nov 14:20:01.827 * RDB: 6 MB of memory used by copy-on-write
    13737:M 20 Nov 14:20:01.927 * Background saving terminated with success

在执行 SAVE 命令之前， 服务器会检查 BGSAVE 是否正在执行当中， 如果是的话， 服务器就不调用 rdbSave ， 而是向客户端返回一个出错信息， 告知在 BGSAVE 执行期间， 不能执行 SAVE 。
这样做可以避免 SAVE 和 BGSAVE 调用的两个 rdbSave 交叉执行， 造成竞争条件。
另一方面， 当 BGSAVE 正在执行时， 调用新 BGSAVE 命令的客户端会收到一个出错信息， 告知 BGSAVE 已经在执行当中。
BGREWRITEAOF 和 BGSAVE 不能同时执行：

    如果 BGSAVE 正在执行，那么 BGREWRITEAOF 的重写请求会被延迟到 BGSAVE 执行完毕之后进行，执行 BGREWRITEAOF 命令的客户端会收到请求被延迟的回复。
    如果 BGREWRITEAOF 正在执行，那么调用 BGSAVE 的客户端将收到出错信息，表示这两个命令不能同时执行。

BGREWRITEAOF 和 BGSAVE 两个命令在操作方面并没有什么冲突的地方， 不能同时执行它们只是一个性能方面的考虑： 并发出两个子进程， 并且两个子进程都同时进行大量的磁盘写入操作， 这怎么想都不会是一个好主意。

## 自动触发
1. 通过save相关配置，可以实现RDB的自动持久化机制(bgsave)

    save 900 1 #在900s（15m）之后，至少有1个key发生变化
    save 300 10 #在300s（5m）之后，至少有10个key发生变化
    save 60 10000 #在60s（1m）之后，至少有1000个key发生变化

不设任何值` save ""`即为关闭
服务器内部维护了一个dirty计数器和lastsave属性：

    dirty：记录了距上次成功执行了save或bgsave命令之后，数据库修改的次数（写入、删除、更新等）；
    lastsave：unix时间戳，记录了上一次成功执行save或bgsave命令的时间；

redis服务器的周期性操作函数serverCron默认每100毫秒执行一次，该函数的一个主要作用就是检查save选项所设置的保存条件是否满足，如果满足就执行bgsave命令。检查的过程：根据系统当前时间、dirty和lastsave属性的值来检验保存条件是否满足。

2. 如果从节点执行全量复制操作，主节点自动执行bgsave生产RDB文件并发送给从节点
3. 执行debug reload命令重新加载redis时，也会自动触发save操作

    13802:M 20 Nov 14:33:58.435 * DB saved on disk
    13802:M 20 Nov 14:33:58.435 # DB reloaded by DEBUG RELOAD

4. 默认情况下执行shutdown命令时，如果没有开启AOF持久化功能则自动执行bgsave

      13737:M 20 Nov 14:27:24.428 # User requested shutdown...
      13737:M 20 Nov 14:27:24.428 * Saving the final RDB snapshot before exiting.
      13737:M 20 Nov 14:27:24.431 * DB saved on disk
      13737:M 20 Nov 14:27:24.431 # Redis is now ready to exit, bye bye...

通过`info stats`命令查看`latest_fork_usec`选项，可以获取最近一个fork操作的耗时，单位是微秒。
通过`info Persistence`命令可以查看RDB相关选项，具体含义查看info命令

    127.0.0.1:6379> info Persistence
    # Persistence
    loading:0
    rdb_changes_since_last_save:0
    rdb_bgsave_in_progress:0
    rdb_last_save_time:1511159638
    rdb_last_bgsave_status:ok
    rdb_last_bgsave_time_sec:-1
    rdb_current_bgsave_time_sec:-1
    rdb_last_cow_size:0
    aof_enabled:0
    aof_rewrite_in_progress:0
    aof_rewrite_scheduled:0
    aof_last_rewrite_time_sec:-1
    aof_current_rewrite_time_sec:-1
    aof_last_bgrewrite_status:ok
    aof_last_write_status:ok
    aof_last_cow_size:0

## RDB文件配置
**指定RDB文件名**

    # The filename where to dump the DB
    dbfilename dump.rdb

**指定RDB文件目录**

    # The working directory.
    #
    # The DB will be written inside this directory, with the filename specified
    # above using the 'dbfilename' configuration directive.
    #
    # The Append Only File will also be created inside this directory.
    #
    # Note that you must specify a directory here, not a file name.
    dir ./

**开启RDB压缩**

    # Compress string objects using LZF when dump .rdb databases?
    # For default that's set to 'yes' as it's almost always a win.
    # If you want to save some CPU in the saving child set it to 'no' but
    # the dataset will likely be bigger if you have compressible values or keys.
    rdbcompression yes
    
    # Since version 5 of RDB a CRC64 checksum is placed at the end of the file.
    # This makes the format more resistant to corruption but there is a performance
    # hit to pay (around 10%) when saving and loading RDB files, so you can disable it
    # for maximum performances.
    #
    # RDB files created with checksum disabled have a checksum of zero that will
    # tell the loading code to skip the check.
    rdbchecksum yes

RDB默认使用LZF算法对生成的RDB进行压缩处理，压缩后的内存远小于内存大小。
redis-check-dump工具可以检测RDB文件兵获取对应的错误报告

redis加载RDB恢复数据远远快于AOF的方式
RDB适用于备份和全量复制等场景，用于灾难恢复。但是RDB没办法做到实时持久化，因为bgsave和save的频繁执行的成本很高。