Git跟其它版本控制系统一样，可以打标签(tag), 作用是标记一个点为一个版本号，如0.1.3, v0.1.7, ver_0.1.3.在程序开发到一个阶段后，我们需要打个标签，发布一个版本，标记的作用显而易见。

下面介绍一下打标签，分享标签，移除标签的操作命令。
打标签

    git tag -a 0.1.3 -m “Release version 0.1.3″

    详解：git tag 是命令

        -a 0.1.3是增加 名为0.1.3的标签

        -m 后面跟着的是标签的注释

    打标签的操作发生在我们commit修改到本地仓库之后。完整的例子

        git add .

        git commit -m “fixed some bugs”

        git tag -a 0.1.3 -m “Release version 0.1.3″
分享提交标签到远程服务器上

    git push origin master

    git push origin --tags

    –tags参数表示提交所有tag至服务器端，普通的git push origin master操作不会推送标签到服务器端。
删除标签的命令

    git tag -d 0.1.3
删除远端服务器的标签

    git push origin :refs/tags/0.1.3