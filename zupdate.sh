#!/bin/bash

typeset -i VAL=$1

cd /opt/coin

# echo "Val- ${VAL}) "
if [ "${VAL}" -eq 0 ]; then
    typeset -i VAL=`echo $((0 + RANDOM % 8))`
fi
# echo "Val- ${VAL}) "
# echo ""

while [ ${VAL} -gt 0 ]
do
    echo "Val: ${VAL}) "
    echo "--" >> /opt/coins/coinmarketcap/report02.sql; gitt.sh

    (( VAL = VAL - 1 ))
done

