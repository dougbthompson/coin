#!/bin/bash

#
cd /opt/coins/icos

export DT=`date "+%Y-%m-%d-%H-%M"`
export DTY=`date "+%Y"`
export DTM=`date "+%m"`
export DTD=`date "+%d"`
export F1="${DTY}/${DTM}/${DTD}/ico.${DT}.html"

curl --output /tmp/ico https://icodrops.com/category/upcoming-ico/
cat /tmp/ico | sed -e "s/^M//g" | sed -e s"/\t//g" | sed -e "/^$/d" > ${F1}

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

# the correct file path is in ${F1}, sort of

./GetICO.sh "./${F1}"

exit

