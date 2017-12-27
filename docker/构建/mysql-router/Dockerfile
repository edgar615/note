FROM 10.4.7.48:5000/csst/ubuntu
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-29

RUN apt-get update && \
   apt-get -yyq install wget curl apparmor && \

   
# Add MySQL configuration
ADD mysql-router_2.0.2-1ubuntu14.04_amd64.deb mysql-router.deb

RUN dpkg -i mysql-router.deb

ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN sed -i 's/\r$//' /run.sh

EXPOSE 7001 7002
CMD ["/run.sh"]