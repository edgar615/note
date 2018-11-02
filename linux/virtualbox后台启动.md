# 找到VirtualBox的安装目录             　　　　　　

 我的virtualbox安装在 D:\virualBox，进入这个目录，你会看到有个VBoxManage.exe文件，没有错，我们就是用它来启动虚拟机的。

怎么启动呢？命令行如下

　　VBoxManage startvm <uuid>|<name> [--type gui|sdl|headless]

比如我新建的虚拟机叫study，那么

　　D:\virualBox\VBoxManage startvm study --type headless

　　　　　　　　　　　　　　　*--type headless:表示后台执行，没有窗口哦*

来，我们打开cmd，试下这个命令

　　![img](https://images2015.cnblogs.com/blog/589123/201609/589123-20160922113551199-256462298.png)

提示已经启动了study虚拟机了。

 

 

# 开机自启动             　　　

 现在看不到窗口了，但是还是需要手动输入命令行启动。如果能开机自启动就好了

1、首选我们要做一个bat脚本：virtualboxtStart.bat

2、里面写入上面的命令：D:\virualBox\VBoxManage startvm study --type headless

3、把virtualboxtStart.bat放到C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup，这个目录下的脚本是开机的时候自动运行的哦

 

好了，小工告成。重启电脑，你就会发现，win7偷偷帮我们启动了study这个虚拟机了。

可以用SSH连接，操作了。

 

**注：也可以在cmd中使用命令行对虚拟机进行状态管理：**

VBoxManage controlvm   <uuid>|<name>   pause|resume|reset|poweroff|savestate|

比如我想关闭：

D:\virualBox\VBoxManage controlvm  study  poweroff









# 启动Headless模式

VirtualBox虚拟机有一种模式为headless模式，即无显示模式：

```
VBoxManage startvm <uuid>|<name> [--type gui|sdl|headless]
```

假设我们的虚拟机叫做nenew，我们像启动headless模式的虚拟机的化，我们可以执行下列命令：

```
vboxmanage startvm nenew --type headless
```

上面的这条命令可以运行headless模式的虚拟机。在运行完命令后虚拟机应该已经后台运行了，并出现下行提示：

```
Waiting for the VM to power on…
VM has been successfully started.
```

虚拟机已经后台运行了，可使用下列命令对其进行关闭重庆等操作。

# 虚拟机状态控制

```
VBoxManage controlvm <uuid>|<name> pause|resume|reset|poweroff|savestate|
```

例如关闭刚才启动的headless虚拟机nenew我们可以用下面命令来完成

```
vboxmanage controlvm nenew poweroff
```

# 共享目录设定

如果想使用共享目录则：
 `vboxmanage sharedfolder add centos --name *share* --hostpath *~/share*`

登录成功后挂载共享目录:
 `mount -t vboxsf share /mnt/`

