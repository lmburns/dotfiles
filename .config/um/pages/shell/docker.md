# docker --
{:data-section="shell"}
{:data-date="May 29, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Container

## EXAMPLES

### ==============================
### RUN

* Look for image called *nginx* in image cache
* If not found, look to default image repo on Dockerhub
* Pull down & store in image cache
* Started it in new container
* Specified it to take port 80- on host & forward to port 80 on container
* Can do `docker container run --publish 8000:80 --detach nginx` to use port 8000
* Can specify versions e.g., *nginx:1.09*

`$ docker container run -d -p 80:80 nginx`
: create and run container

`$ docker container run -d -p 80:80 --name nginx-server nginx`
: name container

`$ docker container ls`
: list running containers

`$ docker ps`
: shorthand list running containers

`$ docker ps -a`
: shorthand to list running containers

`$ docker container ls -a`
: list all containers even if not running

`$ docker container stop [ID]`
: stop container

`$ docker stop $(docker ps -aq)`
: stop all running containers

`$ docker container rm [ID]`
: remove container (stop first)

`$ docker container rm -f [ID]`
: remove running container

`$ docker container rm [ID] [ID] [ID]`
: remove multiple

`$ docker rm $(docker ps -aq)`
: remove all containers

`$ docker container logs [NAME]`
: get logs

`$ docker container top [NAME]`
: list process running in container

`$ docker run -ti ubuntu`
: download and run ubuntu

`$ docker run alpine ls -la`
: run command on container

`$ docker container run -it alpine /bin/sh`
: stay in the shell

`$ docker start -ai [contaiiner_id]`
: restart container

`$ docker container run -it alpine sh`
: run alpine

`$ docker container run -it -d alpine /bin/sh`
: detach container

`$ docker container attach my_nginx`
: attch

### GET A SHELL TO THE CONTAINER

`1. $ docker container run -it -d alpine /bin/sh`
: login again

`2. $ docker container ls`
: verify up, copy first 2-3 digits

`3. $ docker exec -it <CONTAINER ID or just 2-3 digits> sh`
: login with *exec*

`4. $ docker stop <CONTAINER ID>`
: stop once done

### ANOTHER WAY

`1. $ docker container run --name mymysql -d mysql`
: create container named *mymysql*

`2. $ docker container exec -it my_mysql ls /var`
: execute command inside container; *-i* = interactive; *-t* psuedo tty

`3. $ docker container exec -it my_mysql /bin/bash`
: new shell inside container

### ==============================
### IMAGE COMMANDS

* Images are app binaries and dependencies with metadata about image and how to run it
* No complete OS, no kernel, no drivers
* Host provides kernel

`$ docker image ls`
: list images pulled

`$ docker image`
: list images

`$ docker pull [IMAGE]`
: pull down image

`$ docker image rm [IMAGE]`
: remove an image

`$ docker rmi $(docker images -a -q)`
: remove all images

### ==============================
### SAMPLE CONTAINER CREATION

`$ docker container run -d -p 80:80 --name nginx nginx (-p 80:80 is optional as it runs on 80 by default)`
: nginx

`$ docker container run -d -p 8080:80 --name apache httpd`
: apache

`$ docker container run -d -p 3306:3306 --name mysql --env MYSQL_ROOT_PASSWORD=123456 mysql`
: mysql

### ==============================
### CONTAINER INFO

`$ docker container inspect [NAME]`
: info on container

`$ docker container inspect --format '{{ .NetworkSettings.IPAddress }}' [NAME]`
: specify property

`$ docker container stats [NAME]`
: performance stats (cpu, mem, network)

### ==============================
### ACCESSING CONTAINERS

`$ docker container run -it --name [NAME] nginx bash`
: *i* = interactive (keep STDIN); *t* = tty - open prompt

`$ winpty docker container run -it --name [NAME] nginx bash`
: git bash

`$ docker container run -it --name ubuntu ubuntu`
: run / create ubuntu container

`$ docker container run --rm -it --name [NAME] ubuntu`
: remove on exit

`$ docker container start -ai ubuntu`
: already created container *-ai*

`$ docker container exec -it mysql bash`
: exec to edit config, etc

`$ docker container run -it alpine sh`
: very small linux distro

`$ docker start $(docker ps -q -l)`
: restart container in background

`$ docker attach $(docker ps -q -l)`
: reattch to terminal

`$ docker start -ai $(docker ps -q -l)`
: the above in one

### ==============================
### NETWORKING

*bridge* or *docker0* is default network

`$ docker container port [NAME]`
: get port

`$ docker network ls`
: list networks

`$ docker network inspect [NETWORK_NAME]`
: inspect network

`$ docker network create [NETWORK_NAME]`
: create network

`$ docker container run -d --name [NAME] --network [NETWORK_NAME] nginx`
: create container on network

`$ docker network connect [NETWORK_NAME] [CONTAINER_NAME]`
: connect existing container to network

`$ docker network disconnect [NETWORK_NAME] [CONTAINER_NAME]`
: disconnect container from network

`$ docker network disconnect`
: detach network from container

### ==============================
### IMAGE TAGGING / PUSHING TO DOCKERHUB

`$ docker image ls`
: tags are labels point to image id

`$ docker image tag nginx btraversy/nginx`
: retab existing image

`$ docker image push bradtraversy/nginx`
: upload to dockerhub

`$ docker login`
: login

`$ docker image tag bradtraversy/nginx bradtraversy/nginx:testing`
: add tag to image

### ==============================
### DOCKERFILE PARTS

`FROM`
: The os used. Common is alpine, debian, ubuntu

`ENV`
: Environment variables

`RUN`
: Run commands/shell scripts, etc

`EXPOSE`
: Ports to expose

`CMD`
: Final command run when you launch a new container from image

`WORKDIR`
: Sets working directory (also could use 'RUN cd /some/path')

`COPY`
: Copies files from host to container

`$ docker image build -t [REPONAME] .`
: build image from dockerfile (any reponame)

### ==============================
### EXTENDING DOCKERFILE

`$ docker image build -t nginx-website`
: build image from dockerfile

`$ docker container run -p 80:80 --rm nginx-website`
: running it

`$ docker image tag nginx-website:latest btraversy/nginx-website:latest`
: tag

`$ docker image push bradtraversy/nginx-website`
: push

### ==============================
### VOLUMES

Special location outside of container. Used for databases

`$ docker volume ls`
: check volumes

`$ docker volume prune`
: cleanup unused volumes

`$ docker pull mysql`
: pull *mysql* to test

`$ docker image inspect mysql`
: inspect and see volume

`$ docker container run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=True mysql`
: run container

`$ docker container inspect mysql`
: inspect and see volume in container

`$ docker volume ls`
: check volumes

### DOCKERFILE

`ubuntu with git`
: FROM ubuntu:18.04
: RUN apt update
: RUN apt install -y git
