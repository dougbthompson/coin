#!/bin/sh

echo "--" >> /opt/coins/coinmarketcap/rep.sql

cd /opt/coin
find /opt/coins \( -name "*.sh" -o -name "*.sql" -o -name readme -o -name "Price*" \) -print -exec cp {} . \;
find /opt/coins/icos \( -name "*.sh" -o -name "*.sql" -o -name "*.py" \) -print -exec cp {} . \;

git add *

export DT=`date "+%Y%m%d %H:%M"`
git commit -m "${DT}"

git push origin master

