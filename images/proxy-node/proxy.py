#!/usr/bin/env python3
import argparse
import logging
import os
import platform
import signal
import struct
import sys
import threading
from socket import AF_INET, SOCK_STREAM, socket, gethostbyname, gethostname
from socketserver import BaseServer, StreamRequestHandler, ThreadingTCPServer
from flask import Flask, request
import time 
# https://github.com/fengyouchao/pysocks



class MetricGatherer:
    def __init__(self):
        self.metrics = {"number_of_requests": 0}

    def server_http_requests(self):
        print("Get metrics")
        return f"# HELP http_requests_total The amount of requests served by the server in total\n# TYPE http_requests_total counter\nhttp_requests_total {self.metrics['number_of_requests']}\n"

app = Flask(__name__)
metricGatherer = MetricGatherer()

@app.route("/metrics", methods=["GET"])
def metrics():
    return metricGatherer.server_http_requests()

__author__ = 'Youchao Feng'
support_os = ('Darwin', 'Linux')
current_os = platform.system()




def byte_to_int(b):
    """
    Convert Unsigned byte to int
    :param b: byte value
    :return:  int value
    """
    return b & 0xFF


def port_from_byte(b1, b2):
    """
    :param b1: First byte of port
    :param b2: Second byte of port
    :return: Port in Int
    """
    return byte_to_int(b1) << 8 | byte_to_int(b2)


def host_from_ip(a, b, c, d):
    a = byte_to_int(a)
    b = byte_to_int(b)
    c = byte_to_int(c)
    d = byte_to_int(d)
    return "%d.%d.%d.%d" % (a, b, c, d)


def get_command_name(value):
    """
    Gets command name by value
    :param value:  value of Command
    :return: Command Name
    """
    if value == 1:
        return 'CONNECT'
    elif value == 2:
        return 'BIND'
    elif value == 3:
        return 'UDP_ASSOCIATE'
    else:
        return None


def build_command_response(reply):
    start = b'\x05%s\x00\x01\x00\x00\x00\x00\x00\x00'
    return start % reply.get_byte_string()


def close_session(session):
    session.get_client_socket().close()
    print("Session[%s] closed", session.get_id())


def run_daemon_process(stdout='/dev/stdout',
                       stderr=None,
                       stdin='/dev/stdin',
                       pid_file=None,
                       start_msg='started with pid %s'):
    """
         This forks the current process into a daemon.
         The stdin, stdout, and stderr arguments are file names that
         will be opened and be used to replace the standard file descriptors
         in sys.stdin, sys.stdout, and sys.stderr.
         These arguments are optional and default to /dev/null.
        Note that stderr is opened unbuffered, so
        if it shares a file with stdout then interleaved output
         may not appear in the order that you expect.
    """
    # flush io
    sys.stdout.flush()
    sys.stderr.flush()
    # Do first fork.
    try:
        if os.fork() > 0:
            sys.exit(0)  # Exit first parent.
    except OSError as e:
        sys.stderr.write("fork #1 failed: (%d) %s\n" % (e.errno, e.strerror))
        sys.exit(1)
    # Decouple from parent environment.
    os.chdir("/")
    os.umask(0)
    os.setsid()
    # Do second fork.
    try:
        if os.fork() > 0:
            sys.exit(0)  # Exit second parent.
    except OSError as e:
        sys.stderr.write("fork #2 failed: (%d) %s\n" % (e.errno, e.strerror))
        sys.exit(1)
    # Open file descriptors and print start message
    if not stderr:
        stderr = stdout
        si = open(stdin, 'r')
        so = open(stdout, 'a+')
        se = open(stderr, 'ba+', 0)  # unbuffered
        pid = str(os.getpid())
        sys.stderr.write(start_msg % pid)
        sys.stderr.flush()
    if pid_file:
        open(pid_file, 'w+').write("%s\n" % pid)
    # Redirect standard file descriptors.
    os.dup2(si.fileno(), sys.stdin.fileno())
    os.dup2(so.fileno(), sys.stdout.fileno())
    os.dup2(se.fileno(), sys.stderr.fileno())


class Session:
    index = 0

    def __init__(self, client_socket):
        Session.index += 1
        self.__id = Session.index
        self.__client_socket = client_socket
        self._attr = {}

    def get_id(self):
        return self.__id

    def set_attr(self, key, value):
        self._attr[key] = value

    def get_client_socket(self):
        return self.__client_socket


class AddressType:
    IPV4 = 1
    DOMAIN_NAME = 3
    IPV6 = 4


class SocksCommand:
    CONNECT = 1
    BIND = 2
    UDP_ASSOCIATE = 3


class SocksMethod:
    NO_AUTHENTICATION_REQUIRED = 0
    GSS_API = 1
    USERNAME_PASSWORD = 2


class ServerReply:
    def __init__(self, value):
        self.__value = value

    def get_byte_string(self):
        if self.__value == 0:
            return b'\x00'
        elif self.__value == 1:
            return b'\x01'
        elif self.__value == 2:
            return b'\x02'
        elif self.__value == 3:
            return b'\x03'
        elif self.__value == 4:
            return b'\x04'
        elif self.__value == 5:
            return b'\x05'
        elif self.__value == 6:
            return b'\x06'
        elif self.__value == 7:
            return b'\x07'
        elif self.__value == 8:
            return b'\x08'

    def get_value(self):
        return self.__value


class ReplyType:
    SUCCEEDED = ServerReply(0)
    GENERAL_SOCKS_SERVER_FAILURE = ServerReply(1)
    CONNECTION_NOT_ALLOWED_BY_RULESET = ServerReply(2)
    NETWORK_UNREACHABLE = ServerReply(3)
    HOST_UNREACHABLE = ServerReply(4)
    CONNECTION_REFUSED = ServerReply(5)
    TTL_EXPIRED = ServerReply(6)
    COMMAND_NOT_SUPPORTED = ServerReply(7)
    ADDRESS_TYPE_NOT_SUPPORTED = ServerReply(8)


class BCF:
    """BCF Bridging function chain"""

    def __init__(self, chain=0, buffer_size=1024*1024):
        FW_SVC=os.environ.get("EPI_VNF_FW")
        FW_SVC_PORT=os.environ.get("EPI_VNF_FW_PORT", 5000)
        self.VNF_cluster_IPs = {"firewall": gethostbyname(FW_SVC) + ":" + FW_SVC_PORT}
        self.server_port = -1
        self.buffer_size = buffer_size
        self.server_thread = None
        self.client_socket = None
        self.client_port = -1
        self.connection = None


        print("[BCF] get peername")

        # Get ip of hostname
        hostname = gethostname()

        self.src = gethostbyname(hostname)

        print(f"[BCF] peername is src,port={self.src}")
        
        # Start server
        self.server()
        # self.create_iptables()
        # time.sleep(1)


    def client(self):
        """Creates client socket to the server port of this BCF"""
        s = socket(AF_INET, SOCK_STREAM)
        s.connect((self.src, self.server_port))
        self.client_socket = s
        self.client_port = s.getsockname()[1]

    def client_send(self, data):
        """Send all data to the server of this BCF"""
        with open("client", "w") as f:
            f.write("[Client] sendall")
            self.client_socket.sendall(data)
            f.write("[Client] stop sending")

    def server(self):
        """BCF server

        Creates a server socket on a random port, which is saved. It then
        puts the server in a thread.
        """
        s = socket(AF_INET, SOCK_STREAM)
        s.bind((self.src, 0))
        self.server_port = s.getsockname()[1]
        print(f"[BCF.server] Internal client server on port {self.server_port}")
        s.listen(1)
        print(f"[BCF.server] start client ")
        self.client()
        print(f"[BCF.server] accept client ")
        conn, addr = s.accept()
        self.connection = conn

        # with conn:
        #     print('Connected by', addr)
        #     while True:
        #         data = conn.recv(1024)
        #         if not data:
        #             break
        #         conn.sendall(data)
    
    def close(self):
        print("[BCF.close] close everyting.")
        self.server_socket.close()
        self.client_socket.close()
        # self.delete_iptables()


    def create_iptables(self):
        print("[BCF] create iptables")

        # Ipables need to change every connection from this proxy to itself, the source port needs to become 
        # the destination port. So the VNF can just send it to the other endpoint.
        # iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination $EPI_SERVER_VAR:$EPI_SERVER_PORT

        to_firewall_client = (f"iptables -w -t nat -A OUTPUT -p tcp  "
                f"--dst {self.src} --src {self.src} --sport {self.client_port}  -j DNAT "
                f"--to-destination {self.VNF_cluster_IPs['firewall']}")

        to_firewall_server = (f"iptables -w -t nat -A OUTPUT -p tcp  "
                f"--dst {self.src} --src {self.src} --sport {self.server_port}  -j DNAT "
                f"--to-destination {self.VNF_cluster_IPs['firewall']}")

        server_vnf_client = (f"iptables -w -t nat -A PREROUTING -p tcp  "
                f"--dst {self.src} --dport {self.server_port} -j DNAT "
                f"--to-destination {self.src}:{self.client_port}")

        client_vnf_server = (f"iptables -w -t nat -A PREROUTING -p tcp  "
                f"--dst {self.src} --dport {self.client_port} -j DNAT "
                f"--to-destination {self.src}:{self.server_port}")

        print(f"[BCF] first rule {to_firewall_client}")
        print(f"[BCF] second rule {client_vnf_server}")
        print(f"[BCF] third rule {server_vnf_client}")


        # Route traffic through clusterIP of the VNF instance
        os.system(to_firewall_client)
        os.system(to_firewall_server)
        os.system(client_vnf_server)
        os.system(server_vnf_client)


    def delete_iptables(self):
        print("[BCF] delete iptables")

        # Route traffic through clusterIP of the VNF instance
        to_firewall = (f"iptables -t nat -D OUTPUT -p tcp  "
                f"--dst {self.src} --src {self.src} --dport {self.server_port} -j DNAT "
                f"--to-destination {self.VNF_cluster_IPs['firewall']}")


        server_vnf_client = (f"iptables -t nat -D PREROUTING -p tcp  "
                f"--dst {self.src} --dport {self.server_port} -j DNAT "
                f"--to-destination {self.src}:{self.client_port}")

        client_vnf_server = (f"iptables -t nat -D PREROUTING -p tcp  "
                f"--dst {self.src} --dport {self.client_port} -j DNAT "
                f"--to-destination {self.src}:{self.server_port}")


        # os.system(to_firewall)
        # os.system(client_vnf_server)
        # os.system(server_vnf_client)




class SocketPipe:
    BUFFER_SIZE = 1024 * 1024

    def __init__(self, socket1, socket2):
        self._socket1 = socket1
        self._socket2 = socket2
        self.__running = False

        self.t1 = threading.Thread(target=self.__transfer, args=(self._socket1, self._socket2))
        self.t2 = threading.Thread(target=self.__transfer, args=(self._socket2, self._socket1))

    def __transfer(self, socket1, socket2):
        while self.__running:
            try:
                data = socket1.recv(self.BUFFER_SIZE)

                if len(data) > 0:
                    socket2.sendall(data)
                else:
                    break
            except IOError:

                self.stop()
        self.stop()

    def start(self):
        self.__running = True

        self.t1.start()
        self.t2.start()

    def stop(self):
        self._socket1.close()
        self._socket2.close()

        self.__running = False

    def is_running(self):
        return self.__running


class CommandExecutor:
    def __init__(self, remote_server_host, remote_server_port, session):
        self.__proxy_socket = socket(AF_INET, SOCK_STREAM)
        self.__remote_server_host = remote_server_host
        self.__remote_server_port = remote_server_port
        self.__client = session.get_client_socket()
        self.__session = session

    def do_connect(self):
        """
        Do SOCKS CONNECT method
        :return: None
        """
        address = self.__get_address()
        print("Connect request to %s", address)
        result = self.__proxy_socket.connect_ex(address)
        if result == 0:
            self.__client.send(build_command_response(ReplyType.SUCCEEDED))
            socket_pipe = SocketPipe(self.__client, self.__proxy_socket)
            socket_pipe.start()
            while socket_pipe.is_running():
                pass
        elif result == 60:
            self.__client.send(build_command_response(ReplyType.TTL_EXPIRED))
        elif result == 61:
            self.__client.send(build_command_response(ReplyType.NETWORK_UNREACHABLE))
        else:
            logging.error('Connection Error:[%s] is unknown', result)
            self.__client.send(build_command_response(ReplyType.NETWORK_UNREACHABLE))

    def do_bind(self):
        pass

    def do_udp_associate(self):
        pass

    def __get_address(self):
        return self.__remote_server_host, self.__remote_server_port


class User:
    def __init__(self, username, password):
        self.__username = username
        self.__password = password

    def get_username(self):
        return self.__username

    def get_password(self):
        return self.__password

    def __repr__(self):
        return '<user: username=%s, password=%s>' % (self.get_username(), self.__password)


class UserManager:
    def __init__(self):
        self.__users = {}

    def add_user(self, user):
        self.__users[user.get_username()] = user

    def remove_user(self, username):
        if username in self.__users:
            del self.__users[username]

    def check(self, username, password):
        if username in self.__users and self.__users[username].get_password() == password:
            return True
        else:
            return False

    def get_user(self, username):
        return self.__users[username]

    def get_users(self):
        return self.__users


class Socks5RequestHandler(StreamRequestHandler):
    def __init__(self, request, client_address, server):
        StreamRequestHandler.__init__(self, request, client_address, server)

    def handle(self):
        # METRICS: added
        print("[HANDLE] add to metrics")
        metricGatherer.metrics["number_of_requests"] += 1

        session = Session(self.connection)
        print('Create session[%s] for %s:%d', 1, self.client_address[0], self.client_address[1])
        # print(self.server.allowed)
        if self.server.allowed and self.client_address[0] not in self.server.allowed:
            print('Remote IP not in allowed list. Closing connection')
            close_session(session)
            return
        client = self.connection
        client.recv(1)
        method_num, = struct.unpack('b', client.recv(1))
        meth_bytes = client.recv(method_num)
        methods = struct.unpack('b' * method_num, meth_bytes)
        auth = self.server.is_auth()
        if methods.__contains__(SocksMethod.NO_AUTHENTICATION_REQUIRED) and not auth:
            client.send(b"\x05\x00")
        elif methods.__contains__(SocksMethod.USERNAME_PASSWORD) and auth:
            client.send(b"\x05\x02")
            if not self.__do_username_password_auth():
                print('Session[%d] authentication failed', session.get_id())
                close_session(session)
                return
        else:
            print('Client requested unknown method (%s, %s->%s). Cannot continue.', methods, method_num,
                         meth_bytes)
            client.send(b"\x05\xFF")
            return

        version, command, reserved, address_type = struct.unpack('B' * 4, client.recv(4))
        host = None
        port = None
        if address_type == AddressType.IPV4:
            ip_a, ip_b, ip_c, ip_d, port = struct.unpack('!' + ('b' * 4) + 'H', client.recv(6))
            host = host_from_ip(ip_a, ip_b, ip_c, ip_d)
        elif address_type == AddressType.DOMAIN_NAME:
            host_length, = struct.unpack('b', client.recv(1))
            host = client.recv(host_length)
            port, = struct.unpack('!H', client.recv(2))
        elif address_type == AddressType.IPV6:
            ip6_01, ip6_02, ip6_03, ip6_04, \
            ip6_05, ip6_06, ip6_07, ip6_08, \
            ip6_09, ip6_10, ip6_11, ip6_12, \
            ip6_13, ip6_14, ip6_15, ip6_16, \
            port = struct.unpack('!' + ('b' * 16) + 'H', client.recv(18))

            print("Address type not implemented: %s (IPV6 Connect)", address_type)
            print("Params: %s, port: %s", (
                ip6_01, ip6_02, ip6_03, ip6_04, ip6_05, ip6_06, ip6_07, ip6_08, ip6_09, ip6_10, ip6_11, ip6_12, ip6_13,
                ip6_14, ip6_15, ip6_16), port)
            client.send(build_command_response(ReplyType.ADDRESS_TYPE_NOT_SUPPORTED))
            return

        else:  # address type not support
            print("Address type not supported: %s", address_type)
            client.send(build_command_response(ReplyType.ADDRESS_TYPE_NOT_SUPPORTED))
            return

        command_executor = CommandExecutor(host, port, session)
        if command == SocksCommand.CONNECT:
            print("Session[%s] Request connect %s:%s", session.get_id(), host, port)
            command_executor.do_connect()
        close_session(session)

    def __do_username_password_auth(self):
        client = self.connection
        client.recv(1)
        length = byte_to_int(struct.unpack('b', client.recv(1))[0])
        username = client.recv(length)
        length = byte_to_int(struct.unpack('b', client.recv(1))[0])
        password = client.recv(length)
        user_manager = self.server.get_user_manager()
        if user_manager.check(username, password):
            client.send(b"\x01\x00")
            return True
        else:
            client.send(b"\x01\x01")
            return False


class Socks5Server(ThreadingTCPServer):
    """
    SOCKS5 proxy server
    """

    def __init__(self, port, auth=False, user_manager=UserManager(), allowed=None):
        ThreadingTCPServer.__init__(self, ('', port), Socks5RequestHandler)
        self.__port = port
        self.__users = {}
        self.__auth = auth
        self.__user_manager = user_manager
        self.__sessions = {}
        self.allowed = allowed


        self.th = threading.Thread(target=self.serve_forever)

    def serve_forever(self, poll_interval=0.5):
        print("Create SOCKS5 server at port %d", self.__port)
        ThreadingTCPServer.serve_forever(self, poll_interval)

    def finish_request(self, request, client_address):
        BaseServer.finish_request(self, request, client_address)

    def is_auth(self):
        return self.__auth

    def set_auth(self, auth):
        self.__auth = auth

    def get_all_managed_session(self):
        return self.__sessions

    def get_bind_port(self):
        return self.__port

    def get_user_manager(self):
        return self.__user_manager

    def set_user_manager(self, user_manager):
        self.__user_manager = user_manager

    def run_in_thread(self):
        self.th.start()

    def stop_server_thread(self):
        self.server_close()
        self.shutdown()
        self.th.join()


def check_os_support():
    if not support_os.__contains__(current_os):
        print('Not support in %s' % current_os)
        sys.exit()


def stop(pid_file):
    check_os_support()
    print('Stopping server...', end=' ')
    try:
        f = open(pid_file, 'r')
        pid = int(f.readline())
        os.kill(pid, signal.SIGTERM)
        os.remove(pid_file)
        print("                 [OK]")
    except OSError:
        print("pysocks is not running")
    except IOError:
        print("pysocks is not running")


def status(pid_file):
    check_os_support()
    try:
        f = open(pid_file, 'r')
        pid = int(f.readline())
        print('pysocks(pid %d) is running...' % pid)
    except IOError:
        print("pysocks is stopped")


def start_command(args):
    enable_log = False
    log_file = args.logfile
    auth = args.auth is not None
    pid_file = args.pidfile
    user_manager = UserManager()
    should_daemonisze = False
    if auth:
        for user in args.auth:
            user_pwd = user.split(':')
            user_manager.add_user(User(user_pwd[0], user_pwd[1]))
    if enable_log:
        logging.basicConfig(level=logging.INFO,
                            format='%(asctime)s %(levelname)s - %(message)s',
                            filename=log_file,
                            filemode='a')
        console = logging.StreamHandler(sys.stdout)
        console.setLevel(logging.INFO)
        formatter = logging.Formatter('%(asctime)s %(levelname)-5s %(lineno)-3d - %(message)s')
        console.setFormatter(formatter)
        logging.getLogger().addHandler(console)

    Socks5Server.allow_reuse_address = True
    socks5_server = Socks5Server(args.port, auth, user_manager, allowed=args.allow_ip)
    try:
        if support_os.__contains__(current_os) and should_daemonisze:
            run_daemon_process(pid_file=pid_file, start_msg='Start SOCKS5 server at pid %s\n')
        socks5_server.serve_forever()
    except KeyboardInterrupt:
        socks5_server.server_close()
        socks5_server.shutdown()
        print("SOCKS5 server shutdown")



def stop_command(args):
    pid_file = pid_file = args.pidfile
    stop(pid_file)
    sys.exit()


def status_command(args):
    pid_file = args.pidfile
    status(pid_file)
    sys.exit()


def main():
    print("hello")
    default_pid_file = os.path.join(os.path.expanduser('~'), '.pysocks.pid')
    default_log_file = os.path.join(os.path.expanduser('~'), 'pysocks.log')
    parser = argparse.ArgumentParser(description='start a simple socks5 server',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    subparsers = parser.add_subparsers(help='sub-command help')
    parser_start = subparsers.add_parser('start', help='start a SOCKS5 server', description='start a SOCKS5 server',
                                         formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_start.add_argument('-p', '--port', type=int, help='specify server port, default 1080', default=1080)
    parser_start.add_argument('-f', '--foreground', help='stay in foreground (prevents daemonization)',
                              action='store_true', default=False)
    parser_start.add_argument('-i', '--allow-ip', nargs='+', help='allowed client IP list')
    parser_start.add_argument('-a', '--auth', nargs='+', help='allowed users')
    parser_start.add_argument('-L', '--logfile', help='log file', default=default_log_file)
    parser_start.add_argument('-P', '--pidfile', help='pid file', default=default_pid_file)
    parser_start.set_defaults(func=start_command)
    parser_stop = subparsers.add_parser('stop', help='stop a SOCKS5 server', description='stop a SOCKS5 server',
                                        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_stop.add_argument('-P', '--pidfile', help='pid file', default=default_pid_file)
    parser_stop.set_defaults(func=stop_command)
    parser_status = subparsers.add_parser('status', help='print SOCKS5 server status',
                                          description='print SOCKS5 server status',
                                          formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_status.add_argument('-P', '--pidfile', help='pid file', default=default_pid_file)
    parser_status.set_defaults(func=status_command)
    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    t1 = threading.Thread(target=app.run, kwargs={'host':'0.0.0.0', 'port': 80}).start()
    main()