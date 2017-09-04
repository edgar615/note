FROM 10.4.7.48:5000/csst/java
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-29

#ADD MAVEN
ADD apache-maven-3.0.5 maven

ENV MAVEN_MAJOR_VERSION 3
ENV MAVEN_MINOR_VERSION 3.0.5 
ENV M2_HOME /maven
ENV PATH $PATH:$M2_HOME/bin

#ADD nexus
ADD nexus-2.11.4-01 nexus
ADD sonatype-work sonatype-work

ENV NEXUS_MAJOR_VERSION 2
ENV NEXUS_MINOR_VERSION 2.11.4-01
ENV RUN_AS_USER root

VOLUME /var/lib/sonatype-work /sonatype-work

EXPOSE 8081
ENTRYPOINT [ "/nexus/bin/nexus", "start" ]