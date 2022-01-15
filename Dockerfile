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
       python3-dev && \
    pip3 install --upgrade pip && \
    pip3 install pycurl

RUN mkdir -p /opt/Log4Pot/payloads /opt/Log4Pot/log && \
    cd /opt/ && \
    git clone https://github.com/thomaspatzke/Log4Pot

RUN apt-get purge -y build-essential \
        git \
        python3-dev && \
    apt-get autoremove -y --purge && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

STOPSIGNAL SIGINT

WORKDIR /opt/Log4Pot/

CMD ["/usr/bin/python3","log4pot.py","--port","8080","--log","/opt/Log4Pot/log/log4pot.log","--download-dir","/opt/Log4Pot/payloads/","--payloader","--server-header","Apache-Coyote/1.1"]
