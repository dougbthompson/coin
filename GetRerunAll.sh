#!/bin/bash

cd /opt/coins/coinmarketcap

for F1 in `find /opt/coins/coinmarketcap -name "*.json" -print`
do

    export PWD=`pwd`
    export YR=`echo ${F1} | cut -d'/' -f1`
    export F2=`echo ${F1} | cut -d'/' -f4- | sed -e"s/json/bcp/" `
    export DI="${YR}bcp"
    export BCP="${PWD}/${DI}/${F2}"

    export zYE=`echo ${F1} | cut -d'/' -f5`
    export zMO=`echo ${F1} | cut -d'/' -f6`
    export zDA=`echo ${F1} | cut -d'/' -f7`
    export zHO=`echo ${F1} | cut -d'-' -f4`
    export zMI=`echo ${F1} | cut -d'-' -f5 | cut -d'.' -f1`
    export zDT="${zYE}-${zMO}-${zDA} ${zHO}:${zMI}:00"

    export JSON="${F1}"

    echo "<${JSON}> <${zDT}>"
    ./GetBCP.sh ${JSON} "${zDT}"
done


