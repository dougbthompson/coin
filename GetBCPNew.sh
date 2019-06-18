#!/bin/bash

# ./G.sh | tr '\n' ' ' | sed -f sed.sed > bcp
# $JSON = /opt/coins/coinmarketcap/cmc/2019_json/01/03/cmc.2019-01-03-09-58.json 
# $zDT  = 2019-01-03 09:58:00

cd /opt/coins/coinmarketcap

export FILE0=$1
export ZDATE=$2
export DYR=`echo $ZDATE | cut -d'-' -f1`
export DTM=`echo $ZDATE | cut -d'-' -f2`
export DTD=`echo $ZDATE | cut -d'-' -f3 | cut -d' ' -f1`

# correct FILE2
export FILE2a="cmc/${DYR}_bcp/${DTM}/${DTD}/cmc"
export FILE2b=`echo ${FILE0} | cut -d'.' -f2`
export FILE2="${FILE2a}.${FILE2b}.bcp"

cat ${FILE0} | tr '\n' ' ' | sed -f sed.sed > ${FILE2}

mysql coins -e "LOAD DATA local INFILE '${FILE2}' INTO TABLE cmc_api(x);"

exit

