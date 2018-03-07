https://segmentfault.com/a/1190000008762601

https://herdsman.me/2016/12/13/alpine-time-zone/



> 在使用docker的时候，由于很多基础linux镜像都比较大，alpine这个仅仅几兆的linux基础镜像受到了很多人喜欢，笔者也不例外，可是由于alpine中的一些配置及命令与常见的centos等系统在一些方面不一样，下面来看看时区问题是如何解决的：
>
> 原因：alpine中，原生是不带时区相关的命令及文件的，需要安装额外的包来支持，然后需要将时区文件内容替换为localtime文件

## 解决办法

#### Dockerfile1：

```
RUN apk update && apk add tzdata \
	&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& echo "Asia/Shanghai" > /etc/timezone
```



#### Dockerfile2：

```
# Install root filesystem
ADD ./rootfs /

# Install base packages
RUN apk update && apk add curl bash tree tzdata \
    && cp -r -f /usr/share/zoneinfo/Hongkong /etc/localtime \
    && echo -ne "Alpine Linux 3.4 image. (`uname -rsv`)\n" >> /root/.built

```

