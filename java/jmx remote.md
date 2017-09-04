-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.port=9010
-Dcom.sun.management.jmxremote.rmi.port=9010
-Djava.rmi.server.hostname=192.168.1.4
-Dcom.sun.management.jmxremote.ssl=false

开启Java JMX 远程管理时，默认会有用户名密码的验证，所以需要相应的密码文件。

[root@localhost SPECjbb2005]# ls /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/jre/lib/management/
jmxremote.access  jmxremote.password.template  management.properties  snmp.acl.template

需要先在jmxremote.access中定义用户权限，然后在jmxremote.password文件中定义用户名和对应的密码，jmxremote.password文件可以复制jmxremote.password.template模板文件来进行修改。 

当把应用放在docker中运行之后，发现通过jconsole连不上docker里的JVM

-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.port=9999
-Djava.rmi.server.hostname=192.168.1.4
-Dcom.sun.management.jmxremote.ssl=false

-Djava.rmi.server.hostname=192.168.1.4要设成宿主机的IP

在网上搜了一下，是因为rmi会动态分配一个端口。

Java 7 update 25之后提供了一个新的参数，可以指定rmi的端口。一般可以和jmx的端口设成一样

-Dcom.sun.management.jmxremote.rmi.port=9999

https://ptmccarthy.github.io/2014/07/24/remote-jmx-with-docker/
http://stackoverflow.com/questions/20884353/why-java-opens-3-ports-when-jmx-is-configured/21552812#21552812

rmi会动态分配一个端口。

Java 7 update 25之后提供了一个新的参数，可以指定rmi的端口。一般可以和jmx的端口设成一样

-Dcom.sun.management.jmxremote.rmi.port=9999


jstatd配置
grant codebase "file:${java.home}/../lib/tools.jar" {
    permission java.security.AllPermission;
};


jstatd -p 9999 -J-Djava.security.policy=/jstatd.all.policy