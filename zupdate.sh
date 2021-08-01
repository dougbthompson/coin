#!/bin/bash

cd /opt/coin

typeset -i RAN=`echo $((1 + $RANDOM % 10))`
if [ ${RAN} -gt 6 ]; then 
    exit
fi

typeset -i VAL=`echo $((1 + $RANDOM % 8))`

while [ ${VAL} -gt 0 ]
do
    echo "Val: ${VAL}) "
    echo "--" >> /opt/coins/coinmarketcap/report02.sql
    /home/adminuser/gitt.sh

    (( VAL = VAL - 1 ))
done

