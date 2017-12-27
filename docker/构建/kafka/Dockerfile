FROM 10.4.7.48:5000/csst/java
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-10-08

RUN apt-get update

#kafka
ADD kafka kafka
ADD zookeeper zookeeper

ENV KAFKA_MAJOR_VERSION 2.11
ENV KAFKA_MINOR_VERSION 2.11-0.9.0.0
ENV KAFKA_HOME /kafka

WORKDIR /kafka

ADD run.sh /run.sh
ADD kafka_initialize.sh /kafka_initialize.sh
RUN chmod +x /*.sh

#RUN sed -i 's/\r$//' /run.sh

VOLUME  ["/tmp/kafka-logs"]

EXPOSE 9092
ENTRYPOINT ["/run.sh"]