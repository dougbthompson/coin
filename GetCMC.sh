#!/bin/bash

cd /opt/coins/coinmarketcap
# curl --output ${F1} https://poloniex.com/public?command=returnTicker
# curl --output "file.txt" https://poloniex.com/public?command=returnTicker

export DT=`date "+%Y-%m-%d-%H-%M"`
export DTY=`date "+%Y"`
export DTM=`date "+%m"`
export DTD=`date "+%d"`

export F1="${DTY}/${DTM}/${DTD}/cmc.${DT}.json"

curl --output ${F1} https://api.coinmarketcap.com/v1/ticker/?limit=0

export PWD=`pwd`
export YR=`echo ${F1} | cut -d'/' -f1`
export F2=`echo ${F1} | cut -d'/' -f4- | sed -e"s/json/bcp/" `
export DI="${YR}bcp"
export BCP="${PWD}/${DI}/${F2}"

export zYE=`echo ${F1} | cut -d'/' -f1`
export zMO=`echo ${F1} | cut -d'/' -f2`
export zDA=`echo ${F1} | cut -d'/' -f3`
export zHO=`echo ${F1} | cut -d'-' -f4`
export zMI=`echo ${F1} | cut -d'-' -f5 | cut -d'.' -f1`
export zDT="${zYE}-${zMO}-${zDA} ${zHO}:${zMI}:00"

export JSON="${PWD}/${F1}"
./GetBCP.sh ${JSON} "${zDT}"
exit

# cat ${F1} | tr '\n' ' ' | sed -f sed.sed | sed -e "s/}}/},\"DATE\":\"${zDT}\"}/" > ${BCP}
# mysql coins -e "LOAD DATA local INFILE '${BCP}' replace INTO TABLE cmc (x);"
# mysql coins -e "update cmc set lstd = unix_timestamp(lst) where lstd is null;"

