FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-pip \
    iptables \
    tcpdump \
    iputils-ping \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install flask


ENV PYTHONUNBUFFERED=1

ADD proxy.py proxy.py

ENTRYPOINT [ "./proxy.py", "start", "-f" ]
