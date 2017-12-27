#!/bin/bash

if [ ! -f /.zk_initialize ]; then
/zk_initialize.sh "$@"
fi

ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE'
/zookeeper/bin/zkServer.sh start-foreground
