MYID=1
while getopts "h:n:" arg 
do
	case $arg in
		 h)
			echo "zk host:$OPTARG"
			ZK=$OPTARG
			;;
		 n)
			echo "network card:$OPTARG"
			NET=$OPTARG
			;;
		 ?)  #当有不认识的选项的时候arg为?
			echo "usage: -h <zk_host> || -n <network card>"
			exit 1
			;;
	esac
done

if [ -z "$NET" ]
then
	NET=eth0
fi

#get ip addr
IPADDRESS=$(ip -4 addr show scope global dev $NET | grep inet | awk '{print $2}' | cut -d / -f 1)
echo "$NET ip addr:" $IPADDRESS

cd /zookeeper
if [ -n "$ZK" ]
then
	output=(`./bin/zkCli.sh -server $ZK:2181 get /zookeeper/config | grep ^server`)
	
	# extract all the zk-ids from the output
	declare id_list=()
	for i in "${output[@]}"
	do
		id_list+=(`echo $i | cut -d "=" -f 1 | cut -d "." -f 2`)
	done 	
	
	sorted_id_list=( $(
		for el in "${id_list[@]}"
		do
		echo "$el"
		done | sort -n) )
	# get the next increasing number from the sequence
	MYID=$((${sorted_id_list[${#sorted_id_list[@]}-1]}+1))
	echo "MYID:" $MYID
	echo $output >> /zookeeper/conf/zoo.cfg.dynamic
	echo "zk-ids output:" $output
	echo "server.$MYID=$IPADDRESS:2888:3888:observer;2181" >> /zookeeper/conf/zoo.cfg.dynamic
	cp /zookeeper/conf/zoo.cfg.dynamic /zookeeper/conf/zoo.cfg.dynamic.org
	/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
	ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' 
	/zookeeper/bin/zkServer.sh start
	/zookeeper/bin/zkCli.sh -server $ZK:2181 reconfig -add "server.$MYID=$IPADDRESS:2888:3888:participant;2181"
	/zookeeper/bin/zkServer.sh stop
	
	echo "sleeping for 10 seconds"
	sleep 10
	echo "woke up"
	
else
	echo "server.$MYID=$IPADDRESS:2888:3888;2181" >> /zookeeper/conf/zoo.cfg.dynamic
	/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
fi

echo "=> Done!"
touch /.zk_initialize