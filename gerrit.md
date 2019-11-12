

# 没找到gerrit.password文件

htpasswd是Apache的Web服务器内置的工具,用于创建和更新储存用户名和用户基本认证的密码文件，我们服务器上使用的Nginx，所以安卓httpd-tools

```
yum install httpd-tools
```
> 参数
>
> - -c: 创建一个新的密码文件
> - -b: 在命令行中一并输入用户名和密码而不是根据提示输入密码
> - -D: 删除指定的用户
> - -n: 不更新密码文件,只将加密后的用户名密码输出到屏幕上
> - -p: 不对密码进行加密,采用明文的方式
> - -m: 采用MD5算法对密码进行加密(默认的加密方式)
> - -d: 采用CRYPT算法对密码进行加密
> - -s: 采用SHA算法对密码进行加密
> - -B: 采用bcrypt算法对密码进行加密(非常安全)

```
htpasswd -cb etc/gerrit.passwd admin password
```

Nginx配置

```
server {
        listen       443;
        server_name  gerrit.xxx.com;
        ssl on;
        root /alidata/nginx/content/gerrit;
        # ssl信息

        auth_basic "Welcomme to Gerrit Code Review Site!";
        auth_basic_user_file /alidata/gerrit/gerrit_site/etc/gerrit.passwd;

        location / {
                proxy_pass https://gerrit-server;
        }
}
```

# 新增用户

和上面的一样，通过htpasswd添加一个用户

```
htpasswd -b etc/gerrit.passwd user password
```

# 自动生成Change-Id

将https://gerrit.xxx.com/tools/hooks/commit-msg文件拷贝到项目的.git/hooks目录下



git push origin HEAD:refs/for/master

git push origin HEAD:master



同步报错

not authorized