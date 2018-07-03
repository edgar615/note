https://unix.stackexchange.com/questions/87908/how-do-you-empty-the-buffers-and-cache-on-a-linux-system

每个 Linux 系统有三种选项来清除缓存而不需要中断任何进程或服务。

Cache，译作“缓存”，指 CPU 和内存之间高速缓存。Buffer，译作“缓冲区”，指在写入磁盘前的存储再内存中的内容

清除全部

```
free && sync && echo 3 > /proc/sys/vm/drop_caches && free
```

sync 将刷新文件系统缓冲区（buffer） 



仅清除页面缓存（PageCache） 

```
echo 1 > /proc/sys/vm/drop_caches
```

清除目录项和inode 

```
echo 2 > /proc/sys/vm/drop_caches
```

清除页面缓存，目录项和inode 

```
echo 3 > /proc/sys/vm/drop_caches
```

The above are meant to be run as root. If you're trying to do them using `sudo` then you'll need to change the syntax slightly to something like these:

```
$ sudo sh -c 'echo 1 >/proc/sys/vm/drop_caches'
$ sudo sh -c 'echo 2 >/proc/sys/vm/drop_caches'
$ sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
```

清理swap，先关闭swap在打开swap

```
 swapoff -a && swapon -a
```