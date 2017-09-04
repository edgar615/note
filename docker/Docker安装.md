 在 Linux上 安装 Docker

Docker 的 安装资源文件 存放在Amazon S3，会间歇性连接失败。所以安装Docker的时候，会比较慢。
你可以通过执行下面的命令，高速安装Docker。

curl -sSL https://get.daocloud.io/docker | sh

适用于Ubuntu，Debian,Centos等大部分Linux，会3小时同步一次Docker官方资源 



二进制

# To install, run the following commands as root:
curl -fsSLO https://get.daocloud.io/docker/builds/Linux/x86_64/docker-1.12.0.tgz && tar --strip-components=1 -xvzf docker-1.12.0.tgz -C /usr/local/bin

# Then start docker in daemon mode:
/usr/local/bin/dockerd


1.添加Docker的ATP仓库

<code>
#sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"  
sudo sh -c "echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list" 
#sudo sh -c "echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"   
</code>



On Ubuntu Precise 12.04 (LTS)

	deb https://apt.dockerproject.org/repo ubuntu-precise main

On Ubuntu Trusty 14.04 (LTS)

	deb https://apt.dockerproject.org/repo ubuntu-trusty main

Ubuntu Wily 15.10

	deb https://apt.dockerproject.org/repo ubuntu-wily main


2.添加Docker仓库的GPG密钥

<code>
curl -s https://get.docker.io/gpg | sudo apt-key add -
</code>

或者：

<pre>
apt-get install apt-transport-https 
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
</pre>
wget -qO- https://get.docker.com/gpg | sudo apt-key add -
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com F76221572C52609D
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D8576A8BA88D21E9
$ curl -sSL https://get.docker.com/ubuntu/ | sudo sh

3.更新APT源

<code>
apt-get update  
</code>

4.安装Docker

<code>
apt-get install docker-engine
</code>

5.修改UFW转发策略,vim /etc/default/ufw

<code>DEFAULT_FORWARD_POLICY="DROP"</code>
为
<code>DEFAULT_FORWARD_POLICY="ACCEPT"</code>

重新加载ufw : ufw reload


去除掉sudo

在Ubuntu下，在执行Docker时，每次都要输入sudo，同时输入密码，很累人的，这里微调一下，把当前用户执行权限添加到相应的docker用户组里面。

<pre>
# 添加一个新的docker用户组
sudo groupadd docker
# 添加当前用户到docker用户组里，注意这里的yongboy为ubuntu server登录用户名
sudo gpasswd -a yongboy docker
# 重启Docker后台监护进程
sudo service docker restart
# 重启之后，尝试一下，是否生效
docker version
#若还未生效，则系统重启，则生效
sudo reboot
</pre>


如果docker需要连接私有仓库，在/etc/default/docker中加入一行

<code>
DOCKER_OPTS="$DOCKER_OPTS --insecure-registry=10.4.7.48:5000"
</code>

## 安装的一些问题
http://stackoverflow.com/questions/29319538/issue-with-my-ca-certificates-crt

<code>
update-ca-certificates -f

apt-get install --reinstall ca-certificates
</code>

## 一些技巧
关闭所有容器
docker kill $(docker ps -q) 

删除所有容器
docker rm $(docker ps -a -q)

删除所有镜像
docker rmi $(docker images -q -a) 

退出时删除容器
docker run --rm -i -t busybox /bin/bash

保存镜像
docker save -o weaveexec.tar weaveworks/weaveexec:v1.1.0

载入镜像
docker load < weaveexec.tar

查看容器的内网IP
docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_ID

监控
Usage: docker stats [OPTIONS] [CONTAINER...]

Display a live stream of one or more containers' resource usage statistics

  -a, --all          Show all containers (default shows just running)
  --help             Print usage
  --no-stream        Disable streaming stats and only pull the first result


## docker的日志位置
It depends on your OS. Here are the few locations, with commands for few Operating Systems:
* Ubuntu - /var/log/upstart/docker.log
* Boot2Docker - /var/log/docker.log
* Debian GNU/Linux - /var/log/daemon.log
* CentOS - /var/log/daemon.log | grep docker
* Fedora - journalctl -u docker.service
* Red Hat Enterprise Linux Server - /var/log/messages | grep docker

## 启动错误：
### FATA[0000] Error starting daemon: Error initializing network controller: could not delete the default bridge network: network bridge has active endpoints 

sudo mv /var/lib/docker/network/files/ /tmp/dn-files

## 错误
Docker error : no space left on device



Check that you have free space on /var as this is where Docker stores the image files by default (in /var/lib/docker).

First clean stuff up by using docker ps -a to list all containers (including stopped ones) and docker rm to remove them; then use docker images to list all the images you have stored and docker rmi to remove them.

Next change the storage location with a -g option on the docker daemon or by editing /etc/default/docker and adding the -g option to DOCKER_OPTS. -g specifies the location of the "Docker runtime" which is basically all the stuff that Docker creates as you build images and run containers. Choose a location with plenty of space as the disk space used will tend to grow over time. If you edit /etc/default/docker, you will need to restart the docker daemon for the change to take effect.

Now you should be able to create a new image (or pull one from Docker Hub) and you should see a bunch of files getting created in the directory you specified with the -g option.
