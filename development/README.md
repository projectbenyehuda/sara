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

# Running services with docker

To create and run containers for the first time you need to use `up` command

```
cd ./development
docker-compose up
```

You can run this command in daemon mode by adding `-d` key:
```
docker-compose up -d
```

If you want to start or stop already created containers you should use `docker-compose start` and 
`docker-compose stop` commands. 

`docker-compose down` will delete container. So all data (e.g. database state) will be dropped. 

