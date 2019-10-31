#!/bin/bash

export API_KEY=SQDA1ORM-ALCT0QSL-OXXJH7V6-ZTAFV1HD
export API_SECRET=2c5fbb9d848f325912ffd7f162f9a9769eba8842c9dd1959eeaca1e0d28fb829c7f3f9313cd1e2876d686dbb2b44b9ea17bd8554605e718a242b233b309c2fed
export API_SIGN=`echo -n "command=returnCompleteBalances&nonce=157245572100000" | openssl sha512 -hmac $API_SECRET | cut -d' ' -f2`
curl -X POST -d "command=returnCompleteBalances&nonce=157245572100000" -H "Key: ${API_KEY}" -H "Sign: ${API_SIGN}" https://poloniex.com/tradingApi

,"BTC":{"available":     "0.02477689","onOrders":"0.00000000","btcValue":"0.02477689"}
,"OMG":{"available":     "3.67329989","onOrders":"0.00000000","btcValue":"0.00038419"}
,"SC" :{"available":   "489.72199682","onOrders":"0.00000000","btcValue":"0.00010284"}
,"STR":{"available":"401975.32015855","onOrders":"0.00000000","btcValue":"2.78970872"}
,"XRP":{"available": "84190.25285054","onOrders":"0.00000000","btcValue":"2.70924233"}

command=returnTradeHistory&currencyPair=BTC_ETH

export DT=148325760000000
export DT=157245717300000

export DT=`date +%s00000`

export API_KEY=SQDA1ORM-ALCT0QSL-OXXJH7V6-ZTAFV1HD
export API_SECRET=2c5fbb9d848f325912ffd7f162f9a9769eba8842c9dd1959eeaca1e0d28fb829c7f3f9313cd1e2876d686dbb2b44b9ea17bd8554605e718a242b233b309c2fed

export API_SIGN=`echo -n "command=returnDepositAddresses&nonce=${DT}" | openssl sha512 -hmac $API_SECRET | cut -d' ' -f2`
curl -X POST          -d "command=returnDepositAddresses&nonce=${DT}" -H "Key: ${API_KEY}" -H "Sign: ${API_SIGN}" https://poloniex.com/tradingApi

{"BTC":"16zZow9oaCNZNuB82MEZgoXYvJY2zyNTMb",
 "ETC":"0xb188e96202ca874760b42802ca4470775e72277c",
 "ETH":"0xda4778c9422a0252d837f69d3aef3bd497767569",
  "SC":"fedb235a0bc963023399311dc9801d2406771c88ce92361620f522198de16925113fdca3a731",
 "STR":"3803771",
"USDT":"1MiuoApfv8KcH7TLmfdrdbdjrj33tSS6He",
 "ZEC":"t1QWpTb6o146hTVjZYa6WE2evqiuhR43TrM"}

export API_SIGN=`echo -n "command=returnTradeHistory&currencyPair=BTC_ETH&nonce=${DT}" | openssl sha512 -hmac $API_SECRET | cut -d' ' -f2`
curl -X POST          -d "command=returnTradeHistory&currencyPair=BTC_ETH&nonce=${DT}" -H "Key: ${API_KEY}" -H "Sign: ${API_SIGN}" https://poloniex.com/tradingApi

export DT=`date +%s00000`
export DTS=` mysql --raw -e "select unix_timestamp('2017-01-01');" | tail -1`00000
export DTE=${DT}

export API_SIGN=`echo -n "command=returnDepositsWithdrawals&start=${DTS}&end=${DTE}&nonce=${DT}" | openssl sha512 -hmac $API_SECRET | cut -d' ' -f2`
curl -X POST          -d "command=returnDepositsWithdrawals&start=${DTS}&end=${DTE}&nonce=${DT}" -H "Key: ${API_KEY}" -H "Sign: ${API_SIGN}" https://poloniex.com/tradingApi

