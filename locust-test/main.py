# -*- coding: utf-8 -*-

from locust import User, task, between, requests
from lib.epif_functions import choose_random_page


default_headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36'}


class WebsiteUser(User):
    #wait_time = between(1, 2)

    @task(1)
    def get_index(self):
        answer = requests.get("/", headers=default_headers)

    @task(3)
    def get_random_page(self):
        answer = requests.get(choose_random_page(), headers=default_headers)

    # @task(1)
    # def get_index(self):
    #     self.client.get("/", headers=default_headers)

    # @task(3)
    # def get_random_page(self):
    #     self.client.get(choose_random_page(), headers=default_headers)