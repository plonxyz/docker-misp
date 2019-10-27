#!/bin/bash
 docker rmi plonxyz/misp_apache:latest
 docker rmi plonxyz/misp_redis:latest
 docker rmi plonxyz/misp_mariadb:latest
docker build \
    --rm=true --force-rm=true \
    --build-arg MYSQL_MISP_PASSWORD=ChangeThisDefaultPassworda9564ebc3289b7a14551baf8ad5ec60a \
    --build-arg MYSQL_MISP_SERVER=db \
    --build-arg MISP_FQDN=localhost \
    --build-arg REDIS_MISP_SERVER=redis \
    --build-arg MISP_EMAIL=admin@localhost \
    --build-arg MISP_GPG_PASSWORD=ChangeThisDefaultPasswordXuJBao5Q2bps89LWFqWkKgDZwAFpNHvc \
    -t plonxyz/misp_apache:latest \
    $PWD/apache/

 docker build --rm=true --force-rm=true -t plonxyz/misp_redis:latest $PWD/redis/

docker build  --rm=true --force-rm=true  \
--build-arg MYSQL_MISP_PASSWORD=ChangeThisDefaultPassworda9564ebc3289b7a14551baf8ad5ec60a \
    -t plonxyz/misp_mariadb:latest \
    $PWD/mariadb/


