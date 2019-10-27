FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
ARG MYSQL_MISP_PASSWORD=ChangeThisDefaultPassworda9564ebc3289b7a14551baf8ad5ec60a
COPY MYSQL.sql /MYSQL.sql
RUN apt-get update && apt-get install -y mariadb-client mariadb-server sudo && \
    sed -i -e "s/bind-address/#bind-address/g" /etc/mysql/mariadb.conf.d/50-server.cnf ; \
    echo "#!/bin/bash" > /init-db ; \
     echo "if [ ! -f /var/lib/mysql/.db_initialized ]; then" >> /init-db ; \
    echo "sudo chown -R mysql:mysql /var/lib/mysql" >> /init-db ; \
    echo "sudo -u mysql -H /usr/bin/mysql_install_db --user=mysql" >> /init-db ; \
    echo "chown -R mysql:mysql /var/lib/mysql" >> /init-db ; \
    echo "cd '/usr' ; /usr/bin/mysqld_safe --datadir='/var/lib/mysql' &" >> /init-db ; \
    echo "sleep 5" >> /init-db ; \
    echo "mysql -uroot -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')\"" >> /init-db ; \
    echo "mysql -uroot -e \"DELETE FROM mysql.user WHERE User=''\"" >> /init-db ; \
    echo "mysql -uroot -e \"DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'\"" >> /init-db ; \
    echo "mysql -uroot -e \"FLUSH PRIVILEGES;\"" >> /init-db ; \
    echo "mysql -uroot -e \"create database misp\"" >> /init-db ; \
    echo "mysql -uroot -e \"grant usage on *.* to misp@'%' identified by '${MYSQL_MISP_PASSWORD}'\"" >> /init-db ; \
    echo "mysql -uroot -e \"grant all privileges on misp.* to misp@'%'\"" >> /init-db ; \
    echo "mysql -uroot -e \"flush privileges;\"" >> /init-db ; \
    echo "sudo -u www-data -H sh -c \"mysql -u misp -p${MYSQL_MISP_PASSWORD} misp < /MYSQL.sql\"" >> /init-db ; \
    echo "touch /var/lib/mysql/.db_initialized" >> /init-db ; \
    echo "chown -R mysql:mysql /var/lib/mysql" >> /init-db ; \
     echo "fi" >> /init-db ; \
     echo "rm -f /init-db" >> /init-db ; \
    chmod 755 /init-db ; \
    ./init-db
    
    CMD ["/usr/bin/mysqld_safe"]
    EXPOSE 3306