安装

sudo apt-get install mysql-server mysql-client
查看安装端口情况

sudo netstat -tap | grep mysql
配置文件位置

sudo vim /etc/mysql/my.cnf
打开关闭服务

/etc/init.d/mysql start/stop

文件位置

    /usr/bin                 客户端程序和脚本  
    /usr/sbin                mysqld 服务器  
    /var/lib/mysql           日志文件，数据库  ［重点要知道这个］  
    /usr/share/doc/packages  文档  
    /usr/include/mysql       包含( 头) 文件  
    /usr/lib/mysql           库  
    /usr/share/mysql         错误消息和字符集文件  
    /usr/share/sql-bench     基准程序  


卸载

sudo apt-get autoremove --purge mysql-server-5.5.43  
sudo apt-get remove mysql-server  
sudo apt-get autoremovemysql-server  
sudo apt-get remove mysql-common  
dpkg -l | grep ^rc| awk '{print $2}' | sudoxargsdpkg -P 
