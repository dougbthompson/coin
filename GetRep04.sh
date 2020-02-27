#!/bin/bash

cd /opt/coins/coinmarketcap

export DT=`date "+%Y-%m-%d-%H-%M"`
export YR=`date "+%Y"`
export MO=`date "+%m"`

export FILE="${YR}rep04/${MO}/rpt.${DT}.txt"

cat rep04.sql | mysql --table coins > ${FILE}

