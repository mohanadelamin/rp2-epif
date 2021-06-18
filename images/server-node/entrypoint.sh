#!/usr/bin/env bash

nohup bash /monitor.sh &
/usr/bin/python3 /usr/local/bin/gunicorn -b 0.0.0.0:80 httpbin:app -k gevent
sleep infinity