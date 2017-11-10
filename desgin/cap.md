CAP

http://www.hollischuang.com/archives/666

http://blog.csdn.net/chen77716/article/details/30635543

http://www.infoq.com/cn/articles/cap-twelve-years-later-how-the-rules-have-changed

# CAP

2000年7月，加州大学伯克利分校的Eric Brewer教授在ACM PODC会议上提出CAP猜想。2年后，麻省理工学院的Seth Gilbert和Nancy Lynch从理论上证明了CAP。之后，CAP理论正式成为分布式计算领域的公认定理。

一个分布式系统最多只能同时满足一致性（Consistency）、可用性（Availability）和分区容错性（Partition tolerance）这三项中的两项。

    C（一致性）：所有的节点上的数据时刻保持同步
    A（可用性）：每个请求都能接受到一个响应，无论响应成功或失败
    P（分区容错）：系统应该能持续提供服务，即使系统内部有消息丢失（分区）

# Consistency 一致性

一致性指“all nodes see the same data at the same time”，即更新操作成功并返回客户端完成后，所有节点在同一时间的数据完全一致。

对于一致性，可以分为从客户端和服务端两个不同的视角。从客户端来看，一致性主要指的是多并发访问时更新过的数据如何获取的问题。从服务端来看，则是更新如何复制分布到整个系统，以保证数据最终一致。一致性是因为有并发读写才有的问题，因此在理解一致性的问题时，一定要注意结合考虑并发读写的场景。

从客户端角度，多进程并发访问时，更新过的数据在不同进程如何获取的不同策略，决定了不同的一致性。对于关系型数据库，要求更新过的数据能被后续的访问都能看到，这是强一致性。如果能容忍后续的部分或者全部访问不到，则是弱一致性。如果经过一段时间后要求能访问到更新后的数据，则是最终一致性。

# Availability 可用性

可用性指“Reads and writes always succeed”，即服务一直可用，而且是正常响应时间。

对于一个可用性的分布式系统，每一个非故障的节点必须对每一个请求作出响应。也就是，该系统使用的任何算法必须最终终止。当同时要求分区容忍性时，这是一个很强的定义：即使是严重的网络错误，每个请求必须终止。

好的可用性主要是指系统能够很好的为用户服务，不出现用户操作失败或者访问超时等用户体验不好的情况。可用性通常情况下可用性和分布式数据冗余，负载均衡等有着很大的关联。

# Partition Tolerance分区容错性

分区容错性指“the system continues to operate despite arbitrary message loss or failure of part of the system”，即分布式系统在遇到某节点或网络分区故障的时候，仍然能够对外提供满足一致性和可用性的服务。

分区容错性和扩展性紧密相关。在分布式应用中，可能因为一些分布式的原因导致系统无法正常运转。好的分区容错性要求能够使应用虽然是一个分布式系统，而看上去却好像是在一个可以运转正常的整体。比如现在的分布式系统中有某一个或者几个机器宕掉了，其他剩下的机器还能够正常运转满足系统需求，或者是机器之间有网络异常，将分布式系统分隔为独立的几个部分，各个部分还能维持分布式系统的运作，这样就具有好的分区容错性。



# 举例

假设网络中有两个节点N1和N2，可以简单的理解N1和N2分别是两台计算机，他们之间网络可以连通，N1中有一个应用程序A，和一个数据库V，N2也有一个应用程序B2和一个数据库V。现在，A和B是分布式系统的两个部分，V是分布式系统的数据存储的两个子数据库。

	N1	+-----+      +-----+
		| A   |      | V0  |
		+-----+      +-----+

	N2	+-----+      +-----+
		| B   |      | V0  |
		+-----+      +-----+

- 在满足一致性的时候，N1和N2中的数据是一样的，V0=V0。
- 在满足可用性的时候，用户不管是请求N1或者N2，都会得到立即响应。
- 在满足分区容错性的情况下，N1和N2有任何一方宕机，或者网络不通的时候，都不会影响N1和N2彼此之间的正常运作。

下图描述了分布式系统正常运转的流程，用户向N1机器请求数据更新，程序A更新数据库V0为V1，分布式系统将数据进行同步操作M，将V1同步的N2中V0，使得N2中的数据V0也更新为V1，N2中的数据再响应N2的请求。

第一步,用户向N1机器请求数据更新，程序A更新数据库V0为V1

	N1	+-----+  V1  +-----+
		| A   + ---->| V0  |
		+-----+      +-----+

	N2	+-----+      +-----+
		| B   |      | V0  |
		+-----+      +-----+

第二步,分布式系统将数据进行同步操作M，将V1同步的N2中V0，使得N2中的数据V0也更新为V1

	N1	+-----+      +-----+
		| A   +      | V1  |
		+-----+      +-----+
		                |M
		                v
	N2	+-----+      +-----+
		| B   |      | V0  |
		+-----+      +-----+

第三步，N2中的数据再响应N2的请求

	N1	+-----+      +-----+
		| A   +      | V1  |
		+-----+      +-----+

	N2	+-----+   V1 +-----+
		| B   | <----| V1  |
		+-----+      +-----+

这里，可以定义N1和N2的数据库V之间的数据是否一样为一致性；外部对N1和N2的请求响应为可用行；N1和N2之间的网络环境为分区容错性。这是正常运作的场景，也是理想的场景，然而现实是残酷的，当错误发生的时候，一致性和可用性还有分区容错性，是否能同时满足，还是说要进行取舍呢？


作为一个分布式系统，它和单机系统的最大区别，就在于网络，现在假设一种极端情况，N1和N2之间的网络断开了，我们要支持这种网络异常，相当于要满足分区容错性，能不能同时满足一致性和响应性呢？还是说要对他们进行取舍。

假设在N1和N2之间网络断开的时候，有用户向N1发送数据更新请求

那N1中的数据V0将被更新为V1，由于网络是断开的，所以分布式系统同步操作M失败，所以N2中的数据依旧是V0；这个时候，有用户向N2发送数据读取请求，由于数据还没有进行同步，应用程序没办法立即给用户返回最新的数据V1，怎么办呢？有二种选择，第一，牺牲数据一致性，响应旧的数据V0给用户；第二，牺牲可用性，阻塞等待，直到网络连接恢复，数据更新操作M完成之后，再给用户响应最新的数据V1。

第一步,用户向N1机器请求数据更新，程序A更新数据库V0为V1

	N1	+-----+  V1  +-----+
		| A   + ---->| V0  |
		+-----+      +-----+

	N2	+-----+      +-----+
		| B   |      | V0  |
		+-----+      +-----+

第二步,分布式系统将数据进行同步操作M，由于网络是断开的，所以分布式系统同步操作M失败,N2中的数据依旧是V0

	N1	+-----+      +-----+
		| A   +      | V1  |
		+-----+      +-----+
		                |M（失败）
		                x
	N2	+-----+      +-----+
		| B   |      | V0  |
		+-----+      +-----+

第三步，有用户向N2发送数据读取请求，由于数据还没有进行同步，应用程序没办法立即给用户返回最新的数据V1，此时有两种选择 1）牺牲数据一致性，响应旧的数据V0给用户；2）牺牲可用性，阻塞等待，直到网络连接恢复，数据更新操作M完成之后，再给用户响应最新的数据V1

	N1	+-----+      +-----+
		| A   +      | V1  |
		+-----+      +-----+

	N2	+-----+   V0 +-----+
		| B   | <----| V0  |
		+-----+      +-----+

这个过程，证明了要满足分区容错性的分布式系统，只能在一致性和可用性两者中，选择其中一个。


# CAP权衡

通过CAP理论，我们知道无法同时满足一致性、可用性和分区容错性这三个特性，那要舍弃哪个呢？

    CA without P：如果不要求P（不允许分区），则C（强一致性）和A（可用性）是可以保证的。但其实分区不是你想不想的问题，而是始终会存在，因此CA的系统更多的是允许分区后各子系统依然保持CA。

    CP without A：如果不要求A（可用），相当于每个请求都需要在Server之间强一致，而P（分区）会导致同步时间无限延长，如此CP也是可以保证的。很多传统的数据库分布式事务都属于这种模式。

    AP wihtout C：要高可用并允许分区，则需放弃一致性。一旦分区发生，节点之间可能会失去联系，为了高可用，每个节点只能用本地数据提供服务，而这样会导致全局数据的不一致性。现在众多的NoSQL都属于此类。


对于分布式系统来说，分区容错是基本要求，所以必然要放弃一致性。对于大型网站来说，分区容错和可用性的要求更高，所以一般都会选择适当放弃一致性。

对应CAP理论，NoSQL追求的是AP，而传统数据库追求的是CA，这也可以解释为什么传统数据库的扩展能力有限的原因。

# CAP被上升为定理

2002年，Lynch与其他人证明了Brewer猜想，从而把CAP上升为一个定理。但是，她只是证明了CAP三者不可能同时满足，并没有证明任意二者都可满足的问题，所以，该证明被认为是一个收窄的结果。

Lynch的证明相对比较简单：**采用反正法，如果三者可同时满足，则因为允许P的存在，一定存在Server之间的丢包，如此则不能保证C，证明简洁而严谨。**
在该证明中，对CAP的定义进行了更明确的声明：

    C：一致性被称为原子对象，任何的读写都应该看起来是“原子“的，或串行的。写后面的读一定能读到前面写的内容。所有的读写请求都好像被全局排序。
    A：对任何非失败节点都应该在有限时间内给出请求的回应。（请求的可终止性）
    P：允许节点之间丢失任意多的消息，当网络分区发生时，节点之间的消息可能会完全丢失


看了下[http://www.infoq.com/cn/articles/cap-twelve-years-later-how-the-rules-have-changed](http://www.infoq.com/cn/articles/cap-twelve-years-later-how-the-rules-have-changed "CAP理论十二年回顾："规则"变了")，虽然有些地方仍然不是很理解，但还是在这里做下记录，方便日后再次学习(只记录了部分内容)

# CAP和延迟的联系

CAP理论的经典解释，是忽略网络延迟的，但在实际中延迟和分区紧密相关。CAP从理论变为现实的场景发生在操作的间歇，系统需要在这段时间内做出关于分区的一个重要决定：

    取消操作因而降低系统的可用性，还是

    继续操作，以冒险损失系统一致性为代价

依靠多次尝试通信的方法来达到一致性，比如Paxos算法或者两阶段事务提交，仅仅是推迟了决策的时间。系统终究要做一个决定；无限期地尝试下去，本身就是选择一致性牺牲可用性的表现。

因此以实际效果而言，分区相当于对通信的时限要求。系统如果不能在时限内达成数据一致性，就意味着发生了分区的情况，必须就当前操作在C和A之间做出选择。这就从延迟的角度抓住了设计的核心问题：分区两侧是否在无通信的情况下继续其操作？ 

从这个实用的观察角度出发可以导出若干重要的推论。第一，分区并不是全体节点的一致见解，因为有些节点检测到了分区，有些可能没有。第二，检测到分区的节点即进入分区模式——这是优化C和A的核心环节。

最后，这个观察角度还意味着设计师可以根据期望中的响应时间，有意识地设置时限；时限设得越短，系统进入分区模式越频繁，其中有些时候并不一定真的发生了分区的情况，可能只是网络变慢而已。


# 管理分区
管理分区有三个步骤

    检测到分区开始
    明确进入分区模式，限制某些操作，并且
    当通信恢复后启动分区恢复过程

最后一步的目的是恢复一致性，以及补偿在系统分区期间程序产生的错误。

![](http://www.infoq.com/resource/articles/cap-twelve-years-later-how-the-rules-have-changed/zh/resources/fig1large.jpg)

上图可见分区的演变过程。普通的操作都是顺序的原子操作，因此分区总是在两笔操作之间开始。一旦系统在操作间歇检测到分区发生，检测方一侧即进入分区模式。如果确实发生了分区的情况，那么一般分区两侧都会进入到分区模式，不过单方面完成分区也是可能的。单方面分区要求在对方按需要通信的时候，本方要么能正确响应，要么不需要通信；总之操作不得破坏一致性。但不管怎么样，由于检测方可能有不一致的操作，它必须进入分区模式。采取了quorum决定机制的系统即为单方面分区的例子。其中一方拥有“法定通过节点数”，因此可以执行操作，而另一方不可以执行操作。支持离线操作的系统明显地含有“分区模式”的概念，一些支持原子多播（atomic multicast）的系统也含有这个概念，如Java平台的JGroups。

当系统进入到分区模式，它有两种可行的策略。其一是限制部分操作，因此会削弱可用性。其二是额外记录一些有利于后面分区恢复的操作信息。系统可通过持续尝试恢复通信来察觉分区何时结束。

**哪些操作可以执行？**

决定限制哪些操作，主要取决于系统需要维持哪几项不变性约束。在给定了不变性约束条件之后，设计师需要决定在分区模式下，是否坚持不触动某项不变性约束，抑或以事后恢复为前提去冒险触犯它。例如，对于“表中键的惟一性”这项不变性约束，设计师一般都选择在分区期间放宽要求，容许重复的键。重复的键很容易在恢复阶段检查出来，假如重复键可以合并，那么设计师不难恢复这项不变性约束。

对于分区期间必须维持的不变性约束，设计师应当禁止或改动可能触犯该不变性约束的操作。（一般而言，我们没办法知道操作是否真的会破坏不变性约束，因为无法知道分区另一侧的状态。）信用卡扣费等具有外部化特征的事件常以这种方式工作。适合这种情况的策略，是记录下操作意图，然后在分区恢复后再执行操作。这类事务往往从属于一些更大的工作流，在工作流明确含有类似“订单处理中”状态的情况下，将操作推迟到分区结束并无明显的坏处。设计师以用户不易察觉的方式牺牲了可用性。用户只知道自己下了指令，系统稍后会执行。


说得更概括一点，分区模式给用户界面提出了一种根本性的挑战，即如何传达“任务正在进行尚未完成”的信息。研究者已经从离线操作的角度对此问题进行了一些深入的探索，离线操作可以看成时间很长的一次分区。例如Bayou的日历程序用颜色来区分显示可能（暂时）不一致的条目13。工作流应用和带离线模式的云服务中也常见类似的提醒，前者的例子如交易中的电子邮件通知，后者的例子如Google Docs。

在分区模式的讨论中，我们将关注点放在有明确意义的原子操作而非单纯的读写，其中一个原因是操作的抽象级别越高，对不变性约束的影响通常就越容易分析清楚。大体来说，设计师要建立一张所有操作与所有不变性约束的叉乘表格（cross product），观察并确定其中每一处操作可能与不变性约束相冲突的地方。对于这些冲突情况，设计师必须决定是否禁止、推迟或修改相应的操作。在实践中，这类决定还受到分区前状态和/或环境参数的影响。例如有的系统为特定的数据设立了主节点，那么一般允许主节点执行操作，不允许其他节点操作。

对分区两侧跟踪操作历史的最佳方式是使用版本向量，版本向量可以反映操作间的因果依赖关系。向量的元素是（节点, 逻辑时间）数值对，分别对应一个更新了对象的节点和它最后更新的时间。对于同一对象的两个给定的版本A和B，当所有结点的版本向量一致有A的时间大于或等于B的时间，且至少有一个节点的版本向量有A的时间较大，则A新于B。

**分区恢复**

到了某个时刻，通信恢复，分区结束。由于每一侧在分区期间都是可用的，其状态仍继续向前进展，但是分区会推迟某些操作并侵犯一些不变性约束。分区结束的时刻，系统知道分区两侧的当前状态和历史记录，因为它在分区模式下记录了详尽的日志。当前状态不如历史记录有价值，因为通过历史记录，系统可以判断哪些操作违反了不变性约束，产生了何种外在的后果（如发送了响应给用户）。在分区恢复过程中，设计师必须解决两个问题：

    分区两侧的状态最终必须保持一致，
    并且必须补偿分区期间产生的错误。

通常情况，矫正当前状态最简单的解决方法是回退到分区开始时的状态，以特定方式推进分区两侧的一系列操作，并在过程中一直保持一致的状态。Bayou就是这个实现机制，它会回滚数据库到正确的时刻并按无歧义的、确定性的顺序重新执行所有的操作，最终使所有的节点达到相同的状态15。同样地，并发版本控制系统CVS在合并分支的时候，也是从从一个共享的状态一致点开始，逐步将更新合并上去。。

大部分系统都存在不能自动合并的冲突。比如，CVS时不时有些冲突需要手动介入，带离线模式的wiki系统总是把冲突留在产生的文档里给用户处理

相反，有些系统用了限制操作的办法来保证冲突总能合并。一个例子就是Google Docs将其文本编辑操作17精简为应用样式、添加文本和删除文本。因此，虽然总的来说冲突问题不可解，但现实中设计师可以选择在分区期间限制使用部分操作，以便系统在恢复的时候能够自动合并状态。如果要实施这种策略，推迟有风险的操作是相对简单的实现方式。

还有一种办法是让操作可以交换顺序，这种办法最接近于形成一种解决自动状态合并问题的通用框架。此类系统将线性合并各日志并重排操作的顺序，然后执行。操作满足交换率，意味着操作有可能重新排列成一种全局一致的最佳顺序。不幸的是，只允许满足交换率的操作这个想法实现起来没那么容易。比如加法操作可以交换顺序，但是加入了越界检查的加法就不行了。

**CRDTs**
略

**补偿错误**

比计算分区后状态更难解决的问题是如何弥补分区期间造成的错误。跟踪和限制分区模式下的操作，这两种措施足以使设计师确知哪些不变性约束可能被违反，然后分别为它们制定恢复策略。一般系统在分区恢复期间检查违反情况，修复工作也必须在这段时间内完成。

恢复不变性约束的方法有很多，粗陋一点的办法如“最后写入者胜”（因此会忽略部分更新），聪明一点的办法如合并操作和人为跟进事态（human escalation）。人为跟进事态的例子如飞机航班“超售”的情形：可以把乘客登机看作是对之前售票情况的分区恢复，必须恢复“座位数不少于乘客数”这项不变性约束。那么当乘客太多的时候，有些乘客将失去座位，客服最好能设法补偿他们。

航班的例子揭示了一个外在错误（externalized mistake）：假如航空公司没说过乘客一定有座位，这个问题会好解决得多。因此我们看到推迟有风险的操作的又一个理由——到了分区恢复的时候，我们才知道真实的情况。矫正此类错误的核心概念是“补偿（compensation）”；设计师必须设立补偿操作，除了恢复不变性约束，还要纠正外在错误。

恢复外在错误通常要求知道一些有关外在输出的历史信息。以“喝醉酒打电话”为例，一位老兄不记得自己昨晚喝高了的时候打过几个电话，虽然他第二天白天恢复了正常状态，但通话日志上的记录都还在，其中有些通话很可能是错误的。拨出的电话就是这位老兄的状态（喝高了）的外在影响。而由于这位老兄不记得打过什么电话，也就很难补偿其中可能造成的麻烦。

又以机器为例，电脑可能在分区期间把一份订单执行了两次。如果系统能区分两份一样的订单是有意的还是重复了，它就能取消掉一份重复的订单。如果这次错误产生了外在影响，补偿策略可以是自动生成一封电子邮件，向顾客解释系统意外将订单执行了两次，现在错误已经被纠正，附上一张优惠券下次可以用。假如没有完善的历史记录，就只好靠顾客亲自去发现错误了。

曾经有人正式研究过将补偿性事务作为处理长寿命事务（long-lived transactions）的一种手段21,22。长时间运行的事务会面临另一种形态的分区决策：是长时间持有锁来保证一致性比较好呢？还是及早释放锁向其他事务暴露未提交的数据，提高并发能力比较好呢？比如在单笔事务中更新所有的员工记录就是一个典型例子。按照一般的方式串行化这笔事务，将导致所有的记录都被锁定，阻止并发。而补偿性事务采取另一种方式，它将大事务拆成多个分别提交的子事务。如果要中止大事务，系统必须发起一笔新的、起纠正作用的事务，逐一撤销所有已经提交的子事务，这笔新事务就是所谓的补偿性事务。

总的来说，补偿性事务的目的是避免中止其他用了未正确提交数据的事务（即不允许级联取消）。这种方案不依赖串行化或隔离的手段来保障正确性，其正确性取决于事务序列对状态和输出所产生的净影响。那么，经过补偿，数据库的状态究竟是不是相当于那些子事务根本没执行过一样呢？考虑等价必须连外在行为也包括在内；举个例子，把重复扣取的交易款退还给顾客，很难说成等于一开始就没多收顾客的钱，但从结果上看勉强算扯平了。分区恢复也延续同样的思路。虽然服务不一定总能直接撤销其错误，但起码承认错误并做出新的补偿行为。怎样在分区恢复中运用这种思路效果最好，这个问题没有固定的答案。“自动柜员机上的补偿问题”小节以一个很小的应用领域为例点出了一些思考方向。

当系统中存在分区，系统设计师不应该盲目地牺牲一致性或可用性。运用以上讨论的方法，设计师通过细致地管理分区期间的不变性约束，两方面的性质都可以取得最佳的表现。随着版本向量和CRDTs等比较新的技术逐渐被纳入一些简化其用法的框架，这方面的优化手段会得到比较普遍的应用。但引入CAP实践毕竟不像引入ACID事务那么简单，实施的时候需要对过去的策略进行全面的考虑，最佳的实施方案极大地依赖于具体服务的不变性约束和操作细节。

**自动柜员机上的补偿问题**

以自动柜员机（ATM）的设计来说，强一致性看似符合逻辑的选择，但现实情况是可用性远比一致性重要。理由很简单：高可用性意味着高收入。不管怎么样，讨论如何补偿分区期间被破坏的不变性约束，ATM的设计很适合作为例子。

ATM的基本操作是存款、取款、查看余额。关键的不变性约束是余额应大于或等于零。因为只有取款操作会触犯这项不变性约束，也就只有取款操作将受到特别对待，其他两种操作随时都可以执行。

ATM系统设计师可以选择在分区期间禁止取款操作，因为在那段时间里没办法知道真实的余额，当然这样会损害可用性。现代ATM的做法正相反，在stand-in模式下（即分区模式），ATM限制净取款额不得高于k，比如k为$200。低于限额的时候，取款完全正常；当超过限额的时候，系统拒绝取款操作。这样，ATM成功将可用性限制在一个合理的水平上，既允许取款操作，又限制了风险。

分区结束的时候，必须有一些措施来恢复一致性和补偿分区期间系统所造成的错误。状态的恢复比较简单，因为操作都是符合交换率的，补偿就要分几种情况去考虑。最后的余额低于零违反了不变性约束。由于ATM已经把钱吐出去了，错误成了外部实在。银行的补偿办法是收取透支费并指望顾客偿还。因为风险已经受到限制，问题并不严重。还有一种情况是分区期间的某一刻余额已经小于零（但ATM不知道），此时一笔存款重新将余额变为正的。银行可以追溯产生透支费，也可以因为顾客已经缴付而忽略该违反情况。

总而言之，因为通信延迟的存在，银行系统不依靠一致性来保证正确性，而更多地依靠审计和补偿。“空头支票诈骗”也是类似的例子，顾客赶在多家分行对账之前分别取出钱来然后逃跑。透支的错误过后才会被发现，对错误的补偿也许体现为法律行动的形式。