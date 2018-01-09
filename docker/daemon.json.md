https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file

Docker daemon 启动的时候可以有很多的命令行选项，这些选项也可以写到一个配置文件中，默认位置： /etc/docker/daemon.json ，key、value都和命令行一一对应，基本一样，但就是有些key在daemon.json中是复数形式，如： insecure-registries、storage-opts

```
{
"live-restore": true,
"insecure-registries": ["docker-registry.i.bbtfax.com:5000"],
"graph":"/data3/docker",
"storage-opts":["dm.basesize=50G", "dm.loopdatasize=600G"]
}
```

# 使用镜像加速器
```
{
  "registry-mirrors": ["xxxx.mirror.aliyuncs.com"]
}
```
重启docker
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```