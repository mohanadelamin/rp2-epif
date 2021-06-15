# Proof of concept for Network Monitoring Container

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive 
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-pip \
    iptables \
    iproute2 \
    vim \
    net-tools \
    tcpdump \
    sudo \
    dnsutils \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir data
ADD monitor.sh monitor.sh
ADD main.py main.py

ADD entrypoint.sh entrypoint.sh


ENTRYPOINT ./entrypoint.sh
