FROM ubuntu:20.04

# turn off python output buffering
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive 

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
    iputils-ping \
    sudo \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
    daemonize \
    httpx \
    loguru \
    flask

COPY . /build
RUN cd /build && pip3 install . && rm -rf /build

ADD redirector.py redirector.py
ADD entrypoint.sh entrypoint.sh

EXPOSE 8089 5557

# RUN useradd --create-home locust
# RUN echo 'locust:locust' | chpasswd
# RUN adduser locust sudo

#CMD ["./entrypoint.sh"]

#USER locust
#WORKDIR /home/locust

ENTRYPOINT ["locust"]