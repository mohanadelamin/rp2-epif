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

RUN pip3 install flask


ENV PYTHONUNBUFFERED=1

ADD proxy.py proxy.py
ADD entrypoint.sh entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh"]