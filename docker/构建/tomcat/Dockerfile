FROM 10.4.7.48:5000/csst/java
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-29

RUN apt-get update && \
    apt-get -yq install pwgen

#º”»ÎTOMCAT
ADD apache-tomcat-8.0.14 tomcat

ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.14
ENV CATALINA_HOME /tomcat

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh
RUN chmod +x /*.sh

EXPOSE 8080
#ENTRYPOINT [ "/tomcat/bin/catalina.sh", "run" ]
CMD ["/run.sh"]