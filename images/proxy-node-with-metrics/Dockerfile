FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

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
    iputils-ping \
 && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1

RUN pip3 install flask

ADD monitor.sh monitor.sh
ADD proxy.py proxy.py
ADD entrypoint.sh entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh"]