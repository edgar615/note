## 使用docker命令时，如何避免使用sudo

http://www.liyangweb.com/service/309.html	 

​	在我们使用docker的时候，想查看docker下都有哪些镜像，执行命令：

```
docker images
```

​	可结果却给了我们这样的提示：

```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.29/images/json: dial unix /var/run/docker.sock: connect: permission denied
```

​	我们拒绝不知所以然的拿来主义，所以要在拿来之后深究一下为什么。

​	上面说道，连接/var/run/docker.sock的时候，由于没有权限，被拒绝访问了，那么，我们去看一下这个文件的所有者和所属组是什么。

​	执行：

```
sudo ls -l /var/run/docker.sock
```

​	结果显示：

```
srw-rw---- 1 root docker 0 Jul 12 22:41 /var/run/docker.sock
```

​	我们看到docker.sock是属于root用户和docker组的，我们使用的用户既不是root也不在docker组。那么问题应该就好解决了，所有者咱不动，因为不知道动了以后会有什么问题，我们把当前登录用户加入到docker组就可以了，执行：

```
sudo gpasswd -a ${USER} docker
```

​	这样就加入到了用户组，但是此时group命令获取到的是缓存组的信息，我们执行docker images的话，仍然会报错，我们需要手动切换一次组：

```
newgrp - docker
```

​	再次执行：

```
docker images
```

​	终于看到了我们梦寐以求的hello-world镜像