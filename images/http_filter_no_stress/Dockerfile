# Proof of concept for Network Monitoring Container

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive 
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install --no-install-recommends -y \
    python \
    python3.6 \
    python3-pip \
    python3.6-dev \
    python3-dev \
    libnetfilter-queue-dev \
    build-essential libssl-dev libffi-dev \
    libxml2-dev libxslt1-dev zlib1g-dev \
    iptables \
    iproute2 \
    vim \
    net-tools \
    tcpdump \
    git \
    dnsutils \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install -U git+https://github.com/kti/python-netfilterqueue
RUN pip3 install scapy
#RUN pip3 install netfilterqueue

ADD monitor.sh monitor.sh
ADD main.py main.py

ADD entrypoint.sh entrypoint.sh

ENTRYPOINT ./entrypoint.sh