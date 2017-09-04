FROM 10.4.7.48:5000/csst/java
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-10-08

RUN apt-get update

#¼ÓÈëZK
ADD zookeeper zookeeper

ENV ZOOKEEPER_MAJOR_VERSION 3
ENV ZOOKEEPER_MINOR_VERSION 3.5.1-alpha
ENV ZK_HOME /zookeeper

WORKDIR /zookeeper

RUN if [ ! -f /zookeeper/conf/zoo.cfg ] ; then cp /zookeeper/conf/zoo_sample.cfg /zookeeper/conf/zoo.cfg; fi

RUN echo "standaloneEnabled=false" >> /zookeeper/conf/zoo.cfg
RUN echo "dynamicConfigFile=/zookeeper/conf/zoo.cfg.dynamic" >> /zookeeper/conf/zoo.cfg

ADD run.sh /run.sh
ADD zk_initialize.sh /zk_initialize.sh
RUN chmod +x /*.sh

#RUN sed -i 's/\r$//' /run.sh

VOLUME  ["/tmp/zookeeper"]

EXPOSE 2181 2888 3888
ENTRYPOINT ["/run.sh"]