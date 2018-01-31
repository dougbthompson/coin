#!/usr/bin/python 

from bs4 import BeautifulSoup
import re
import sys
import mysql.connector

def has_href_but_no_id(tag):
    return tag.has_attr('href') and not tag.has_attr('id')

def has_class(tag):
    return tag.has_attr('class')

def get_goal(tag):
    if len(tag.contents[0].split(" ")) == 4:
        return u'Not Set'
    if len(tag.contents[0].split(" ")) == 3:
        x1 = tag.contents[0].split(" ")
        x2 = x1[2].split('\t')
        return x2[0]
    if len(tag.contents[0].split(" ")) == 1:
        x1 = tag.contents[1].contents[0].split('\t')
        if len(x1) == 1:
            x1 = tag.contents[1].contents[0].split('\n')
            return x1[1]
        else:
            return x1[1]

def get_interest(tag):
    if len(tag.contents[1].contents[0].split('\t')) == 1:
       if len(tag.contents[1].contents[0].split('\n')) == 2:
           x1 = tag.contents[1].contents[0].split('\n')
           return x1[1]
       else:
           return u'Not Rated'
    if len(tag.contents[1].contents[0].split('\t')) == 9:
        x1 = tag.contents[1].contents[0].split('\t')
        return x1[4]

file_name = sys.argv[1]
date_time = sys.argv[2]
date_ts   = sys.argv[3]

# print(file_name, date_time, date_ts)

raw_data = open(file_name, 'r')
soup = BeautifulSoup(raw_data, 'html.parser')

hrf_tags = soup.find_all(has_href_but_no_id, rel="bookmark")
icn_tags = soup.find_all('span', 'ico-category-name')
gic_tags = soup.find_all('div', 'goal-in-card')
cds_tags = soup.find_all('div', 'categ_desc_short')
int_tags = soup.find_all('div', 'interest')
cty_tags = soup.find_all('div', 'categ_type')

cnx = mysql.connector.connect(user='root', database='coins')
cursor = cnx.cursor()

insert_entry = ("replace into ico_entry "
                "(c_dt, c_ts, c_name, c_type, c_goal, c_description, c_interest) "
                "values (%s, %s, %s, %s, %s, %s, %s)")

for i in range(len(icn_tags)):
#    print(i),
#    print(hrf_tags[i].contents[0]),
#    print("-"),
#    print(icn_tags[i].contents[0]),
#    print("-"),
#    print(get_goal(gic_tags[i])),
#    print("-"),
#    print(cds_tags[i].contents[0]),
#    print("-"),
#    print(get_interest(int_tags[i])),
#    print("-"),
#    print(cty_tags[i].contents[0])
    data_entry = (str(date_time), date_ts, str(hrf_tags[i].contents[0]), str(icn_tags[i].contents[0]),
                  str(get_goal(gic_tags[i])), str(cds_tags[i].contents[0]), str(get_interest(int_tags[i])))
    cursor.execute(insert_entry, data_entry)
    cnx.commit()

cursor.close()
cnx.close()

