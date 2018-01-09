FROM alpine
MAINTAINER Edgar

ENV JDK_VERSION 8u151

# INSTALL JDK
RUN wget --no-check-certificate -c \
--header "Cookie: oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz \
-O jdk-8u151-linux-x64.tar.gz && \
tar -zxf jdk*.tar.gz -C /usr/local && \
rm jdk*.tar.gz && \
mv /usr/local/jdk* /usr/local/jdk

ENV JAVA_HOME /usr/local/jdk
ENV CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin