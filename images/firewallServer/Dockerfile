FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-pip \
    iptables \
    tcpdump \
    sudo \
 && rm -rf /var/lib/apt/lists/*

ADD rules.sh rules.sh
ADD entrypoint.sh entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh"]


