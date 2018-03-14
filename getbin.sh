#!/bin/bash
read APIKEY APISECRET <<< $(cat apibinance | cut -f2 -d " "); 
RECVWINDOW=50000
RECVWINDOW="recvWindow=$RECVWINDOW"
TIMESTAMP="timestamp=$(( $(date +%s) *1000))"
QUERYSTRING="$RECVWINDOW&$TIMESTAMP"

SIGNATURE=$(echo -n "$QUERYSTRING" | openssl dgst -sha256 -hmac $APISECRET | cut -c 10-)
SIGNATURE="signature=$SIGNATURE"

curl -s -H "X-MBX-APIKEY: $APIKEY" "https://api.binance.com/api/v3/account?$RECVWINDOW&$TIMESTAMP&$SIGNATURE" | jq '.'
echo

