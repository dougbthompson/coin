#!/bin/bash

cd /opt/coins/icos
# curl --output ${ICO} https://icodrops.com/category/upcoming-ico/
# cat 2018/01/25/ico.2018-01-25-13-14.html | sed -e "s/^M//" | sed -e s"/\t//g" | sed -e "/^$/d"

export DT=`date "+%Y-%m-%d-%H-%M"`
export DTY=`date "+%Y"`
export DTM=`date "+%m"`
export DTD=`date "+%d"`

export F1="${DTY}/${DTM}/${DTD}/ico.${DT}.html"

curl --output /tmp/ico https://icodrops.com/category/upcoming-ico/
cat /tmp/ico | sed -e "s/^M//" | sed -e s"/\t//g" | sed -e "/^$/d" > ${F1}

export PWD=`pwd`
export YR=`echo ${F1} | cut -d'/' -f1`
export F2=`echo ${F1} | cut -d'/' -f4- | sed -e"s/html/bcp/" `
export DI="${YR}bcp/${DTM}/${DTD}"
export BCP="${PWD}/${DI}/${F2}"

export zYE=`echo ${F1} | cut -d'/' -f1`
export zMO=`echo ${F1} | cut -d'/' -f2`
export zDA=`echo ${F1} | cut -d'/' -f3`
export zHO=`echo ${F1} | cut -d'-' -f4`
export zMI=`echo ${F1} | cut -d'-' -f5 | cut -d'.' -f1`
export zDT="${zYE}-${zMO}-${zDA} ${zHO}:${zMI}:00"

export HTML="${PWD}/${F1}"
# ./GetBCP.sh ${JSON} "${zDT}"
exit

# cat ${F1} | tr '\n' ' ' | sed -f sed.sed | sed -e "s/}}/},\"DATE\":\"${zDT}\"}/" > ${BCP}
# mysql coins -e "LOAD DATA local INFILE '${BCP}' replace INTO TABLE cmc (x);"
# mysql coins -e "update cmc set lstd = unix_timestamp(lst) where lstd is null;"

