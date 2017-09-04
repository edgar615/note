三台机器：10.4.7.220 10.4.7.221 10.4.7.222
## consul的安装
**使用本地网络模式安装consul，映射模式在服务注册时还存在问题**

**-client=0.0.0.0 会让所有的IP都能访问consul，会存在安全问题，正式部署时需要使用内网IP**

### node1


	1.使用本地网络
	docker run -d --net=host --name=node1 \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
		consul agent -server \
		-bind=10.4.7.220 \
		-client=0.0.0.0 \
		-retry-join=10.4.7.221 \
		-bootstrap-expect=3 

	2.使用映射
	docker run -d -h node1 --name node1  \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
		-p 10.4.7.220:8300:8300 \
		-p 10.4.7.220:8301:8301 \
		-p 10.4.7.220:8301:8301/udp \
		-p 10.4.7.220:8302:8302 \
		-p 10.4.7.220:8302:8302/udp \
		-p 10.4.7.220:8400:8400 \
		-p 10.4.7.220:8500:8500 \
		-p 10.4.7.220:8600:8600 \
		-p 10.4.7.220:8600:8600/udp \
		consul agent -server -advertise=10.4.7.220 \
		-retry-join=10.4.7.221 \
		-client=0.0.0.0 \
		-bootstrap-expect=3 -recursor=8.8.8.8

### node2

	1.使用本地网络
	docker run -d --net=host --name=node2 \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
		consul agent -server \
		-bind=10.4.7.221 \
		-client=0.0.0.0 \
		-retry-join=10.4.7.220


	2.使用映射
	docker run -d -h node2 --name node2  \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
		-p 10.4.7.221:8300:8300 \
		-p 10.4.7.221:8301:8301 \
		-p 10.4.7.221:8301:8301/udp \
		-p 10.4.7.221:8302:8302 \
		-p 10.4.7.221:8302:8302/udp \
		-p 10.4.7.221:8400:8400 \
		-p 10.4.7.221:8500:8500 \
		-p 10.4.7.221:8600:8600 \
		-p 10.4.7.221:8600:8600/udp \
		consul agent -server -advertise=10.4.7.221 \
		-client=0.0.0.0 \
		-retry-join=10.4.7.220 -recursor=8.8.8.8

### node3

	1.使用本地网络
	docker run -d --net=host --name=node3 \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
		consul agent -server \
		-bind=10.4.7.222 \
		-client=0.0.0.0 \
		-retry-join=10.4.7.220

	2.使用映射
	docker run -d -h node3 --name node3  \
		-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
		-p 10.4.7.222:8300:8300 \
		-p 10.4.7.222:8301:8301 \
		-p 10.4.7.222:8301:8301/udp \
		-p 10.4.7.222:8302:8302 \
		-p 10.4.7.222:8302:8302/udp \
		-p 10.4.7.222:8400:8400 \
		-p 10.4.7.222:8500:8500 \
		-p 10.4.7.222:8600:8600 \
		-p 10.4.7.222:8600:8600/udp \
		consul agent -server -advertise=10.4.7.222 \
		-client=0.0.0.0 \
		-retry-join=10.4.7.220 -recursor=8.8.8.8

在node1 node2 node3分别执行

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest \
		-cleanup=true \
		consul://localhost:8500 

**一定要加上-cleanup=true，否则机器重启之后注册信息不会删除**
docker重启之后，如果只启动consul，注册信息并没有被清除，只有当registrator重启之后才会清除

### 测试服务注册
**注意：使用--net=host模式启动的镜像，依然要使用-p指定端口映射，否则不能实现服务自动注册**
在任意服务器上启动一个mysql

`docker run -d -P --name=mysql -e SERVICE_NAME=db -e SERVICE_TAGS="db, datasource" 10.4.7.48:5000/csst/mysql`

在任意服务上运行
`curl http://127.0.0.1:8500/v1/catalog/service/db`

可以看到正在运行的DB实例

	[
	  {
		"ModifyIndex": 15,
		"CreateIndex": 15,
		"Node": "ubuntu220",
		"Address": "10.4.7.220",
		"ServiceID": "ubuntu220:mysql:3306",
		"ServiceName": "db",
		"ServiceTags": [
		  "master",
		  "backups"
		],
		"ServiceAddress": "",
		"ServicePort": 32768,
		"ServiceEnableTagOverride": false
	  },
	  {
		"ModifyIndex": 12,
		"CreateIndex": 12,
		"Node": "ubuntu221",
		"Address": "10.4.7.221",
		"ServiceID": "ubuntu221:mysql:3306",
		"ServiceName": "db",
		"ServiceTags": [
		  "master",
		  "datasource"
		],
		"ServiceAddress": "",
		"ServicePort": 32768,
		"ServiceEnableTagOverride": false
	  },
	  {
		"ModifyIndex": 798,
		"CreateIndex": 798,
		"Node": "ubuntu222",
		"Address": "10.4.7.222",
		"ServiceID": "ubuntu222:mysql:3306",
		"ServiceName": "db",
		"ServiceTags": [
		  "db",
		  " datasource"
		],
		"ServiceAddress": "",
		"ServicePort": 32769,
		"ServiceEnableTagOverride": false
	  }
	]
