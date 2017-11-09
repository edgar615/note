HyperLogLog是一直基数算法（实际类型为字符串类型）。通过HyperLogLog可以利用极小的内存空间完成独立总数的统计，数据集可以是IP，email，ID等等。HyperLogLog提供了三个命令：pfadd、pfcount、pfmerge



**添加**
pfadd key element [element ...]

    127.0.0.1:6379> pfadd 2017_11_09:ids 1 2 3 4 5
    (integer) 1

**计算独立用户数**
pfcount key [key ...]

pfcount用于计算一个或多个HyperLogLog的独立总数

    127.0.0.1:6379> PFCOUNT 2017_11_09:ids
    (integer) 5

HyperLogLog在数据量大的情况下会对内存的占用量非常小。但是用如此小空间来估算巨大的数据，必然不是100%的正确，其中一定一定存在误差率。Redis官方给出的数字是0.81%的失误率

**合并**
pfmerge destkey sourcekey [sourcekey ...]
pfmerge可以求出多个HyperLogLog的并集并赋值给destKey

    127.0.0.1:6379> pfmerge 2017_11_08-09:ids 2017_11_08:ids 2017_11_09:ids
    OK
    127.0.0.1:6379> pfcount 2017_11_08-09:ids
    (integer) 7

