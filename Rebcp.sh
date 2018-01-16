#!/bin/bash

cd /opt/coins/mph
# curl --output "file.txt" https://poloniex.com/public?command=returnTicker
# export DT=`date "+%Y-%m-%d-%H-%M"`
# export DTY=`date "+%Y"`
# export DTM=`date "+%m"`
# export DTD=`date "+%d"`
# export F1="${DTY}/${DTM}/${DTD}/mph.${DT}.json"
# curl --output ${F1} https://poloniex.com/public?command=returnTicker

# Start of script

for F1 in `find 2018/01/0* -name "*" -print`
do
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
export zDT="${zYE}-${zMO}-${zDA} ${zHO}:${zMI}"

echo "${zDT} - ${BCP}"
cat ${F1} | tr '\n' ' ' | sed -f sed.sed | sed -e "s/}}/},\"DATE\":\"${zDT}\"}/" > ${BCP}
mysql coins -e "LOAD DATA local INFILE '${BCP}' replace INTO TABLE mph (x);"
mysql coins -e "update mph set lstd = unix_timestamp(lst) where lstd is null;"

done
exit

# cat ${F1} | tr '\n' ' ' | sed -f sed.sed | sed -e "s/}}/},\"DATE\":\"${zDT}\"}/" > ${BCP}
# mysql coins -e "LOAD DATA local INFILE '${BCP}' replace INTO TABLE mph (x);"
# mysql coins -e "update mph set lstd = unix_timestamp(lst) where lstd is null;"

