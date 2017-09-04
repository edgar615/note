 在Linux中增加swap空间	

        在安装Linux的时候，不知道swap空间分配多少比较好，所以会随便分配一个，在真正使用的时候，比如安装Oracle10g会要求很大的swap空间，发现swap空间不够，那应该怎么增加swap空间大小呢。

        以下的操作都要在root用户下进行，首先先建立一个分区，采用dd命令比如
dd if=/dev/zero of=/home/swap bs=1024 count=512000

这样就会创建/home/swap这么一个分区文件。文件的大小是512000个block，一般情况下1个block为1K，所以这里空间是512M。接着再把这个分区变成swap分区。
/sbin/mkswap /home/swap

再接着使用这个swap分区。使其成为有效状态。
/sbin/swapon /home/swap

现在再用free -m命令查看一下内存和swap分区大小，就发现增加了512M的空间了。不过当计算机重启了以后，发现swap还是原来那么大，新的swap没有自动启动，还要手动启动。那我们需要修改/etc/fstab文件，增加如下一行
/home/swap              swap                    swap    defaults        0 0
你就会发现你的机器自动启动以后swap空间也增大了。