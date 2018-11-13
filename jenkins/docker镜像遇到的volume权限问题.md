https://blog.csdn.net/minicto/article/details/73539986

用docker启动jenkins的时候遇到错误

```
Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions? touch: cannot touch ‘/var/jenkins_home/copy_reference_file.log’: Permission denied
```

在执行docker run命令的时候增加一个-u参数，如下改进后的命令，
```
docker run -d -v /root/jenkins:/var/jenkins_home -u 0 -P --name jenkins-server jenkins
```

这命令的意思是覆盖容器中内置的帐号，该用外部传入，这里传入0代表的是root帐号Id。这样再启动的时候就应该没问题了。

如果按照上面做还是出现Permission denied错误，那么可以检查一下selinux状态，开启的情况下会导致一些服务安装、使用不成功。

查看selinux状态，

```
[root@localhost ~]# sestatus  
SELinux status:                 enabled  
SELinuxfs mount:                /sys/fs/selinux  
SELinux root directory:         /etc/selinux  
Loaded policy name:             targeted  
Current mode:                   enforcing  
Mode from config file:          enforcing  
Policy MLS status:              enabled  
Policy deny_unknown status:     allowed  
Max kernel policy version:      28
```

临时关闭，

```
[root@localhost ~]# setenforce 0
```

永久关闭,可以修改配置文件/etc/selinux/config,将其中SELINUX设置为disabled，如下，
```
[root@localhost ~]# cat /etc/selinux/config   

# This file controls the state of SELinux on the system.  
# SELINUX= can take one of these three values:  
#     enforcing - SELinux security policy is enforced.  
#     permissive - SELinux prints warnings instead of enforcing.  
#     disabled - No SELinux policy is loaded.  
#SELINUX=enforcing  
SELINUX=disabled  
# SELINUXTYPE= can take one of three two values:  
#     targeted - Targeted processes are protected,  
#     minimum - Modification of targeted policy. Only selected processes are protected.   
#     mls - Multi Level Security protection.  
SELINUXTYPE=targeted

[root@rdo ~]# sestatus  
SELinux status:                 disabled
```
