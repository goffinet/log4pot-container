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
       cargo \
       cleo \
             git \
       libcap2 \
       libcap2-bin \
       libcurl4 \
       libcurl4-nss-dev \
       libffi7 \
       libffi-dev \
       libssl-dev \
       python3-pip \
             python3 \
             python3-dev \
             rust-all && \
    pip3 install --upgrade pip && \
    pip3 install poetry pycurl && \
    mkdir -p /opt /var/log/log4pot && \
    cd /opt/ && \
    git clone https://github.com/thomaspatzke/Log4Pot && \
    cd Log4Pot && \
#    git checkout 4269bf4a91457328fb64c3e7941cb2f520e5e911 && \
    git checkout 4e9bac32605e4d2dd4bbc6df56365988b4815c4a && \
    sed -i 's#"type": logtype,#"reason": logtype,#g' log4pot.py && \
    poetry install && \
    setcap cap_net_bind_service=+ep /usr/bin/python3.8 && \
    addgroup --gid 2000 log4pot && \
    adduser --system --no-create-home --shell /bin/bash -uid 2000 --disabled-password --disabled-login -gid 2000 log4pot && \
    mkdir -p /opt/Log4Pot/payloads /opt/Log4Pot/log && \
    chown -R 775 /opt/Log4Pot/payloads /opt/Log4Pot/log && \
    chown log4pot:log4pot -R /opt/Log4Pot && \
    chown log4pot:log4pot -R /var/log/log4pot && \
    apt-get purge -y build-essential \
        cargo \
        git \
        libffi-dev \
        libssl-dev \
        python3-dev \
        rust-all && \
    apt-get autoremove -y --purge && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


STOPSIGNAL SIGINT

USER log4pot:log4pot

WORKDIR /opt/Log4Pot/

CMD ["/usr/bin/python3","log4pot.py","--port","8080","--log","/opt/Log4Pot/log/log4pot.log","--download-dir","/opt/Log4Pot/payloads/","--download-class","--download-payloads"]
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
#    read_only: true
#    volumes:
#     - /data/log4pot/log:/opt/Log4Pot/log
#     - /data/log4pot/payloads:/opt/Log4Pot/payloads
```

## Usage

```
git clone https://github.com/goffinet/log4pot-container.git
cd log4pot-container
```

```
docker-compose up -d
```

```
docker exec log4pot tail -f /opt/Log4Pot/log/log4pot.log
```
