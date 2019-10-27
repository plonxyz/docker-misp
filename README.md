# docker-misp 
rootless Docker MISP Container 
\
This is a modified version of [harvard-itsecurity/docker-misp](https://github.com/harvard-itsecurity/docker-misp). \
I've splitted it up into one container which runs MISP on www-data context and two dedicated containers for mysql and redis.
## Getting Started

```
git clone https://github.com/plonxyz/docker-misp.git
cd docker-misp

# modify build.sh
# Build the docker image 
./build.sh
```

## Access MISP
```
docker-compose up -d 
```
then access your misp instance at https://FQDN:4434 

## Good to know
Currently the MISP Modules aren't implemented yet, they will follow later on.
