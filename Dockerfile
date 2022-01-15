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
#    pip3 install poetry && \
    pip3 install pycurl && \
    mkdir -p /opt /var/log/log4pot && \
    cd /opt/ && \
    git clone https://github.com/thomaspatzke/Log4Pot && \
    cd Log4Pot && \
#    git checkout 4269bf4a91457328fb64c3e7941cb2f520e5e911 && \
#    git checkout 4e9bac32605e4d2dd4bbc6df56365988b4815c4a && \
#    sed -i 's#"type": logtype,#"reason": logtype,#g' log4pot.py && \
#    mv log4pot.py log4pot.py.backup && \
#    poetry install && \
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

CMD ["/usr/bin/python3","log4pot.py","--port","8080","--log","/opt/Log4Pot/log/log4pot.log","--download-dir","/opt/Log4Pot/payloads/","--payloader","--server-header","Apache-Coyote/1.1"]
