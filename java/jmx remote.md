-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.port=9010
-Dcom.sun.management.jmxremote.rmi.port=9010
-Djava.rmi.server.hostname=192.168.1.4
-Dcom.sun.management.jmxremote.ssl=false

����Java JMX Զ�̹���ʱ��Ĭ�ϻ����û����������֤��������Ҫ��Ӧ�������ļ���

[root@localhost SPECjbb2005]# ls /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/jre/lib/management/
jmxremote.access  jmxremote.password.template  management.properties  snmp.acl.template

��Ҫ����jmxremote.access�ж����û�Ȩ�ޣ�Ȼ����jmxremote.password�ļ��ж����û����Ͷ�Ӧ�����룬jmxremote.password�ļ����Ը���jmxremote.password.templateģ���ļ��������޸ġ� 

����Ӧ�÷���docker������֮�󣬷���ͨ��jconsole������docker���JVM

-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.local.only=false
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.port=9999
-Djava.rmi.server.hostname=192.168.1.4
-Dcom.sun.management.jmxremote.ssl=false

-Djava.rmi.server.hostname=192.168.1.4Ҫ�����������IP

����������һ�£�����Ϊrmi�ᶯ̬����һ���˿ڡ�

Java 7 update 25֮���ṩ��һ���µĲ���������ָ��rmi�Ķ˿ڡ�һ����Ժ�jmx�Ķ˿����һ��

-Dcom.sun.management.jmxremote.rmi.port=9999

https://ptmccarthy.github.io/2014/07/24/remote-jmx-with-docker/
http://stackoverflow.com/questions/20884353/why-java-opens-3-ports-when-jmx-is-configured/21552812#21552812

rmi�ᶯ̬����һ���˿ڡ�

Java 7 update 25֮���ṩ��һ���µĲ���������ָ��rmi�Ķ˿ڡ�һ����Ժ�jmx�Ķ˿����һ��

-Dcom.sun.management.jmxremote.rmi.port=9999


jstatd����
grant codebase "file:${java.home}/../lib/tools.jar" {
    permission java.security.AllPermission;
};


jstatd -p 9999 -J-Djava.security.policy=/jstatd.all.policy