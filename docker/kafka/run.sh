#!/bin/bash

if [ ! -f /.kafka_initialize ]; then
/kafka_initialize.sh "$@"
fi

BROKER_ID=$(cat /.kafka_initialize)
echo "start kafka-server, broker id : $BROKER_ID"
./bin/kafka-server-start.sh config/server_$BROKER_ID.properties