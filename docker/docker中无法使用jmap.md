https://jarekprzygodzki.wordpress.com/2016/12/19/jvm-in-docker-and-ptrace_attach/

在docker中使用jmap命令会报错

```
Attaching to process ID 142, please wait...
Error attaching to process: sun.jvm.hotspot.debugger.DebuggerException: Can't attach to the process: ptrace(PTRACE_ATTACH, ..) failed for 142: Operation not permitted
sun.jvm.hotspot.debugger.DebuggerException: sun.jvm.hotspot.debugger.DebuggerException: Can't attach to the process: ptrace(PTRACE_ATTACH, ..) failed for 142: Operation not permitted
```

因为类似于 jmap 这些 JDK 工具依赖于 Linux 的 PTRACE_ATTACH，而是 Docker 自 1.10 在默认的 seccomp 配置文件中禁用了 ptrace

解决方法
1. 直接关闭 seccomp 配置，不推荐
```
docker run --security-opt seccomp:unconfined ...
```
2 使用 --cap-add 明确添加指定功能
```
 docker run  --cap-add=SYS_PTRACE ...
```