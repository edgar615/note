docker run --net host --name [name] -P edgar615/zookeeper -h 10.4.7.15 -n ethwe

    h = ip address of a node of the existing cluster
	n = network card, default eth0

The --net host is needed for zookeepers on different hosts to be able to contact each other.