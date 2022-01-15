# log4pot container image

![log4pot](https://github.com/goffinet/log4pot-container/actions/workflows/main.yml/badge.svg)

## Dockerfile

```
FROM ubuntu:20.04

LABEL org.opencontainers.image.source https://github.com/goffinet/log4pot-container

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
       build-essential \
       git \
       libcurl4-openssl-dev \
       libssl-dev \
       python3-pip \
       python3 \
       python3-dev

RUN pip3 install --upgrade pip && \
    pip3 install pycurl

RUN cd /opt/ && \
    git clone https://github.com/thomaspatzke/Log4Pot && \
    mkdir -p /opt/Log4Pot/payloads /opt/Log4Pot/log

RUN apt-get purge -y build-essential \
        git \
        python3-dev && \
    apt-get autoremove -y --purge && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

STOPSIGNAL SIGINT

WORKDIR /opt/Log4Pot/

CMD ["/usr/bin/python3","log4pot.py","--port","8080","--log","/opt/Log4Pot/log/log4pot.log","--download-dir","/opt/Log4Pot/payloads/","--payloader","--server-header","Apache-Coyote/1.1"]
```

## Docker-compose

```
version: '2.3'
networks:
  log4pot_local:
services:
  log4pot:
#    build: .
    container_name: log4pot
    restart: always
    tmpfs:
     - /tmp:uid=2000,gid=2000
    networks:
     - log4pot_local
    ports:
     - "80:8080"
     - "443:8080"
     - "8080:8080"
     - "9200:8080"
     - "25565:8080"
    image: "ghcr.io/goffinet/log4pot-container:master"
    read_only: true
    volumes:
     - "$PWD/log:/opt/Log4Pot/log"
     - "$PWD/payloads:/opt/Log4Pot/payloads"
```

## Usage

```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker
yum -y install python3-pip || apt update && apt -y install python3-pip
pip3 install pip --upgrade
pip3 install docker-compose
apt update
apt -y install git
addgroup --gid 2000 log4pot
adduser --system --shell /bin/bash -uid 2000 --disabled-password -gid 2000 log4pot
gpasswd -a log4pot docker
su - log4pot
git clone https://github.com/goffinet/log4pot-container.git
cd log4pot-container
mkdir log/ payloads/
chown -R 2000:2000 log/ payloads/
```

```
docker-compose up -d
```

```
jq '.' log/log4pot.log
docker exec log4pot tail -f /opt/Log4Pot/log/log4pot.log
```
