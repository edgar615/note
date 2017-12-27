FROM 10.4.7.48:5000/csst/ubuntu
MAINTAINER Edgar Zhang yuzhou.zhang@csst.com
ENV REFRESHED_AT 2015-10-08

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv C7917B12 && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server pwgen && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# Add scripts
ADD run.sh /run.sh

RUN chmod a+x /run.sh

ENV REDIS_PASS **Random**
ENV REDIS_DIR /data

VOLUME ["/data"]
EXPOSE 6379

CMD ["/run.sh"]