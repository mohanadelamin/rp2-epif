# -*- coding: utf-8 -*-

import random


def choose_random_page():
    pages = [
        '/get',
        # '/response-headers?freeform=helloworld!',
        # '/headers',
        # '/ip',
        # #'/user-agent'
        # '/deflate',
        # '/deny',
        # '/encoding/utf8',
        # '/gzip',
        '/html',
        '/json',
        # '/xml',
        # '/uuid',
        # '/drip?duration=2&numbytes=10&code=200&delay=2',
        #'/delay/' + str(random.randrange(10)),
        #'/bytes/' + str(random.randrange(100)),
        # '/cookies',
        '/anything'
    ]

    return random.choice(pages)
