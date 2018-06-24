#!/bin/bash

cd /opt/coin
typeset -i VAL=`echo $((0 + RANDOM % 8))`

while [ ${VAL} -gt 0 ]
do
    echo "Val: ${VAL}) "
    echo "--" >> /opt/coins/coinmarketcap/report02.sql; gitt.sh

    (( VAL = VAL - 1 ))
done

