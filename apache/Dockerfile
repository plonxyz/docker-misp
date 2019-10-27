FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
ARG MYSQL_MISP_PASSWORD=ChangeThisDefaultPassworda9564ebc3289b7a14551baf8ad5ec60a
ARG MISP_FQDN=localhost
ARG MYSQL_MISP_SERVER=db
ARG REDIS_MISP_SERVER=redis
ARG MISP_EMAIL=admin@localhost
ARG MISP_GPG_PASSWORD=ChangeThisDefaultPasswordXuJBao5Q2bps89LWFqWkKgDZwAFpNHvc
COPY setup.sh /setup.sh
RUN chmod a+x setup.sh && ./setup.sh 


VOLUME /var/www/MISP    
COPY envvars /etc/apache2/envvars 
EXPOSE 8080 4434 50000
USER www-data
ENTRYPOINT ["/bin/bash", "-c", "apachectl -DFOREGROUND" ]