参考

http://blog.csdn.net/bluishglc/article/details/7710738

http://www.zolazhou.com/posts/primary-key-selection-in-database-partition-design/

http://blog.csdn.net/hengyunabc/article/details/19025973

http://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=403837240&idx=1&sn=ae9f2bf0cc5b0f68f9a2213485313127&mpshare=1&scene=23&srcid=1013Mv1Ub3adzOqb6QY7zZvG#rd

我们在对数据库集群作扩容时，为了保证负载的平衡，需要在不同的Shard之间进行数据的移动， 如果主键不唯一，我们就没办法这样随意的移动数据.

# UUID
采用UUID作为主键是最简单的方案.

维基百科

    通用唯一识别码（英语：Universally Unique Identifier，简称UUID）是一种软件建构的标准，亦为自由软件基金会组织在分散式计算环境领域的一部份。

    UUID的目的，是让分散式系统中的所有元素，都能有唯一的辨识信息，而不需要通过中央控制端来做辨识信息的指定。如此一来，每个人都可以创建不与其它人冲突的UUID。在这样的情况下，就不需考虑数据库创建时的名称重复问题。目前最广泛应用的UUID，是微软公司的全局唯一标识符（GUID），而其他重要的应用，则有Linux ext2/ext3文件系统、LUKS加密分区、GNOME、KDE、Mac OS X等等。另外我们也可以在e2fsprogs包中的UUID库找到实现。

	UUID是由一组32位数的16进制数字所构成，是故UUID理论上的总数为1632=2128，约等于3.4 x 1038。也就是说若每纳秒产生1兆个UUID，要花100亿年才会将所有UUID用完。
	
	UUID的标准型式包含32个16进制数字，以连字号分为五段，形式为8-4-4-4-12的32个字符。示例：
	
	    550e8400-e29b-41d4-a716-446655440000 

## UUID具有以下涵义：

**经由一定的算法机器生成**
为了保证UUID的唯一性，规范定义了包括网卡MAC地址、时间戳、名字空间（Namespace）、随机或伪随机数、时序等元素，以及从这些元素生成UUID的算法。UUID的复杂特性在保证了其唯一性的同时，意味着只能由计算机生成。

**非人工指定，非人工识别**
UUID是不能人工指定的，除非你冒着UUID重复的风险。UUID的复杂性决定了“一般人“不能直接从一个UUID知道哪个对象和它关联。

**在特定的范围内重复的可能性极小**
UUID的生成规范定义的算法主要目的就是要保证其唯一性。但这个唯一性是有限的，只在特定的范围内才能得到保证，这和UUID的类型有关（参见UUID的版本）。

## UUID的版本
UUID具有多个版本，每个版本的算法不同，应用范围也不同。
首先是一个特例－－Nil UUID－－通常我们不会用到它，它是由全为0的数字组成，如下：
00000000-0000-0000-0000-000000000000

### UUID Version 1：基于时间的UUID
基于时间的UUID通过计算当前时间戳、随机数和机器MAC地址得到。由于在算法中使用了MAC地址，这个版本的UUID可以保证在全球范围的唯一性。但与此同时，使用MAC地址会带来安全性问题，这就是这个版本UUID受到批评的地方。如果应用只是在局域网中使用，也可以使用退化的算法，以IP地址来代替MAC地址－－Java的UUID往往是这样实现的（当然也考虑了获取MAC的难度）。

### UUID Version 2：DCE安全的UUID
DCE（Distributed Computing Environment）安全的UUID和基于时间的UUID算法相同，但会把时间戳的前4位置换为POSIX的UID或GID。这个版本的UUID在实际中较少用到。

### UUID Version 3：基于名字的UUID（MD5）
基于名字的UUID通过计算名字和名字空间的MD5散列值得到。这个版本的UUID保证了：相同名字空间中不同名字生成的UUID的唯一性；不同名字空间中的UUID的唯一性；相同名字空间中相同名字的UUID重复生成是相同的。

### UUID Version 4：随机UUID
根据随机数，或者伪随机数生成UUID。这种UUID产生重复的概率是可以计算出来的，但随机的东西就像是买彩票：你指望它发财是不可能的，但狗屎运通常会在不经意中到来。

### UUID Version 5：基于名字的UUID（SHA1）
和版本3的UUID算法类似，只是散列值计算使用SHA1（Secure Hash Algorithm 1）算法。

## UUID的应用
从UUID的不同版本可以看出，
Version 1/2适合应用于分布式计算环境下，具有高度的唯一性；
Version 3/5适合于一定范围内名字唯一，且需要或可能会重复生成UUID的环境下；
至于Version 4，个人的建议是最好不用（虽然它是最简单最方便的）。
通常我们建议使用UUID来标识对象或持久化数据，但以下情况最好不使用UUID：
映射类型的对象。比如只有代码及名称的代码表。
人工维护的非系统生成对象。比如系统中的部分基础数据。
对于具有名称不可重复的自然特性的对象，最好使用Version 3/5的UUID。比如系统中的用户。如果用户的UUID是Version 1的，如果你不小心删除了再重建用户，你会发现人还是那个人，用户已经不是那个用户了。（虽然标记为删除状态也是一种解决方案，但会带来实现上的复杂性。）

https://www.zhihu.com/question/34876910/answer/88924223

## 优缺点
UUID作为主键的优缺点分别如下
优点：

- 本地生成ID，不需要进行远程调用，时延低
- 扩展性好，基本可以认为没有性能上限

缺点：

- uuid过长，往往用字符串表示
- UUID的生成没有顺序性，所以在写入时， 需要随机更改索引的不同位置，这就需要更多的IO操作，如果索引太大而不能存放在内存中的话就更是如此。 而UUID索引时，一个key需要32个字节(当然如果采用二进制形式存储的话可以压缩到16个字节)， 因此整个索引也会相对比较大

# MySQL自增字段

结合数据库维护一个Sequence表：此方案的思路也很简单，在数据库中建立一个Sequence表，表的结构类似于

	CREATE TABLE `SEQUENCE` (  
	    `tablename` varchar(30) NOT NULL,  
	    `nextid` bigint(20) NOT NULL,  
	    PRIMARY KEY (`tablename`)  
	) ENGINE=InnoDB 

每当需要为某个表的新纪录生成ID时就从Sequence表中取出对应表的nextid,并将nextid的值加1后更新到数据库中以备下次使用。此方案也较简单，但缺点同样明显：由于所有插入任何都需要访问该表，该表很容易成为系统性能瓶颈，同时它也存在单点问题，一旦该表数据库失效，整个应用程序将无法工作。有人提出使用Master-Slave进行主从同步，但这也只能解决单点问题，并不能解决读写比为1:1的访问压力问题。

# flickr的方案
http://code.flickr.net/2010/02/08/ticket-servers-distributed-unique-primary-keys-on-the-cheap/

![](http://ww1.sinaimg.cn/large/67a6a651gw1dujgqcx9ncj.jpg)

flickr这一方案的整体思想是：建立两台以上的数据库ID生成服务器，每个服务器都有一张记录各表当前ID的Sequence表，但是Sequence中ID增长的步长是服务器的数量，起始值依次错开，这样相当于把ID的生成散列到了每个服务器节点上。例如：如果我们设置两台数据库ID生成服务器，那么就让一台的Sequence表的ID起始值为1,每次增长步长为2,另一台的Sequence表的ID起始值为2,每次增长步长也为2，那么结果就是奇数的ID都将从第一台服务器上生成，偶数的ID都从第二台服务器上生成，这样就将生成ID的压力均匀分散到两台服务器上，同时配合应用程序的控制，当一个服务器失效后，系统能自动切换到另一个服务器上获取ID，从而保证了系统的容错。

**设置两台服务器的自增步长**

一台服务器从1开始，步长为2，生成的ID永远为奇数，一台服务器从2开始步长为2生成的ID永远为偶数

    Server1:  
    auto-increment-increment = 2  
    auto-increment-offset = 1  
      
    Server2:  
    auto-increment-increment = 2  
    auto-increment-offset = 2  

**在两台服务器上分别创建一个Sequence表**

    CREATE TABLE `Sequence` (  
      `id` bigint(20) unsigned NOT NULL auto_increment,  
      `stub` char(1) NOT NULL default '',  
      PRIMARY KEY  (`id`),  
      UNIQUE KEY `stub` (`stub`)  
    ) ENGINE=MyISAM  

**生成一个新的ID**

    REPLACE INTO Tickets64 (stub) VALUES ('a');  
    SELECT LAST_INSERT_ID();  

REPLACE INTO和INSERT的功能一样，但是当使用REPLACE INTO插入新数据行时， 如果新插入的行的主键或唯一键(UNIQUE Key)已有的行重复时，已有的行会先被删除，然后再将新数据行插入

**注意**

SELECT LAST_INSERT_ID()必须要于REPLACE INTO语句在同一个数据库连接下才能得到刚刚插入的新ID，否则返回的值总是0。该方案中Sequence表使用的是MyISAM引擎，以获取更高的性能.MyISAM引擎使用的是表级别的锁，MyISAM对表的读写是串行的，因此不必担心在并发时两次读取会得到同一个ID。

## 优缺点
优点：简单可靠

缺点：ID只是一个ID，没有带入时间，shardingId等信息。

# snowflake
http://www.lanindex.com/twitter-snowflake%EF%BC%8C64%E4%BD%8D%E8%87%AA%E5%A2%9Eid%E7%AE%97%E6%B3%95%E8%AF%A6%E8%A7%A3/

Twitter-Snowflake算法产生的背景相当简单，为了满足Twitter每秒上万条消息的请求，每条消息都必须分配一条唯一的id，这些id还需要一些大致的顺序（方便客户端排序），并且在分布式系统中不同机器产生的id必须不同。

	0    00000.....000 00000 00000 000000000000
	|    |___________| |___| |___| |__________|
	|         |          |     |        |
	1bit     41bit     5bit  5bit     12bit

核心代码就是毫秒级时间41位+机器ID 10位+毫秒内序列12位

- 第一段:1bit 预留 实际上是作为long的符号位
- 第二段:41bit 时间标记 记录的是当前时间与元年的时间差
- 第三段:5bit 数据中心Id标记  记录的是数据中心的Id,5bit最大可以表示32个数据中心,这么多数据中心能保证全球范围内服务可用
- 第四段:5bit 节点标记  记录的是单个数据中心里面服务节点的Id,同理也是最大可以有32个节点,这个除非是整个数据中心离线,否则可以保证服务永远可用
- 第五段:12bit 单毫秒内自增序列 每毫秒可以生成4096个ID

除了最高位bit标记为不可用以外，其余三组bit位数均可根据具体的业务需求浮动。

## 时间戳
时间戳的细度是毫秒级

## 数据中心ID和节点标记
严格意义上来说这个bit段的使用可以是进程级，机器级的话你可以使用MAC地址来唯一标示工作机器，工作进程级可以使用IP+Path来区分工作进程。如果工作机器比较少，可以使用配置文件来设置这个id是一个不错的选择，如果机器过多配置文件的维护是一个灾难性的事情。

## 自增序列
序列号就是一系列的自增id（多线程建议使用atomic），为了处理在同一毫秒内需要给多条消息分配id，若同一毫秒把序列号用完了，则“等待至下一毫秒”。

## 示例

	class SimpleSnowflakeIdFactory implements IdFactory<Long>, TimeExtracter<Long>, SeqExtracter<Long>,
	        ServerExtracter<Long> {
	
	  /**
	   * 自增序列的位数
	   */
	  private static final int SEQ_BIT = 12;
	
	  /**
	   * 节点标识的位数
	   */
	  private static final int SERVER_BIT = 10;
	
	  /**
	   * 最大序列号
	   */
	  private static final int SEQ_MASK = -1 ^ (-1 << SEQ_BIT);
	
	  /**
	   * 最大server
	   */
	  private static final int SERVER_MASK = -1 ^ (-1 << SERVER_BIT);
	
	
	  /**
	   * 时间的左移位数
	   */
	  private static final int TIME_LEFT_BIT = SEQ_BIT + SERVER_BIT;
	
	  /**
	   * SERVER的左移位数
	   */
	  private static final int SERVER_LEFT_BIT = SEQ_BIT;
	
	  /**
	   * 每次初始化对序列值.
	   */
	  private static final int INIT_SEQ = 0;
	
	  /**
	   * 服务器id
	   */
	  private final int serverId;
	
	  /**
	   * 上次时间戳
	   */
	  private volatile long lastTime = -1l;
	
	  /**
	   * 自增序列
	   */
	  private volatile long seqId = INIT_SEQ;
	
	  private SimpleSnowflakeIdFactory(int serverId) {
	    this.serverId = serverId & SERVER_MASK;
	  }
	
	  @Override
	  public synchronized Long nextId() {
	    long time = currentTime();
	    if (time < lastTime) {//当前时间小于上次时间，说明时钟不对
	      throw new IllegalStateException("Clock moved backwards.");
	    }
	    if (time == lastTime) {
	      seqId = (seqId + 1) & SEQ_MASK;
	      if (seqId == 0) {//说明该毫秒下对序列已经自增完毕，等待下一个毫秒
	        tilNextMillis(lastTime);
	      }
	    } else {
	      seqId = INIT_SEQ;
	    }
	    lastTime = time;
	    long id = time << TIME_LEFT_BIT;
	    id |= serverId << SERVER_LEFT_BIT;
	    id |= seqId;// & SEQ_MASK;
	    return id;
	  }
	
	  /**
	   * 从主键中提取时间.
	   * 将ID左移22位，提取出时间
	   *
	   * @param id 主键
	   * @return 时间
	   */
	  @Override
	  public long fetchTime(Long id) {
	    return id >> TIME_LEFT_BIT;
	  }
	
	  @Override
	  public long fetchServer(Long id) {
	    return (id ^ (fetchTime(id) << TIME_LEFT_BIT)) >> SERVER_LEFT_BIT;
	  }
	
	  @Override
	  public long fetchSeq(Long id) {
	    return (id ^ (fetchTime(id) << TIME_LEFT_BIT)) ^ (fetchServer(id) << SERVER_LEFT_BIT);
	  }
	}

## 优缺点
优点：充分把信息保存到ID里。

缺点：结构略复杂，要依赖zookeeper。分片ID不能灵活生成。

# instagram的方案
instagram参考了flickr的方案，再结合twitter的经验，利用Postgres数据库的特性，实现了一个更简单可靠的ID生成服务。

    使用41 bit来存放时间，精确到毫秒，可以使用41年。  
    使用13 bit来存放逻辑分片ID。  
    使用10 bit来存放自增长ID，意味着每台机器，每毫秒最多可以生成1024个ID  