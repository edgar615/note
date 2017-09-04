清理安装包

查看安装包占用空间

du  –h  /var/cache/apt/archives

删除已经卸载掉的软件包的命令

sudo　apt-get autoclean

删除全部软件包

sudo　apt-get clean

卸载这些孤立包

sudo　apt-get autoremove
