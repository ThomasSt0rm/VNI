from __future__ import print_function
import json
import urllib2
from time import sleep

while True:
    bittrex_req = urllib2.urlopen('https://bittrex.com/api/v1.1/public/getmarketsummaries')
    content = json.load(bittrex_req)
    if content['success']:
        for market in content['result']:
            print('Market ' + str(market['MarketName']) + ' last price is ' + str(market['Last']))
    else:
        print(content['message'])
    sleep(600)