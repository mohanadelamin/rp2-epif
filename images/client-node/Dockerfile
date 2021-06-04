FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    iptables \
    nano \
    vim \
    net-tools \
    tcpdump \
    python3 \
    python3-pip \
    python3-socksipychain \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
    daemonize \
    httpx \
    loguru \
    flask

ADD client.py client.py
ADD entrypoint.sh entrypoint.sh
ADD redirector.py redirector.py

ENTRYPOINT [ "./entrypoint.sh" ]
