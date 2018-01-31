#!/usr/bin/python

from lxml import html
from lxml import etree
import requests

# <a href="https://icodrops.com/kodakone/" rel="bookmark">KodakOne</a>
parser = etree.HTMLParser()
tree   = etree.parse(StringIO(broken_html), parser)

result = etree.tostring(tree.getroot(), pretty_print=True, method="html")


tree = etree.parse("icodrops.html")

coins  = tree.xpath('//a[@href="https://icodrops.com/*"]/text()')
print 'Coins: ', coins
