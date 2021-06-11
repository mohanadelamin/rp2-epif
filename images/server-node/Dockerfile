FROM kennethreitz/httpbin

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