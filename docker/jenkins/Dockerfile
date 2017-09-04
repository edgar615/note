FROM 10.4.7.48:5000/csst/java
MAINTAINER yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-25

RUN apt-get update -qq && apt-get install -qqy curl apt-transport-https
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list
RUN apt-get update -qq && apt-get install -qqy iptables ca-certificates git-core lxc-docker


#ADD MAVEN
ADD apache-maven-3.0.5 maven

ENV MAVEN_MAJOR_VERSION 3
ENV MAVEN_MINOR_VERSION 3.0.5 
ENV M2_HOME /maven
ENV PATH $PATH:$M2_HOME/bin

#ADD jenkins
ENV JENKINS_HOME /opt/jenkins/data

RUN mkdir -p $JENKINS_HOME/plugins

ADD jenkins.war /opt/jenkins/jenkins.war

ADD ./dockerjenkins.sh /usr/local/bin/dockerjenkins.sh
RUN chmod +x /usr/local/bin/dockerjenkins.sh

VOLUME /var/lib/docker
EXPOSE 8080
ENTRYPOINT [ "/usr/local/bin/dockerjenkins.sh" ]