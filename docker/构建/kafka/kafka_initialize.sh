#!/bin/bash

MY_BROKER_ID=0
while getopts "z:n:b" arg 
do
	case $arg in
		z)
			echo "zk connect:$OPTARG"
			ZK=$OPTARG
			;;
		n)
			echo "network card:$OPTARG"
			NET=$OPTARG
			;;
		b)
			echo "GEN_BROKER:true"
			GEN_BROKER="true"
			;;
		 ?)  #当有不认识的选项的时候arg为?
			echo "usage: -z <zk connect> || -n <network card> || -b "
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

cd /kafka

if [ -n "$GEN_BROKER" ] && [ -n "$ZK" ]
then	
	echo "sleeping for 10 seconds"
	sleep 10
	echo "woke up"
	
	echo "find broker id"
	BROKER_IDS_STR=$(/zookeeper/bin/zkCli.sh -server $ZK ls /brokers/ids | tail -1)
	BROKER_IDS_STR1=${BROKER_IDS_STR/#[/}
	BROKER_IDS_STR2=${BROKER_IDS_STR1/%]/}
	BROKER_IDS=(${BROKER_IDS_STR2//,/})
	echo "BROKER_IDS:" ${BROKER_IDS[@]}

	sorted_id_list=($(
		for el in ${BROKER_IDS[@]}
		do
			echo $el
		done | sort -n
	)) || echo "sorted id list"
	for i in ${sorted_id_list[@]}
	do
		echo $i
	done

	MY_BROKER_ID=$((${sorted_id_list[${#sorted_id_list[@]}-1]}+1))
	
	echo "MY_BROKER_ID:" $MY_BROKER_ID
elif [ -z "$ZK" ]
then
	echo "not found zookeeper connect string"
	ZK=localhost:2181	
	echo "start local zookeeper"
	./bin/zookeeper-server-start.sh config/zookeeper.properties
fi

echo "create new server.properties: server_$MY_BROKER_ID.properties" 
sed "s/broker.id=0/broker.id=$MY_BROKER_ID/g; s/zookeeper.connect=localhost:2181/zookeeper.connect=$ZK/g; s/#advertised.host.name=<hostname routable by clients>/advertised.host.name=$IPADDRESS/g" config/server.properties > config/server_$MY_BROKER_ID.properties

echo "=> Done!"
echo $MY_BROKER_ID > /.kafka_initialize