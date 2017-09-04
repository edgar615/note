docker run --net host --name [name] -P edgar615/kafka -z 10.4.7.15:2181 -b

    z = ip address of a node of the existing cluster
	n = network card, default eth0
	b 如果有这个参数，会连接zookeeper去自动生成一个broker id

The --net host is needed for zookeepers on different hosts to be able to contact each other.

 -e KAFKA_HEAP_OPTS="-Xmx512M -Xms128M"