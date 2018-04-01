#!/bin/bash

cd /opt/coins/coinmarketcap

export DT=`date "+%Y-%m-%d-%H-%M"`

export FILE="2018rep05/rpt.${DT}.txt"

cat rep05.sql | mysql --table coins > ${FILE}

