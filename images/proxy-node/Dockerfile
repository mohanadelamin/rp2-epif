FROM ubuntu:20.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

ADD proxy.py proxy.py

ENTRYPOINT [ "./proxy.py", "start", "-f" ]
