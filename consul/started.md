# Consul

Consul提供了下列功能：


**服务发现**

Consul的Client可以提供一个服务（如API或MYSQL），然后其他Client可以通过Consul来发现一个给定服务的提供商。通过DNS或HTTP，应用程序可以很容易找到他们所依赖的服务。


**健康检查**

Consul的客户端可以提供一些健康检查，如一个关联的服务（Web Server返回200 OK），或者一个本地的节点（内存利用率低于90%）。这些信息可以被用来监控集群的健康，并且可以被服务发现组件用来远离不健康的节点

**键/值存储**

应用程序可以通过Consul提供的分层的KEY/VALUE存储数据，来实现各种不同的目的，包括动态配置、功能特征标记、协调、Leader选举等等。Consul提供了一个简单的HTTP API使它易于使用。


**多数据中心**

Consul支持开箱即用的多数据中心.这意味着Consul的用户不需要担心增加额外的抽象层来扩展更多的分区

## 基本架构
Consul是一个分布式、高可用的系统。

为Consul提供服务的每个节点都运行着一个代理(Agent)，运行Agent不需要发现其他服务或者获取key/value数据。Agent负责检查节点上的服务以及节点本身的健康状况

Agent与一个或者多个Consul服务器通信.Server是保持和复制数据的地方。多个Server本身会在它们之间选择出一个领导者。输入Consul用1个Server也可以正常工作，但是仍然建议使用3或5个Server来避免失败导致的数据丢失。每个数据中心都推荐使用一组Server构成的机器

你的基础设施里那些需要发现其他服务或节点的组件可以查询任意一个Server或者Agent.Agent会自动向Server转发查询

每个数据中心都运行着一组Server,当有跨数据中心的服务发现或者配置请求时，本地的Consul服务器会将请求转发到远程数据中心并返回结果

# 快速入门
## 安装
将下载的consul_XXX_linux_amd64.zip解压,并将consul的二进制文件放在任何可以被执行的地方.
linux: ~/bin 或者 /usr/local/bin
windows 任意目录，然后通过%PATH%指定

## 验证安装
在终端中输入consul命令来检查

	csst@csst-ubuntu-server:~$ consul
	usage: consul [--version] [--help] <command> [<args>]
	
	Available commands are:
	    agent          Runs a Consul agent
	    configtest     Validate config file
	    event          Fire a new event
	    exec           Executes a command on Consul nodes
	    force-leave    Forces a member of the cluster to enter the "left" state
	    info           Provides debugging information for operators
	    join           Tell Consul agent to join cluster
	    keygen         Generates a new encryption key
	    keyring        Manages gossip layer encryption keys
	    kv             Interact with the key-value store
	    leave          Gracefully leaves the Consul cluster and shuts down
	    lock           Execute a command holding a lock
	    maint          Controls node or service maintenance mode
	    members        Lists the members of a Consul cluster
	    monitor        Stream logs from a Consul agent
	    operator       Provides cluster-level tools for Consul operators
	    reload         Triggers the agent to reload configuration files
	    rtt            Estimates network round trip time between nodes
	    snapshot       Saves, restores and inspects snapshots of Consul server state
	    version        Prints the Consul version
	    watch          Watch for changes in Consul
	
	csst@csst-ubuntu-server:~$ consul version
	Consul v0.7.5
	Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

## 运行Consul Agent
在Consul安装之后，必须运行一个Agent。这个Agent可以用Server模式或者Client模式运行。每个数据中心必须至少有个一个Server，不过一个集群推荐3或5个Server，单个Server在发生失败的情况下会发生数据丢失，因此不推荐使用。

所有其他的Agent以Cient模式运行。一个Client是一个非常轻量级的进程，它可以注册服务，运行健康检查，以及转发查询到服务器。Agent必须运行在集群的每个节点上。

**启动Agent**

使用开发者模式启动一个Agent,这个模式可以非常容易快速地启动一个单节点的Consul环境。当然它并不是用于生产环境下并且它也不会持久任何状态。

	csst@csst-ubuntu-server:~$ consul agent -dev
	==> Starting Consul agent...
	==> Starting Consul agent RPC...
	==> Consul agent running!
	           Version: 'v0.7.5'
	           Node ID: 'e46e29fa-6a5b-4b41-ad9a-6559df987baf'
	         Node name: 'csst-ubuntu-server'
	        Datacenter: 'dc1'
	            Server: true (bootstrap: false)
	       Client Addr: 127.0.0.1 (HTTP: 8500, HTTPS: -1, DNS: 8600, RPC: 8400)
	      Cluster Addr: 127.0.0.1 (LAN: 8301, WAN: 8302)
	    Gossip encrypt: false, RPC-TLS: false, TLS-Incoming: false
	             Atlas: <disabled>
	
	==> Log data will now stream in as it occurs:
	
	    2017/03/17 17:17:49 [DEBUG] Using unique ID "e46e29fa-6a5b-4b41-ad9a-6559df987baf" from host as node ID
	    2017/03/17 17:17:49 [INFO] raft: Initial configuration (index=1): [{Suffrage:Voter ID:127.0.0.1:8300 Address:127.0.0.1:8300}]
	    2017/03/17 17:17:49 [INFO] raft: Node at 127.0.0.1:8300 [Follower] entering Follower state (Leader: "")
	    2017/03/17 17:17:49 [INFO] serf: EventMemberJoin: csst-ubuntu-server 127.0.0.1
	    2017/03/17 17:17:49 [INFO] serf: EventMemberJoin: csst-ubuntu-server.dc1 127.0.0.1
	    2017/03/17 17:17:49 [INFO] consul: Adding LAN server csst-ubuntu-server (Addr: tcp/127.0.0.1:8300) (DC: dc1)
	    2017/03/17 17:17:49 [INFO] consul: Adding WAN server csst-ubuntu-server.dc1 (Addr: tcp/127.0.0.1:8300) (DC: dc1)
	    2017/03/17 17:17:56 [ERR] agent: failed to sync remote state: No cluster leader
	    2017/03/17 17:17:58 [WARN] raft: Heartbeat timeout from "" reached, starting election
	    2017/03/17 17:17:58 [INFO] raft: Node at 127.0.0.1:8300 [Candidate] entering Candidate state in term 2
	    2017/03/17 17:17:58 [DEBUG] raft: Votes needed: 1
	    2017/03/17 17:17:58 [DEBUG] raft: Vote granted from 127.0.0.1:8300 in term 2. Tally: 1
	    2017/03/17 17:17:58 [INFO] raft: Election won. Tally: 1
	    2017/03/17 17:17:58 [INFO] raft: Node at 127.0.0.1:8300 [Leader] entering Leader state
	    2017/03/17 17:17:58 [INFO] consul: cluster leadership acquired
	    2017/03/17 17:17:58 [INFO] consul: New leader elected: csst-ubuntu-server
	    2017/03/17 17:17:58 [DEBUG] consul: reset tombstone GC to index 3
	    2017/03/17 17:17:58 [INFO] consul: member 'csst-ubuntu-server' joined, marking health alive
	    2017/03/17 17:18:00 [INFO] agent: Synced service 'consul'
	    2017/03/17 17:18:00 [DEBUG] agent: Node info in sync

从日志信息中，可以看到我们Agent运行Server模式 `Server: true (bootstrap: false)`，

并且声明集群的Leader 

    2017/03/17 17:17:56 [ERR] agent: failed to sync remote state: No cluster leader
    2017/03/17 17:17:58 [WARN] raft: Heartbeat timeout from "" reached, starting election
    2017/03/17 17:17:58 [INFO] raft: Node at 127.0.0.1:8300 [Candidate] entering Candidate state in term 2
    2017/03/17 17:17:58 [DEBUG] raft: Votes needed: 1
    2017/03/17 17:17:58 [DEBUG] raft: Vote granted from 127.0.0.1:8300 in term 2. Tally: 1
    2017/03/17 17:17:58 [INFO] raft: Election won. Tally: 1
    2017/03/17 17:17:58 [INFO] raft: Node at 127.0.0.1:8300 [Leader] entering Leader state
    2017/03/17 17:17:58 [INFO] consul: cluster leadership acquired
    2017/03/17 17:17:58 [INFO] consul: New leader elected: csst-ubuntu-server

另外，本地的成员已经被标记为一个健康的集群成员

	    2017/03/17 17:17:58 [INFO] consul: member 'csst-ubuntu-server' joined, marking health alive

## 集群成员

在终端上输入`consul members`，能看到Consul集群所有的节点

	csst@csst-ubuntu-server:~$ consul members
	Node                Address         Status  Type    Build  Protocol  DC
	csst-ubuntu-server  127.0.0.1:8301  alive   server  0.7.5  2         dc1

输出显示了节点的名称、运行地址、健康状态、在集群中的角色、版本信息等等。一下额外元数据可以通过 `-detailed`选项来查看

该命令输出显示你自己的节点，运行的地址，它的健康状态，它在集群中的角色，以及一些版本信息。另外元数据可以通过 -detailed 选项来查看。

	csst@csst-ubuntu-server:~$ consul members -detailed
	Node                Address         Status  Tags
	csst-ubuntu-server  127.0.0.1:8301  alive   build=0.7.5:'21f2d5a,dc=dc1,id=e46e29fa-6a5b-4b41-ad9a-6559df987baf,port=8300,role=consul,vsn=2,vsn_max=3,vsn_min=2

members 命令选项的输出是基于gossip协议，并且其内容保证最终一致性。也就是说，在任何时候你在本地代理看到的内容也许与当前服务器中的状态并不是绝对一致的。如果需要强一致性的状态信息，使用HTTP API向Consul服务器发送请求`http://127.0.0.1:8500/v1/catalog/nodes`
	
	csst@csst-ubuntu-server:~$ curl http://127.0.0.1:8500/v1/catalog/nodes
	[
	    {
	        "ID": "e46e29fa-6a5b-4b41-ad9a-6559df987baf",
	        "Node": "csst-ubuntu-server",
	        "Address": "127.0.0.1",
	        "TaggedAddresses": {
	            "lan": "127.0.0.1",
	            "wan": "127.0.0.1"
	        },
	        "Meta": {},
	        "CreateIndex": 4,
	        "ModifyIndex": 5
	    }
	]

另外除了HTTP API，DNS接口也常被用来查询节点信息。但你必须确保你的DNS能够找到Consul代理的DNS服务器，Consul代理的DNS服务器默认运行在8600端口。

	csst@csst-ubuntu-server:~$ dig @127.0.0.1 -p 8600 csst-ubuntu-server.node.consul
	
	; <<>> DiG 9.9.5-3ubuntu0.7-Ubuntu <<>> @127.0.0.1 -p 8600 csst-ubuntu-server.node.consul
	; (1 server found)
	;; global options: +cmd
	;; Got answer:
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17078
	;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
	;; WARNING: recursion requested but not available
	
	;; QUESTION SECTION:
	;csst-ubuntu-server.node.consul.	IN	A
	
	;; ANSWER SECTION:
	csst-ubuntu-server.node.consul.	0 IN	A	127.0.0.1
	
	;; Query time: 0 msec
	;; SERVER: 127.0.0.1#8600(127.0.0.1)
	;; WHEN: Fri Mar 17 17:44:30 CST 2017
	;; MSG SIZE  rcvd: 64

