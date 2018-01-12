Docker客户端已经提供了基本的命令行工具来检查容器的资源消耗。可以查看每个容器的CPU利用率、内存的使用量以及可用内存总量。

```
docker stats [OPTIONS] [CONTAINER...]
```
示例
```
docker stats -a
```
```
CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
f7190aa00439        0.07%               285.2MiB / 500MiB     57.04%              8.78kB / 5.1kB      0B / 0B             0
91c81139ceae        0.00%               1.395MiB / 3.861GiB   0.04%               134kB / 2.12MB      0B / 0B             0
ac7ab073b3a2        0.05%               238.6MiB / 3.861GiB   6.04%               2.44MB / 3.32MB     139kB / 51.3MB      0
```
如果你没有限制容器内存，那么该命令将显示您的主机的内存总量。但它并不意味着你的每个容器都能访问那么多的内存

如果想得到更详细的参数，可以通过docker的远程API`GET请求/containers/[CONTAINER_NAME]`来查询，参考`Runtime metrics`部分

## 格式化
```
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```
```
CONTAINER           CPU %               MEM USAGE / LIMIT
f7190aa00439        0.07%               285.2MiB / 500MiB
91c81139ceae        0.00%               1.395MiB / 3.861GiB
ac7ab073b3a2        0.04%               238.6MiB / 3.861GiB
```

格式化变量

| Placeholder  | Description                              |
| ------------ | ---------------------------------------- |
| `.Container` | Container name or ID (user input)        |
| `.Name`      | Container name                           |
| `.ID`        | Container ID                             |
| `.CPUPerc`   | CPU percentage                           |
| `.MemUsage`  | Memory usage                             |
| `.NetIO`     | Network IO                               |
| `.BlockIO`   | Block IO                                 |
| `.MemPerc`   | Memory percentage (Not available on Windows) |
| `.PIDs`      | Number of PIDs (Not available on Windows) |

示例
```
docker stats --format "{{.Container}}: {{.CPUPerc}}"

f7190aa00439: 0.09%
91c81139ceae: 0.00%
ac7ab073b3a2: 0.05%
```