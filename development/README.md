This directory contains docker configuration for application dependencies only (like db, cache service, etc).

It does not runs app itself, we expect app will be run on host system.

# Installation instructions for Ubuntu

Modern Ubuntu versions provides fresh docker via snap package, just use
```
sudo snap install docker
```
This will install actual version of docker and docker-compose utility.

As a post-install steps you need to create docker group and add your user to it:
```
sudo groupadd docker
sudo usermod -a -G docker <USERNAME>
reboot
```

Launch docker service:
```
sudo snap start docker
```

# Running app

```
cd ./development-dependencies
docker-compose up
```

To run docker containers in daemon mode add `-d` key:
```
docker-compose up -d
```