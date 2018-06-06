#!/bin/bash

# curl -H "X-MBX-APIKEY: "qaM8qLwLn1Pxh2KKHV1dCoMIC674nFtxBiPykKZPrbxJmReuPBrnjSOprU6EIN4s" -X POST 'https://api.binance.com/api/v3/BTC/price
# curl --output "bin.20180312.105600.txt" -s "https://api.binance.com/api/v1/exchangeInfo"
# curl --output "bin.20180312.111200.txt" -s "https://api.binance.com/api/v1/24hr"

cd /opt/coins/coinmarketcap

export DT=`date "+%Y%m%d.%H%M%S"`
export YE=`date "+%Y"`
export MO=`date "+%m"`
export DA=`date "+%d"`
echo ${DT}

for SYM in `echo "POEETH POEBTC XLMETH XLMBTC TRXETH TRXBTC XRPETH XRPBTC BTCUSDT"`
do
    curl --output "Bin/${YE}/${MO}/${DA}/bin.${DT}.${SYM}.txt" -s "https://api.binance.com/api/v1/ticker/24hr?symbol=${SYM}"
done

