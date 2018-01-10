https://yq.aliyun.com/articles/18037



如果使用官方的[Java](https://hub.docker.com/_/java/)镜像，或者基于Java镜像构建的Docker镜像，都可以通过传递 `JAVA_OPTS` 环境变量来轻松地设置JVM的内存参数。比如，对于官方[Tomcat](https://hub.docker.com/_/tomcat/) 镜像，我们可以执行下面命令来启动一个最大内存为512M的tomcat实例

```
docker run --rm -e JAVA_OPTS='-Xmx512m' tomcat:8
```

在日志中，我们可以清楚地发现设置已经生效 “Command line argument: -Xmx512m”

```
02-Apr-2016 12:46:26.970 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server version:        Apache Tomcat/8.0.32
02-Apr-2016 12:46:26.974 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server built:          Feb 2 2016 19:34:53 UTC
02-Apr-2016 12:46:26.975 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server number:         8.0.32.0
02-Apr-2016 12:46:26.975 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log OS Name:               Linux
02-Apr-2016 12:46:26.975 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log OS Version:            4.1.19-boot2docker
02-Apr-2016 12:46:26.975 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Architecture:          amd64
02-Apr-2016 12:46:26.975 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Java Home:             /usr/lib/jvm/java-7-openjdk-amd64/jre
02-Apr-2016 12:46:26.976 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log JVM Version:           1.7.0_95-b00
02-Apr-2016 12:46:26.976 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log JVM Vendor:            Oracle Corporation
02-Apr-2016 12:46:26.977 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log CATALINA_BASE:         /usr/local/tomcat
02-Apr-2016 12:46:26.977 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log CATALINA_HOME:         /usr/local/tomcat
02-Apr-2016 12:46:26.978 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties
02-Apr-2016 12:46:26.978 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
02-Apr-2016 12:46:26.978 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Xmx512m
...
```

然而在Docker集群上部署运行Java容器应用的时候，仅仅对JVM的heap参数设置是不够的，我们还需要对Docker容器的内存资源进行限制：

```
1. 限制容器使用的内存的最大量，防止对系统或其他应用造成伤害
2. 能够将Docker容器调度到拥有足够空余的内存的节点，从而保证应用的所需运行资源
```

关于容器的资源分配约束，Docker提供了相应的[启动参数](https://docs.docker.com/engine/reference/run/#runtime-constraints-on-resources)

对内存而言，最基本的就是通过 `-m`参数来约束容器使用内存的大小

```
-m, --memory=""
Memory limit (format: <number>[<unit>]). Number is a positive integer. Unit can be one of b, k, m, or g. Minimum is 4M.
```

那么问题就来了，为了正确设置Docker容器内存的大小，难道我们需要同时传递容器的内存限制和JAVA_OPTS环境变量吗？ 如下所示：

```
docker run --rm -m 512m -e JAVA_OPTS='-Xmx512m' tomcat:8
```

这个方法有两个问题

1. 需要管理员保证容器内存和JVM内存设置匹配，否则可能引发错误
2. 当对容器内存限制调整时，环境变量也需要重新设定，这就需要重建一个新的容器

是否有一个方法，可以让容器内部的JVM自动适配容器的内存限制？这样可以采用更加统一的方法来进行资源管理，简化配置工作。

大家知道Docker是通过CGroup来实现资源约束的，自从1.7版本之后，Docker把容器的local cgroups以只读方式挂载到容器内部的文件系统上，这样我们就可以在容器内部，通过cgroups信息来获取系统对当前容器的资源限制了。

我创建了一个示例镜像 `registry.aliyuncs.com/denverdino/tomcat:8-autoheap`
，其源代码可以从[Github](https://github.com/denverdino/docker-tomcat-autoheap) 获得。它基于Docker官方Tomcat镜像创建，它的启动脚本会检查CGroup中内存限置，并计算JVM最大Heap size来传递给Tomcat。其代码如下

```
#!/bin/bash
limit_in_bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)

# If not default limit_in_bytes in cgroup
if [ "$limit_in_bytes" -ne "9223372036854771712" ]
then
    limit_in_megabytes=$(expr $limit_in_bytes \/ 1048576)
    heap_size=$(expr $limit_in_megabytes - $RESERVED_MEGABYTES)
    export JAVA_OPTS="-Xmx${heap_size}m $JAVA_OPTS"
    echo JAVA_OPTS=$JAVA_OPTS
fi

exec catalina.sh run
```

说明：

- 为了监控，故障排查等场景，我们预留了部分内存（缺省256M），其余容器内存我们都分配给JVM的堆。
- 这里没有对边界情况做进一步处理。在生产系统中需要根据情况做相应的设定，比如最大的堆大小等等。

现在我们启动一个tomcat运行在512兆的容器中

```
docker run -d --name test -m 512m registry.aliyuncs.com/denverdino/tomcat:8-autoheap
```

通过下列命令，从日志中我们可以检测到相应的JVM参数已经被设置成 256MB (512-256)

```
docker logs test

...
02-Apr-2016 14:18:09.870 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Xmx256m
...
```

我们也可以方便的调整Java应用的内存.

Docker 1.10提供了对容器资源限制的动态修改能力。但是由于JVM无法感知容器资源修改，我们依然需要重启tomcat来变更JVM的内存设置，例如，我们可以通过下面命令把容器内存限制调整到1GB

```
docker update -m 1024m test
docker restart test
```

再次检查日志，相应的JVM Heap Size最大值已被设置为768MB

```
docker logs test

...
02-Apr-2016 14:21:07.644 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Xmx768MB
...
```