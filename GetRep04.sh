#!/bin/bash

cd /opt/coins/coinmarketcap

export DT=`date "+%Y-%m-%d-%H-%M"`

export FILE="2018rep04/rpt.${DT}.txt"

cat rep04.sql | mysql --table coins > ${FILE}

