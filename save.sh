#!/bin/bash

cd /opt/coins/_siacoin

export DT=`date "+%Y%m%d-%H%M"`
export DT_YM=`date "+%Y%m"`
export F1="/opt/coins/_siacoin/${DT_YM}/sia.${DT}.json"

curl --output ${F1} 'https://siamining.com/api/v1/addresses/fedb235a0bc963023399311dc9801d2406771c88ce92361620f522198de16925113fdca3a731'

export ERR=`egrep "500 I" ${F1} | egrep "head"`
if [ "${ERR}" != "" ]; then
    rm ${F1}
else
    export F2=`echo ${F1} | sed -e"s/201711/201711bcp/" | sed -e"s/json/bcp/" `
    cat ${F1} | tr '\n' ' ' | sed -f sed.sed > ${F2}
    mysql coins -e "LOAD DATA local INFILE '${F2}' replace INTO TABLE test (x);"
fi

