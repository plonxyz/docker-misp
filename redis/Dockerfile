FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install build-essential tar sudo vim wget -y ; \
wget http://download.redis.io/releases/redis-5.0.5.tar.gz ; \
tar xvzf redis-5.0.5.tar.gz ; \
useradd redis && chown redis:redis /redis-5.0.5 
WORKDIR /redis-5.0.5 
RUN make && make install
EXPOSE 6379
USER redis
ENTRYPOINT [ "/bin/bash","-c","/usr/local/bin/redis-server","/tmp/redis.conf" ]
