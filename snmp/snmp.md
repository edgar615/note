http://bluedream.me/post/ji-zhu/snmp

http://freeloda.blog.51cto.com/2033581/1306743

http://blog.csdn.net/shmily_cml0603/article/details/12968157

网络管理

网络管理分为两类。第一类是网络应用程序、用户帐号（例如文件的使用）和存取权限（许可）的 管理。它们都是与软件有关的网络管理问题。这里不作讨论。

网络管理的第二类是由构成网络的硬件所组成。这一类包括工作站、服务器、网卡、路由器、 网桥和集线器等等。通常情况下这些设备都离你所在的地方很远。正是由于这个原因，如果当 设备有问题发生时网络管理员可以自动地被通知的话，那么一切事情都好办。但是你的路由器 不会象你的用户那样，当有一个应用程序问题发生时就可以打电话通知你，而当路由器拥挤时 它并不能够通知你。

为了解决这个问题，厂商们已经在一些设备中设立了网络管理的功能，这样你就可以远程地询 问它们的状态，同样能够让它们在有一种特定类型的事件发生时能够向你发出警告。这些设备 通常被称为"智能"设备。

网络管理通常包括四个部分：

    被管理节点(或设备) 即你想要监视的设备
    代理 用来跟踪被管理设备状态的特殊软件或固件 (firmware)
    网络管理工作站 与在不同的被管理节点中的代理通信，并且显示这些代理状态的中心设备。
    网络管理协议 被网络管理工作站和代理用来交换信息的协议。

当设计和构造网络管理的基础结构时，你需要记住下列两条网络管理的原则：

    由于管理信息而带来的通信量不应明显的增加网络的通信量。
    被管理设备上的协议代理不应明显得增加系统处理的额外开销，以致于该设备的主要功能都被削弱了。

## SNMP协议

简单网络管理协议(SNMP)首先是由Internet工程任务组织(Internet Engineering Task Force)(IETF)的研究小组为了解决Internet上的路由器管理问题而提出的。许多人认为 SNMP在IP上运行的原因是Internet运行的是TCP/IP协议，然而事实并不是这样。

SNMP被设计成与协议无关，所以它可以在IP，IPX，AppleTalk，OSI以及其他用到的传输协议上被使用。

SNMP是一系列协议组和规范（见下表），它们提供了一种从网络上的设备中收集网络管理信息的方法。SNMP也为设备向网络管理工作站报告问题和错误提供了一种方法。

<table>
<tr>
<th>名字</th>
<th>说明</th>
</tr>
<tr>
<td>MIB</td>
<td>管理信息库</td>
</tr>
<tr>
<td>SMI</td>
<td>管理信息的结构和标识</td>
</tr>
<tr>
<td>SNMP</td>
<td>简单网络管理协议</td>
</tr>
</table>

从被管理设备中收集数据有两种方法：一种是只轮询（polling-only）的方法，另一种是基于中断（interrupt-based）的方法。

如果你只使用只轮询的方法，那么网络管理工作站总是在控制之下。而这种方法的缺陷在于信息的实时性，尤其是错误的实时性。你多久轮询一次，并且在轮询时按照什么样的设备顺序呢？如果轮询间隔太小，那么将产生太多不必要的通信量。如果轮询间隔太大，并且在轮询时顺序不对，那么关于一些大的灾难性的事件的通知又会太馒。这就违背了积极主动的网络管理目的。

当有异常事件发生时，基于中断的方法可以立即通知网络管理工作站（在这里假设该设备还没有崩溃，并且在被管理设备和管理工作站之间仍有一条可用的通信途径）。然而，这种方法也不是没有他的缺陷的，首先，产生错误或自陷需要系统资源。如果自陷必须转发大量的信息，那么被管理设备可能不得不消耗更多的时间和系统资源来产生自陷，从而影响了它执行主要的功能（违背了网络管理的原则2）。

而且，如果几个同类型的自陷事件接连发生，那么大量网络带宽可能将被相同的信息所占用（违背了网络管理的原则1）。尤其是如果自陷是关于网络拥挤问题的时候，事情就会变得特别糟糕。克服这一缺陷的一种方法就是对于被管理设备来说，应当设置关于什么时候报告问题的阈值（threshold）。但不幸的是这种方法可能再一次违背了网络管理的原则2，因为设备必须消耗更多的时间和系统资源，来决定一个自陷是否应该被产生。

结果，以上两种方法的结合：面向自陷的轮询方法（trap-directed polling）可能是执行网络管理最为有效的方法了。一般来说，网络管理工作站轮询在被管理设备中的代理来收集数据，并且在控制台上用数字或图形的表示方式来显示这些数据。这就允许网络管理员分析和管理设备以及网络通信量了

被管理设备中的代理可以在任何时候向网络管理工作站报告错误情况，例如预制定阈值越界程度等等。代理并不需要等到管理工作站为获得这些错误情况而轮询他的时候才会报告。这些错误情况就是众所周知的SNMP自陷（trap）。

在这种结合的方法中，当一个设备产生了一个自陷时，你可以使用网络管理工作站来查询该设备（假设它仍然是可到达的），以获得更多的信息。

## 被管理设备

你可能听说过许多关于“SNMP可管理设备”、“与SNMP兼容的设备”或者“被SNMP管理的设备”的说法。但是它们到底什么？它们与“智能设备”又是怎么区别的呢？

简单地说，以上所有说法的意思都是“一个包含网络管理代理实现的网络设备”。这些话也意味着这种代理支持SNMP协议来进行信息交换。正如前面所提到的，一个智能设备可能并不需要使用或支持SNMP协议。那么什么是一个代理呢？

## 代理

管理代理（agent）是一种特殊的软件（或固件），它包含了关于一个特殊设备和/或该设备所处环境的信息。当一个代理被安装到一个设备上时，上述的设备就被列为“被管理的”。换句话说，代理就是一个数据库。

数据库中所包含的数据随被安装设备的不同而不同。举例来说，在一个路由器上，代理将包含关于路由选择表、接收和发送包的总数等信息。而对于一个网桥来说，数据库可能包含关于转发包数目和过滤表等信息。

代理是与网络管理控制台通信的软件或固件。在这个控制台的“链路”上可以执行以下任务：

    网络管理工作站可以从代理中获得关于设备的信息。
    网络管理工作站可以修改、增加或者删除代理中的表项，例如在由代理所维护的数据库中的路由选择表表项。
    网络管理工作站可以为一个特定的自陷设置阈值。
    代理可以向网络管理工作站发送自陷。

请记住，在被管理设备中的代理并不是自愿提供信息的，除非当有一个阈值被超过的事件发生时。

在一些偶然的情况下，在一个特定的设备上可能因为系统资源的缺乏，或者因为该设备不支持SNMP代理所需要的传输协议，而不能实现一个SNMP代理。这是否就意味着你不能监视这个设备呢？答案并不是这样的，在这种情况下并不是完全没有办法的。你可以使用受托代理（proxy agent），它相当于外部设备（foreign device）。

受托代理并非在被管理的外部设备上运行，而是在另一个设备上运行。网络管理工作站首先与受托代理联系，并且指出（通过某种方法）受托代理与外部设备的一致性。然后受托代理把它接收到的协议命令翻译成任何一种外部设备所支持的管理协议。在这种情况下，受托代理就被称为应用程序网关（application gateway）。

如果外部设备不支持任何管理协议，那么受托代理必须使用一些被动的方法来监视这个设备。举例来说，一个令牌环网桥的受托代理可以监视它的性能，并且如果它检测到任何由网桥所报告的拥挤错误时，它就会产生自陷。幸运的是，目前大多数网际互联设备类型都是支持SNMP可管理设备的，所以你可以很容易地使用一个SNMP可管理设备，例如集线器、网桥和路由器。有一些厂商甚至还在他们的网卡上提供SNMP代理。

## MIB

我们通常很少把在一个被管理设备中的数据库称为一个数据库。在SNMP术语中它通常被称为管理信息库（MIB）。

一个MIB描述了包含在数据库中的对象或表项。每一个对象或表项都有以下四个属性：

    对象类型（Object Type）
    语法（Syntax）
    存取（Access）
    状态（Status）

在SNMP规范之一的管理信息结构与标识（SMI；RFC 1155/1065）规范中定义了这些属性。SMI对于MIB来说就相当于模式对于数据库。SMI定义了每一个对象“看上去象什么”。

### 对象类型

这个属性定义了一个特定对象的名字，例如sysUpTime。它只不过是一个标记。在表示数据时，SMI使用了ASN.1(Abstract Syntax Notation One)。对象必须被“标识”。对于互联网络管理MIB来说，用ASN.1记法来表示的标识符开头如下：

	internet OBJECT IDENTIFIER : : = { iso org(3) dod(6) 1 }

或者用一种简单的格式：

		1.3.6.1

这是从ASN.1文档中抽取的。它为标识符定义了一个树形的格式。该树是由一个根及与之相连接的许多被标记的节点组成。每一个节点由一个非负整数值和尽可能简明的文字说明所标识。每一个节点可能也拥有同样被标记的子节点。

当描述一个对象标识符（OBJECT INDENTIFIER）时，你可以使用几种格式，最简单的格式是列出由根开始到所讨论的对象遍历该树所找到的整数值。

SNMP的管理信息库采用和域名系统DNS相似的树型结构，它的根在最上面，根没有名字。图1画的是管理信息库的一部分，它又称为对象命名（objectnamingtree）。 

![](http://static.oschina.net/uploads/space/2013/0420/215148_VTeV_857839.jpg)

 对象命名树的顶级对象有三个，即ISO、ITU-T和这两个组织的联合体。在ISO的下面有4个结点，其中的饿一个（标号3）是被标识的组织。在其下面有一个美国国防部（Department
of
Defense）的子树（标号是6），再下面就是Internet（标号是1）。在只讨论Internet中的对象时，可只画出Internet以下的子树（图中带阴影的虚线方框），并在Internet结点旁边标注上{1.3.6.1}即可。

 

在Internet结点下面的第二个结点是mgmt（管理），标号是2。再下面是管理信息库，原先的结点名是mib。1991年定义了新的版本MIB-II，故结点名现改为mib-2，其标识为{1.3.6.1.2.1}，或{Internet(1)
.2.1}。这种标识为对象标识符。 

最初的结点mib将其所管理的信息分为8个类别，见表1。现在de mib-2所包含的信息类别已超过40个

![](http://static.oschina.net/uploads/space/2013/0420/215247_w4Pe_857839.jpg)

### 语法

这个属性指定了数据类型，例如整数、8位组串数字（字符串；范围为0至255）、对象标识符（预先定义的数据类型别名）或NULL。NULL是留待的后使用的空位。

### 存取

存取表明了这个特定对象的存取级别。合法的值有：只读、读写、只写和不可存取。

### 状态

状态定义了这个对象的实现需要：必备的（被管理节点必须实现该对象）；可选的（被管理对象可能实现该对象）；或者已废弃的（被管理设备不需要再实现该对象）。

## 简单网络管理协议

简单网络管理协议允许网络管理工作站软件与被管理设备中的代理进行通信。这种通信可以包括来自管理工作站的询问消息、来自代理的应答消息或者来自代理给管理工作站的自陷消息。

为了保证因网络管理而带来的通信量是最小的（网络管理原则1），SNMP使用了一种异步客户机/服务器方法。这意味着一个SNMP实体（管理工作站或被管理设备）在发出一条消息后不需要等待一个应答；然而，除了自陷的情况以外应答都是要被产生的。如果需要的话该实体可以发送另一条消息，或者也可以继续它预先被定义的功能。SNMPv1实现起来很简单并且对资源占用不多，它只有5个请求/响应原语：

    get-request
    set-request
    get-next-request
    get-reponse
    trap

![](http://img.blog.csdn.net/20131027024018218?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc2htaWx5X2NtbDA2MDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

网络管理工作站可以把感兴趣的变量值提取到其应用程序中，只要发出get-request或get-next-request报文即可。前者是指定对象的读操作，后者则提供了一个树遍历操作符，便于确定一个代理进程支持哪些对象。网络管理工作站可以修改代理进程中的变量值，只要发出set-request报文即可。

如果没有发生错误，代理进程可以用get-reponse原语回答这些请求。另外，利用trap原语，代理进程可以异步地发送告警给网络管理工作站，告诉它发生了某个满足预设条件的事件。

实现中的经验和设计过程中的不断完善给SNMPv2带来了协议改进意见，即给网络管理工作站增加一个成块读操作get-bulk-request报文。当需要用一个请求原语提取大量数据（如读取某个表的内容）时就可以调用它以提高效率。SNMPv2也引进管理进程和管理进程之间的通信进行状况报告，为此增加了一条原语inform-request，并把get-response简化成更加合理的名称reponse。trap报文则已改为snmpv2-trap，并与所有的协议报文具有同样的格式。

## 巧妙而有效地管理网络

网络管理的两种方法是积极主动（pro-active）的方法和被动反应（re-active）得分方法。在大多数的时间里，我们总是要对一个事件作出反应，但这并不是有效的网络管理。 在积极主动的方式中，你所有现存的资源都得到了充分使用。如果你有智能集线器，那么请你把它找出来。几乎所有现存的路由器都至少在MIB－I级别上支持SNMP协议。如果你不能确定的话，请你和厂商联系。

当管理网络时，你需要明确的第一件事情就是要知道什么时候网络出问题。但是，你怎样辨别网络出问题了呢？对于人类来说，你会寻找以下症状，你会检查体温和脉搏。你网络上的症状也可以被监视，例如带宽利用率随时间的变化、服务器和路由器上的CPU利用率及通常在网线上的错误量（你总有以下错误）。请你使用网络管理工作站来跟踪这些统计数据一段时间，不如说两个星期，并且统计出一天中不同时候的平均值。这将成为你的基准线（baseline）。

一个基准线就是一系列数字，这些数字反映出了一个“健康”的网络。对于人类来说，一个“正常而且健康”的体温是37度。这就是你区分一个人是否发烧的基准线。你也需要一个基准线来决定你的网络是否出了问题。通过监视被管理设备中的网络阈值设置，并且寻找故障的征兆，你就可以拥有一个提前报警的系统


# 常用SNMP OID列表
http://www.ttlsa.com/monitor/snmp-oid/

<table>
<tbody>
<tr>
<td colspan="4">
系统参数（1.3.6.1.2.1.1）
</td>
</tr>
<tr>
<td>OID</td>
<td>描述</td>
<td>备注</td>
<td>请求方式</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.1.1.0</td>
<td>获取系统基本信息</td>
<td>SysDesc</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.1.3.0</td>
<td>监控时间</td>
<td>sysUptime</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.1.4.0</td>
<td>系统联系人</td>
<td>sysContact</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.1.5.0</td>
<td>获取机器名</td>
<td>SysName</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.1.6.0</td>
<td>机器坐在位置</td>
<td>SysLocation</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.1.7.0</td>
<td>机器提供的服务</td>
<td>SysService</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.4.2.1.2</td>
<td>系统运行的进程列表</td>
<td>hrSWRunName</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.6.3.1.2</td>
<td>系统安装的软件列表</td>
<td>hrSWInstalledName</td>
<td>WALK</td>
</tr>
</tbody>
</table>

<table>
<tbody>
<tr>
<td colspan="4">网络接口（1.3.6.1.2.1.2）</td>
</tr>
<tr>
<td>OID</td>
<td>描述</td>
<td>备注</td>
<td>请求方式</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.1.0</td>
<td>网络接口的数目</td>
<td>IfNumber</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.2</td>
<td>网络接口信息描述</td>
<td>IfDescr</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.3</td>
<td>网络接口类型</td>
<td>IfType</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.4</td>
<td>接口发送和接收的最大IP数据报[BYTE]</td>
<td>IfMTU</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.5</td>
<td>接口当前带宽[bps]</td>
<td>IfSpeed</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.6</td>
<td>接口的物理地址</td>
<td>IfPhysAddress</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.8</td>
<td>接口当前操作状态[up|down]</td>
<td>IfOperStatus</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.10</td>
<td>接口收到的字节数</td>
<td>IfInOctet</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.16</td>
<td>接口发送的字节数</td>
<td>IfOutOctet</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.11</td>
<td>接口收到的数据包个数</td>
<td>IfInUcastPkts</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.2.2.1.17</td>
<td>接口发送的数据包个数</td>
<td>IfOutUcastPkts</td>
<td>WALK</td>
</tr>
</tbody>
</table>

<table>
<tbody>
<tr>
<td colspan="4">CPU及负载</td>
</tr>
<tr>
<td>OID</td>
<td>描述</td>
<td>备注</td>
<td>请求方式</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.9.0</td>
<td>用户CPU百分比</td>
<td>ssCpuUser</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.10.0</td>
<td>系统CPU百分比</td>
<td>ssCpuSystem</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.11.0</td>
<td>空闲CPU百分比</td>
<td>ssCpuIdle</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.50.0</td>
<td>原始用户CPU使用时间</td>
<td>ssCpuRawUser</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.51.0</td>
<td>原始nice占用时间</td>
<td>ssCpuRawNice</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.52.0</td>
<td>原始系统CPU使用时间</td>
<td>ssCpuRawSystem.</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.53.0</td>
<td>原始CPU空闲时间</td>
<td>ssCpuRawIdle</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.3.3.1.2</td>
<td>CPU的当前负载，N个核就有N个负载</td>
<td>hrProcessorLoad</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.3.0</td>
<td>ssSwapIn</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.4.0</td>
<td>SsSwapOut</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.5.0</td>
<td>ssIOSent</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.6.0</td>
<td>ssIOReceive</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.7.0</td>
<td>ssSysInterrupts</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.8.0</td>
<td>ssSysContext</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.54.0</td>
<td>ssCpuRawWait</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.56.0</td>
<td>ssCpuRawInterrupt</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.57.0</td>
<td>ssIORawSent</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.58.0</td>
<td>ssIORawReceived</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.59.0</td>
<td>ssRawInterrupts</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.60.0</td>
<td>ssRawContexts</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.61.0</td>
<td>ssCpuRawSoftIRQ</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.62.0</td>
<td>ssRawSwapIn.</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.11.63.0</td>
<td>ssRawSwapOut</td>
<td>
GET
</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.10.1.3.1</td>
<td>Load5</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.10.1.3.2</td>
<td>Load10</td>
<td>GET</td>
<td></td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.10.1.3.3</td>
<td>Load15</td>
<td>GET</td>
<td></td>
</tr>
</tbody>
</table>


<table>
<tbody>
<tr>
<td colspan="4">内存及磁盘（1.3.6.1.2.1.25）</td>
</tr>
<tr>
<td>OID</td>
<td>描述</td>
<td>备注</td>
<td>请求方式</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.2.0</td>
<td>获取内存大小</td>
<td>hrMemorySize</td>
<td>
GET
</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.3.1.1</td>
<td>存储设备编号</td>
<td>hrStorageIndex</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.3.1.2</td>
<td>存储设备类型</td>
<td>hrStorageType[OID]</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.3.1.3</td>
<td>存储设备描述</td>
<td>hrStorageDescr</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.3.1.4</td>
<td>簇的大小</td>
<td>hrStorageAllocationUnits</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.3.1.5</td>
<td>簇的的数目</td>
<td>hrStorageSize</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.2.1.25.2.3.1.6</td>
<td>使用多少，跟总容量相除就是占用率</td>
<td>hrStorageUsed</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.3.0</td>
<td>Total Swap Size(虚拟内存)</td>
<td>memTotalSwap</td>
<td>
GET
</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.4.0</td>
<td>Available Swap Space</td>
<td>memAvailSwap</td>
<td>
GET
</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.5.0</td>
<td>Total RAM in machine</td>
<td>memTotalReal</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.6.0</td>
<td>Total RAM used</td>
<td>memAvailReal</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.11.0</td>
<td>Total RAM Free</td>
<td>memTotalFree</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.13.0</td>
<td>Total RAM Shared</td>
<td>memShared</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.14.0</td>
<td>Total RAM Buffered</td>
<td>memBuffer</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.4.15.0</td>
<td>Total Cached Memory</td>
<td>memCached</td>
<td>GET</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.2</td>
<td>Path where the disk is mounted</td>
<td>dskPath</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.3</td>
<td>Path of the device for the partition</td>
<td>dskDevice</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.6</td>
<td>Total size of the disk/partion (kBytes)</td>
<td>dskTotal</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.7</td>
<td>Available space on the disk</td>
<td>dskAvail</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.8</td>
<td>Used space on the disk</td>
<td>dskUsed</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.9</td>
<td>Percentage of space used on disk</td>
<td>dskPercent</td>
<td>WALK</td>
</tr>
<tr>
<td>.1.3.6.1.4.1.2021.9.1.10</td>
<td>Percentage of inodes used on disk</td>
<td>dskPercentNode</td>
<td>WALK</td>
</tr>
</tbody>
</table>


针对Linux主机的对象标识符

（1）CPU负载
	
	1 minute Load: .1.3.6.1.4.1.2021.10.1.3.1
	5 minute Load: .1.3.6.1.4.1.2021.10.1.3.2
	15 minute Load: .1.3.6.1.4.1.2021.10.1.3.3

（2）CPU信息
	
	percentage of user CPU time: .1.3.6.1.4.1.2021.11.9.0
	raw user cpu time: .1.3.6.1.4.1.2021.11.50.0
	percentages of system CPU time: .1.3.6.1.4.1.2021.11.10.0
	raw system cpu time: .1.3.6.1.4.1.2021.11.52.0
	percentages of idle CPU time: .1.3.6.1.4.1.2021.11.11.0
	raw idle cpu time: .1.3.6.1.4.1.2021.11.53.0
	raw nice cpu time: .1.3.6.1.4.1.2021.11.51.0

（3）内存使用
	
	Total Swap Size: .1.3.6.1.4.1.2021.4.3.0
	Available Swap Space: .1.3.6.1.4.1.2021.4.4.0
	Total RAM in machine: .1.3.6.1.4.1.2021.4.5.0
	Total RAM used: .1.3.6.1.4.1.2021.4.6.0
	Total RAM Free: .1.3.6.1.4.1.2021.4.11.0
	Total RAM Shared: .1.3.6.1.4.1.2021.4.13.0
	Total RAM Buffered: .1.3.6.1.4.1.2021.4.14.0
	Total Cached Memory: .1.3.6.1.4.1.2021.4.15.0

（4）磁盘使用

	Path where the disk is mounted: .1.3.6.1.4.1.2021.9.1.2.1
	Path of the device for the partition: .1.3.6.1.4.1.2021.9.1.3.1
	Total size of the disk/partion (kBytes): .1.3.6.1.4.1.2021.9.1.6.1
	Available space on the disk: .1.3.6.1.4.1.2021.9.1.7.1
	Used space on the disk: .1.3.6.1.4.1.2021.9.1.8.1
	Percentage of space used on disk: .1.3.6.1.4.1.2021.9.1.9.1
	Percentage of inodes used on disk: .1.3.6.1.4.1.2021.9.1.10.1

（5）系统运行时间       

	.1.3.6.1.2.1.1.3.0当然，其实这个是mib下的，也就是公有的。

2.MIB对象标识符

也就是公有的对象标识符。

（1）System组

都是一些简单变量，没有table：
	
	sysDescr 1.3.6.1.2.1.1.1
	sysObjectID 1.3.6.1.2.1.1.2
	sysUpTime 1.3.6.1.2.1.1.3
	sysContact 1.3.6.1.2.1.1.4
	sysName 1.3.6.1.2.1.1.5
	sysLocation 1.3.6.1.2.1.1.6
	sysServices 1.3.6.1.2.1.1.7


（2）Interfaces组

	ifNumber 1.3.6.1.2.1.2.1

一个ifTable表（表格变量）：
	
	ifTable 1.3.6.1.2.1.2.2
	ifEntry 1.3.6.1.2.1.2.2.1
	ifIndex 1.3.6.1.2.1.2.2.1.1
	ifDescr 1.3.6.1.2.1.2.2.1.2
	ifType 1.3.6.1.2.1.2.2.1.3
	ifMtu 1.3.6.1.2.1.2.2.1.4
	ifSpeed 1.3.6.1.2.1.2.2.1.5
	ifPhysAddress 1.3.6.1.2.1.2.2.1.6
	ifAdminStatus 1.3.6.1.2.1.2.2.1.7
	ifOperStatus 1.3.6.1.2.1.2.2.1.8
	ifLastChange 1.3.6.1.2.1.2.2.1.9
	ifInOctets 1.3.6.1.2.1.2.2.1.10
	ifInUcastPkts 1.3.6.1.2.1.2.2.1.11
	ifInNUcastPkts 1.3.6.1.2.1.2.2.1.12
	ifInDiscards 1.3.6.1.2.1.2.2.1.13
	ifInErrors 1.3.6.1.2.1.2.2.1.14
	ifInUnknownProtos 1.3.6.1.2.1.2.2.1.15
	ifOutOctets 1.3.6.1.2.1.2.2.1.16
	ifOutUcastPkts 1.3.6.1.2.1.2.2.1.17
	ifOutNUcastPkts 1.3.6.1.2.1.2.2.1.18
	ifOutDiscards 1.3.6.1.2.1.2.2.1.19
	ifOutErrors 1.3.6.1.2.1.2.2.1.20
	ifOutQLen 1.3.6.1.2.1.2.2.1.21
	ifSpecific 1.3.6.1.2.1.2.2.1.22


（3）IP组

不区分简单变量和表格变量，直接给出了：
	
	ipForwarding 1.3.6.1.2.1.4.1
	ipDefaultTTL 1.3.6.1.2.1.4.2
	ipInReceives 1.3.6.1.2.1.4.3
	ipInHdrErrors 1.3.6.1.2.1.4.4
	ipInAddrErrors 1.3.6.1.2.1.4.5
	ipForwDatagrams 1.3.6.1.2.1.4.6
	ipInUnknownProtos 1.3.6.1.2.1.4.7
	ipInDiscards 1.3.6.1.2.1.4.8
	ipInDelivers 1.3.6.1.2.1.4.9
	ipOutRequests 1.3.6.1.2.1.4.10
	ipOutDiscards 1.3.6.1.2.1.4.11
	ipOutNoRoutes 1.3.6.1.2.1.4.12
	ipReasmTimeout 1.3.6.1.2.1.4.13
	ipReasmReqds 1.3.6.1.2.1.4.14
	ipReasmOKs 1.3.6.1.2.1.4.15
	ipReasmFails 1.3.6.1.2.1.4.16
	ipFragsOKs 1.3.6.1.2.1.4.17
	ipFragsFails 1.3.6.1.2.1.4.18
	ipFragCreates 1.3.6.1.2.1.4.19
	ipAddrTable 1.3.6.1.2.1.4.20
	ipAddrEntry 1.3.6.1.2.1.4.20.1
	ipAdEntAddr 1.3.6.1.2.1.4.20.1.1
	ipAdEntIfIndex 1.3.6.1.2.1.4.20.1.2
	ipAdEntNetMask 1.3.6.1.2.1.4.20.1.3
	ipAdEntBcastAddr 1.3.6.1.2.1.4.20.1.4
	ipAdEntReasmMaxSize 1.3.6.1.2.1.4.20.1.5


（4）ICMP组
	
	icmpInMsgs 1.3.6.1.2.1.5.1
	icmpInErrors 1.3.6.1.2.1.5.2
	icmpInDestUnreachs 1.3.6.1.2.1.5.3
	icmpInTimeExcds 1.3.6.1.2.1.5.4
	icmpInParmProbs 1.3.6.1.2.1.5.5
	icmpInSrcQuenchs 1.3.6.1.2.1.5.6
	icmpInRedirects 1.3.6.1.2.1.5.7
	icmpInEchos 1.3.6.1.2.1.5.8
	icmpInEchoReps 1.3.6.1.2.1.5.9
	icmpInTimestamps 1.3.6.1.2.1.5.10
	icmpInTimestampReps 1.3.6.1.2.1.5.11
	icmpInAddrMasks 1.3.6.1.2.1.5.12
	icmpInAddrMaskReps 1.3.6.1.2.1.5.13
	icmpOutMsgs 1.3.6.1.2.1.5.14
	icmpOutErrors 1.3.6.1.2.1.5.15
	icmpOutDestUnreachs 1.3.6.1.2.1.5.16
	icmpOutTimeExcds 1.3.6.1.2.1.5.17
	icmpOutParmProbs 1.3.6.1.2.1.5.18
	icmpOutSrcQuenchs 1.3.6.1.2.1.5.19
	icmpOutRedirects 1.3.6.1.2.1.5.20
	icmpOutEchos 1.3.6.1.2.1.5.21
	icmpOutEchoReps 1.3.6.1.2.1.5.22
	icmpOutTimestamps 1.3.6.1.2.1.5.23
	icmpOutTimestampReps 1.3.6.1.2.1.5.24
	icmpOutAddrMasks 1.3.6.1.2.1.5.25
	icmpOutAddrMaskReps 1.3.6.1.2.1.5.26


（5）TCP组
	
	tcpRtoAlgorithm 1.3.6.1.2.1.6.1
	tcpRtoMin 1.3.6.1.2.1.6.2
	tcpRtoMax 1.3.6.1.2.1.6.3
	tcpMaxConn 1.3.6.1.2.1.6.4
	tcpActiveOpens 1.3.6.1.2.1.6.5
	tcpPassiveOpens 1.3.6.1.2.1.6.6
	tcpAttemptFails 1.3.6.1.2.1.6.7
	tcpEstabResets 1.3.6.1.2.1.6.8
	tcpCurrEstab 1.3.6.1.2.1.6.9
	tcpInSegs 1.3.6.1.2.1.6.10
	tcpOutSegs 1.3.6.1.2.1.6.11
	tcpRetransSegs 1.3.6.1.2.1.6.12
	tcpConnTable 1.3.6.1.2.1.6.13
	tcpConnEntry 1.3.6.1.2.1.6.13.1
	tcpConnState 1.3.6.1.2.1.6.13.1.1
	tcpConnLocalAddress 1.3.6.1.2.1.6.13.1.2
	tcpConnLocalPort 1.3.6.1.2.1.6.13.1.3
	tcpConnRemAddress 1.3.6.1.2.1.6.13.1.4
	tcpConnRemPort 1.3.6.1.2.1.6.13.1.5
	tcpInErrs 1.3.6.1.2.1.6.14
	tcpOutRsts 1.3.6.1.2.1.6.15


（6）UDP组
	
	udpInDatagrams 1.3.6.1.2.1.7.1
	udpNoPorts 1.3.6.1.2.1.7.2
	udpInErrors 1.3.6.1.2.1.7.3
	udpOutDatagrams 1.3.6.1.2.1.7.4
	udpTable 1.3.6.1.2.1.7.5
	udpEntry 1.3.6.1.2.1.7.5.1
	udpLocalAddress 1.3.6.1.2.1.7.5.1.1
	udpLocalPort 1.3.6.1.2.1.7.5.1.2


（7）SNMP组

	
	snmpInPkts 1.3.6.1.2.1.11.1
	snmpOutPkts 1.3.6.1.2.1.11.2
	snmpInBadVersions 1.3.6.1.2.1.11.3
	snmpInBadCommunityNames 1.3.6.1.2.1.11.4
	snmpInBadCommunityUses 1.3.6.1.2.1.11.5
	snmpInASNParseErrs 1.3.6.1.2.1.11.6
	NOT USED 1.3.6.1.2.1.11.7
	snmpInTooBigs 1.3.6.1.2.1.11.8
	snmpInNoSuchNames 1.3.6.1.2.1.11.9
	snmpInBadValues 1.3.6.1.2.1.11.10
	snmpInReadOnlys 1.3.6.1.2.1.11.11
	snmpInGenErrs 1.3.6.1.2.1.11.12
	snmpInTotalReqVars 1.3.6.1.2.1.11.13
	snmpInTotalSetVars 1.3.6.1.2.1.11.14
	snmpInGetRequests 1.3.6.1.2.1.11.15
	snmpInGetNexts 1.3.6.1.2.1.11.16
	snmpInSetRequests 1.3.6.1.2.1.11.17
	snmpInGetResponses 1.3.6.1.2.1.11.18
	snmpInTraps 1.3.6.1.2.1.11.19
	snmpOutTooBigs 1.3.6.1.2.1.11.20
	snmpOutNoSuchNames 1.3.6.1.2.1.11.21
	snmpOutBadValues 1.3.6.1.2.1.11.22
	NOT USED 1.3.6.1.2.1.11.23
	snmpOutGenErrs 1.3.6.1.2.1.11.24
	snmpOutGetRequests 1.3.6.1.2.1.11.25
	snmpOutGetNexts 1.3.6.1.2.1.11.26
	snmpOutSetRequests 1.3.6.1.2.1.11.27
	snmpOutGetResponses 1.3.6.1.2.1.11.28
	snmpOutTraps 1.3.6.1.2.1.11.29
	snmpEnableAuthenTraps 1.3.6.1.2.1.11.30