#!/usr/bin/env python3
from os import environ
from flask import Flask, request
from httpx import Client
from json import dumps

epi_server=environ.get("EPI_SERVER")

app = Flask(__name__)

@app.route("/api",methods=['GET','POST'])
def index():
    if request.method=='GET':
        payload = {
            'message': 'Hello, world!'
        }

        with Client() as client:
            r = client.post('http://' + epi_server + '/post', json=payload)
            return(dumps(r.json(), indent=2))
    else:
        return "This is a GET API method"

@app.after_request
def add_header(r):
    """
    Add headers to both force latest IE rendering engine or Chrome Frame,
    and also to cache the rendered page for 10 minutes.
    """
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    r.headers["Pragma"] = "no-cache"
    r.headers["Expires"] = "0"
    r.headers['Cache-Control'] = 'public, max-age=0'
    return r

if __name__ == '__main__':
    app.run(host = '0.0.0.0', port = 80, debug = True)