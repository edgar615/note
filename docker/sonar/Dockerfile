FROM 10.4.7.48:5000/csst/java
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-29

#º”»ÎSONAR
ADD sonarqube-4.5.6 sonar

ENV SONAR_MAJOR_VERSION 4
ENV SONAR_MINOR_VERSION 4.5.6
ENV SONAR_HOME /sonar
ADD run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh
RUN chmod +x /*.sh

EXPOSE 9000
CMD ["/run.sh"]