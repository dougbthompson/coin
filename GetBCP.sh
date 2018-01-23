#!/bin/bash

# ./G.sh | tr '\n' ' ' | sed -f sed.sed > bcp

export FILE0=$1
export ZDATE=$2
export DT=`date "+%m"`
cd /opt/coins/coinmarketcap

export FILE1=/tmp/bcp.1
cat /dev/null > ${FILE1}

# correct FILE2
export FILE2a="2018bcp/${DT}/cmc"
export FILE2b=`echo ${FILE0} | cut -d'.' -f2`
export FILE2="${FILE2a}.${FILE2b}.bcp"

export FIRST=0
while read LINE # '{'
do
    if [ "${FIRST}" = "0" ]; then
        read LINE
        export FIRST=1
        echo "{" >> ${FILE1}
    fi

    read LINE_ID;                     export                    L_ID=`echo ${LINE_ID} | sed -e"s/: /:/"`
    read LINE_NAME;                   export                  L_NAME=`echo ${LINE_NAME} | sed -e"s/: /:/"`
    read LINE_SYMBOL;                 export                L_SYMBOL=`echo ${LINE_SYMBOL} | sed -e"s/: /:/"`
    read LINE_RANK;                   export                  L_RANK=`echo ${LINE_RANK} | sed -e"s/: /:/"`
    read LINE_PRICE_USD;              export             L_PRICE_USD=`echo ${LINE_PRICE_USD} | sed -e"s/: /:/"`
    read LINE_PRICE_BTC;              export             L_PRICE_BTC=`echo ${LINE_PRICE_BTC} | sed -e"s/: /:/"`
    read LINE_24H_VOLUME_USD;         export        L_24H_VOLUME_USD=`echo ${LINE_24H_VOLUME_USD} | sed -e"s/: /:/" | sed -e"s/24h_volume_usd/volume_usd_24h/"`
    read LINE_MARKET_CAP_USD;         export        L_MARKET_CAP_USD=`echo ${LINE_MARKET_CAP_USD} | sed -e"s/: /:/"`
    read LINE_AVAILABLE_SUPPLY;       export      L_AVAILABLE_SUPPLY=`echo ${LINE_AVAILABLE_SUPPLY} | sed -e"s/: /:/"`
    read LINE_TOTAL_SUPPLY;           export          L_TOTAL_SUPPLY=`echo ${LINE_TOTAL_SUPPLY} | sed -e"s/: /:/"`
    read LINE_MAX_SUPPLY;             export            L_MAX_SUPPLY=`echo ${LINE_MAX_SUPPLY} | sed -e"s/: /:/"`
    read LINE_PERCENTAGE_CHANGE_1H;   export  L_PERCENTAGE_CHANGE_1H=`echo ${LINE_PERCENTAGE_CHANGE_1H} | sed -e"s/: /:/"`
    read LINE_PERCENTAGE_CHANGE_24H;  export L_PERCENTAGE_CHANGE_24H=`echo ${LINE_PERCENTAGE_CHANGE_24H} | sed -e"s/: /:/"`
    read LINE_PERCENTAGE_CHANGE_7D;   export  L_PERCENTAGE_CHANGE_7D=`echo ${LINE_PERCENTAGE_CHANGE_7D} | sed -e"s/: /:/"`
    read LINE_LAST_UPDATED;           export          L_LAST_UPDATED=`echo ${LINE_LAST_UPDATED} | sed -e"s/: /:/"`

    read LINE  # '},'

    export SYMBOL=`echo ${L_SYMBOL} | sed -e"s/,//" | cut -'d:' -f2`

    echo "${SYMBOL}:{${L_ID}${L_NAME}${L_SYMBOL}${L_RANK}${L_PRICE_USD}${L_PRICE_BTC}${L_24H_VOLUME_USD}${L_MARKET_CAP_USD}${L_AVAILABLE_SUPPLY}${L_TOTAL_SUPPLY}${L_MAX_SUPPLY}${L_PERCENTAGE_CHANGE_1H}${L_PERCENTAGE_CHANGE_24H}${L_PERCENTAGE_CHANGE_7D}${L_LAST_UPDATED},\"date_actual\":\"${ZDATE}\"}," >> ${FILE1}

done < ${FILE0}

echo "}" >> ${FILE1}
cat ${FILE1} | tr '\n' ' ' | sed -f sed.sed > ${FILE2}

mysql coins -e "LOAD DATA local INFILE '${FILE2}' INTO TABLE cmc(x);"

exit

