#!/usr/bin/env python3
import logging
from daemonize import Daemonize
from socket import AF_INET, SOCK_STREAM, socket as Socket, SOL_IP
from sockschain import setdefaultproxy, PROXY_TYPE_SOCKS5, socksocket as SocksSocket
from struct import unpack
from os import environ
from threading import Thread
from typing import Tuple

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.propagate = False
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh = logging.FileHandler("/var/log/redirector.log", "w")
fh.setFormatter(formatter)
fh.setLevel(logging.DEBUG)
logger.addHandler(fh)
keep_fds = [fh.stream.fileno()]

def get_original_destination(socket: Socket) -> Tuple[str, int]:
    """
    Extracts the original destination from the socket.
    """
    SO_ORIGINAL_DST=80 # Not in socket module
    
    original_dst = socket.getsockopt(SOL_IP, SO_ORIGINAL_DST, 16)
    _, port, a1, a2, a3, a4 = unpack("!HHBBBBxxxxxxxx", original_dst)
    host = f"{a1}.{a2}.{a3}.{a4}"

    return (host, port)


def bidirectional_copy(source: Socket, destination: Socket):
    """
    Sets up a bidirectional copy between two sockets.
    """
    active = True

    def close():
        """
        Close both sockets, and stop the copying.
        """
        nonlocal active 

        source.close()
        destination.close()
        active = False

    def copy(a: Socket, b: Socket):
        """
        Copy any data from socket A to socket B.
        """
        nonlocal active 

        while active:
            try:
                data = a.recv(1024)
                if len(data) == 0:
                    close()
                    break

                b.sendall(data)
            except IOError:
                close()

    Thread(target=copy, args=(source, destination)).start()
    Thread(target=copy, args=(destination, source)).start()

    while active:
        pass


def redirector():
    """
    Redirects all incoming traffic through the proxy.
    """

    PROXY_HOST=environ.get("PROXY_HOST")
    PROXY_PORT=int(environ.get("PROXY_PORT", 1080))

    setdefaultproxy(PROXY_TYPE_SOCKS5, PROXY_HOST, PROXY_PORT)

    server = Socket(AF_INET, SOCK_STREAM)
    server.bind(("127.0.0.1", 42000))
    server.listen(1000)

    while True:
        client_socket, (src_host, src_port) = server.accept()
        (dst_host, dst_port) = get_original_destination(client_socket)

        logger.info(f"Intercepted connection from {src_host}:{src_port} to {dst_host}:{dst_port}")

        proxy_socket = SocksSocket()
        proxy_socket.connect((dst_host, dst_port))
        Thread(bidirectional_copy(client_socket, proxy_socket)).start()


if __name__ == "__main__":
    daemon = Daemonize(app="redirector", pid="/tmp/redirector.pid", action=redirector, keep_fds=keep_fds)
    daemon.start()