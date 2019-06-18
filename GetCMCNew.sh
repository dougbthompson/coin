#!/bin/bash

#
# directory structure cmc, cmc/2019_json, cmc/2019_bcp
# $JSON = /opt/coins/coinmarketcap/cmc/2019_json/01/03/cmc.2019-01-03-09-58.json 
# $zDT  = 2019-01-03 09:58:00
#
# https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?CMC_PRO_API_KEY=4f555a16-64b4-4ec2-87b7-cbf0a7179c71&limit=200
# https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?CMC_PRO_API_KEY=4f555a16-64b4-4ec2-87b7-cbf0a7179c71&symbol=BTC,BCH,DRGN,ETH,NCASH,POE,TRX,XLM
#

cd /opt/coins/coinmarketcap

export DT=`date "+%Y-%m-%d-%H-%M"`
export DTY=`date "+%Y"`
export DTM=`date "+%m"`
export DTD=`date "+%d"`
export F1="cmc/${DTY}_json/${DTM}/${DTD}/cmc.${DT}.json"

curl --output ${F1} -d "limit=400" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?CMC_PRO_API_KEY=4f555a16-64b4-4ec2-87b7-cbf0a7179c71

export PWD=`pwd`
export YR=`echo ${F1} | cut -d'_' -f1 | cut -d'/' -f2`
export F2=`echo ${F1} | cut -d'/' -f5- | sed -e"s/json/bcp/" `
export DI="cmc/${YR}_bcp"
export BCP="${PWD}/${DI}/${DTM}/${DTD}/${F2}"

# cmc/2019_json/01/03/cmc.2019-01-03-09-58.json
export zYE=`echo ${F1} | cut -d'.' -f2 | cut -d'-' -f1`
export zMO=`echo ${F1} | cut -d'-' -f2`
export zDA=`echo ${F1} | cut -d'-' -f3`
export zHO=`echo ${F1} | cut -d'-' -f4`
export zMI=`echo ${F1} | cut -d'-' -f5 | cut -d'.' -f1`
export zDT="${zYE}-${zMO}-${zDA} ${zHO}:${zMI}:00"
export JSON="${PWD}/${F1}"

./GetBCPNew.sh ${JSON} "${zDT}"

exit

