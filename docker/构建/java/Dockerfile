FROM 10.4.7.48:5000/csst/ubuntu
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-29

#º”»ÎJDK
ADD jdk1.8.0_20 /usr/local/jdk1.8.0.20

ENV JAVA_HOME /usr/local/jdk1.8.0.20
ENV CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin