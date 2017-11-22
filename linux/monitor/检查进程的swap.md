根据进程ID检查swap信息

    [root@ihorn-dev redis-3.2.0]# cat /proc/2721/smaps | grep Swap
    Swap:                  0 kB
    Swap:                  0 kB
    Swap:                  0 kB
    Swap:                  0 kB

由于内存和硬盘的读写速度 差几个数量级，对应高性能应用，发生swap是致命的