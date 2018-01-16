#!/bin/bash

# LOAD DATA local INFILE '/tmp/file' INTO TABLE test (x);
# mysql coins -e "truncate table test;"

for F1 in `find 201711 -name "*.json" -print`
do
    export F2=`echo ${F1} | sed -e"s/201711/201711bcp/" | sed -e"s/json/bcp/" `
    echo "${F1} - ${F2} "

    cat ${F1} | tr '\n' ' ' | sed -f sed.sed > ${F2}
    mysql coins -e "LOAD DATA local INFILE '${F2}' replace INTO TABLE test (x);"

done

