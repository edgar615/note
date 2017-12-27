FROM 10.4.7.48:5000/csst/java
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-09-29


ADD service /service
ADD run.sh /run.sh

RUN sed -i 's/\r$//' /run.sh

RUN chmod +x /*.sh

#ENV MYSQL_DATABASE alarmuser
#ENV MYSQL_USERNAME root
#ENV MYSQL_PASSWORD csst

EXPOSE 8080
CMD ["/run.sh"]