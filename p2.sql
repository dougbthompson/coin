#!/usr/bin/python

from BeautifulSoup import BeautifulSoup

raw_data = open('icodrops.html', 'r')

souped_data = BeautifulSoup(raw_data, "html5lib")

for message in souped_data.find_all("div", {"class": "message"}):
    username = message.find('span', attrs={'class': 'user'}).get_text()
    meta = message.find('span', attrs={'class': 'meta'}).get_text()
    message = message.next_sibling 


