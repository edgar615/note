# 升级单个软件
sudo apt-get update

sudo apt-get upgrade 软件名

# 升级所有软件
sudo apt-get update

sudo apt-get dist-upgrade

# 普通的正常升级
sudo apt-get update

-- 如果又可以升级的话就升级
sudo apt-get upgrade



#升级系统
1.先检查系统更新，如果有更新则在终端中运行：
sudo apt-get update && sudo apt-get dist-upgrade

2.接着检查是否有可用的更新，在终端中运行：
sudo update-manager -d

3.然后进入到如下图的图形更新提示中：

-d是告诉更新管理器升级到开发版本，也就是正式版本发布之前的Ubuntu 15.04，升级的时间取决于你的网速。

# 升级内核
查找可升级的内核
apt-cache search linux-generic-lts
升级
sudo apt-get install linux-generic-lts-utopic
