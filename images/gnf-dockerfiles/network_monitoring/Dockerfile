# Proof of concept for Network Monitoring Container

# FROM glanf/base
FROM ubuntu:20.04
MAINTAINER Kyle White

RUN apt-get update 

RUN apt install -y software-properties-common

RUN add-apt-repository universe 

RUN apt-get update 

RUN apt-get install -y \
    python \ 
    build-essential \
    python-dev \
    iptables \
    tcpdump \
    curl \
    net-tools

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py

RUN pip install requests

RUN mkdir data
ADD main.py ./data/
RUN chmod +x ./data/main.py

ADD entrypoint.sh entrypoint.sh


# Set delta for notification of stats here (float, seconds)
ENV DELTA 60.0

ENTRYPOINT ./entrypoint.sh
