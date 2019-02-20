在jenkins根据不通的变量发布执行不同的命令，主要用到其选择参数 

安装插件choice parameter

选择参数化构建过程

![](deploy_env.png)

增加SSH服务器，在label中输入上一步参数对应的值

![](ssh.png)

点高级设置参数化发布

![](publish.png)

发布是选择对应的参数

![](build.png)