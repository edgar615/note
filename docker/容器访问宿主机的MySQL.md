我的MySQL没有使用docker安装，docker内运行的应用在启动并不知道MySQL的IP是多少 .

我们可以在启动容器时通过--add-host参数将宿主机的IP写入到host中

```
HOSTIP=`ip -4 addr show scope global dev docker0 | grep inet | awk '{print \$2}' | cut -d / -f 1`
docker run --add-host=docker:${HOSTIP} -it --rm edgar615/jdk:8u151 /bin/sh
```