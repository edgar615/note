tomcat8启动慢

http://blog.csdn.net/chszs/article/details/49494701

https://www.mzlion.com/CentOS7-install-Tomcat8-start-slowly.html

https://stackoverflow.com/questions/26431922/tomcat7-starts-too-late-on-ubuntu-14-04-x64-digitalocean/26432537#26432537

Tomcat 8启动很慢，且日志上无任何错误，在日志中查看到如下信息：

Log4j:[2015-10-29 15:47:11]  INFO ReadProperty:172 - Loading properties file from class path resource [resources/jdbc.properties]
Log4j:[2015-10-29 15:47:11]  INFO ReadProperty:172 - Loading properties file from class path resource [resources/common.properties]
29-Oct-2015 15:52:53.587 INFO [localhost-startStop-1] org.apache.catalina.util.SessionIdGeneratorBase.createSecureRandom Creation of SecureRandom instance for session ID generation using [SHA1PRNG] took [342,445] milliseconds.

原因

Tomcat 7/8都使用org.apache.catalina.util.SessionIdGeneratorBase.createSecureRandom类产生安全随机类SecureRandom的实例作为会话ID，这里花去了342秒，也即接近6分钟。

SHA1PRNG算法是基于SHA-1算法实现且保密性较强的伪随机数生成器。

在SHA1PRNG中，有一个种子产生器，它根据配置执行各种操作。

1）如果Java.security.egd属性或securerandom.source属性指定的是”file:/dev/random”或”file:/dev/urandom”，那么JVM会使用本地种子产生器NativeSeedGenerator，它会调用super()方法，即调用SeedGenerator.URLSeedGenerator(/dev/random)方法进行初始化。

2）如果java.security.egd属性或securerandom.source属性指定的是其它已存在的URL，那么会调用SeedGenerator.URLSeedGenerator(url)方法进行初始化。

这就是为什么我们设置值为”file:///dev/urandom”或者值为”file:/./dev/random”都会起作用的原因。

在这个实现中，产生器会评估熵池（entropy pool）中的噪声数量。随机数是从熵池中进行创建的。当读操作时，/dev/random设备会只返回熵池中噪声的随机字节。/dev/random非常适合那些需要非常高质量随机性的场景，比如一次性的支付或生成密钥的场景。

当熵池为空时，来自/dev/random的读操作将被阻塞，直到熵池收集到足够的环境噪声数据。这么做的目的是成为一个密码安全的伪随机数发生器，熵池要有尽可能大的输出。对于生成高质量的加密密钥或者是需要长期保护的场景，一定要这么做。

那么什么是环境噪声？

随机数产生器会手机来自设备驱动器和其它源的环境噪声数据，并放入熵池中。产生器会评估熵池中的噪声数据的数量。当熵池为空时，这个噪声数据的收集是比较花时间的。这就意味着，Tomcat在生产环境中使用熵池时，会被阻塞较长的时间。
解决

有两种解决办法：

1）在Tomcat环境中解决

可以通过配置JRE使用非阻塞的Entropy Source。

在catalina.sh中加入这么一行：-Djava.security.egd=file:/dev/./urandom 即可。

加入后再启动Tomcat，整个启动耗时下降到Server startup in 2912 ms。

2）在JVM环境中解决

打开$JAVA_PATH/jre/lib/security/java.security这个文件，找到下面的内容：

securerandom.source=file:/dev/urandom

替换成

securerandom.source=file:/dev/./urandom


增大/dev/random的熵池（推荐）

问题的原因是由于熵池不够大，所以增大它是最彻底的方法。我们可以通过软件的方法实现，下面是软件的安装和配置流程。

    安装熵服务

    yum install rng-tools

    启动熵服务

    systemctl start rngd

    如果你的CPU不支持DRNG特性或者像我一样使用虚拟机，可以使用/dev/unrandom来模拟。

      cp /usr/lib/systemd/system/rngd.service /etc/systemd/system 
      vim /etc/systemd/system/rngd.service
      #以下是编辑内容
      ExecStart=/sbin/rngd -f -r /dev/urandom

    重新载入服务

      systemctl daemon-reload
      systemctl restart rngd

经过上面的修改，我们再观察 /proc/sys/kernel/random/entropy_avail 基本上在3000左右。这个时候重新启动Tomcat，发现启动时间正常