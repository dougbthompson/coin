#!/bin/bash

# ./G.sh | tr '\n' ' ' | sed -f sed.sed > bcp
# $JSON = /opt/coins/coinmarketcap/cmc/2019_json/01/03/cmc.2019-01-03-09-58.json 
# $zDT  = 2019-01-03 09:58:00

cd /opt/coins/coinmarketcap

export FILE0=$1
export ZDATE=$2

export DYR=`echo $ZDATE | cut -d'-' -f1`
export DTM=`echo $ZDATE | cut -d'-' -f2`
export DTD=`echo $ZDATE | cut -d'-' -f3 | cut -d' ' -f1`

# correct FILE2
export FILE2a="cmc/${DYR}_bcp/${DTM}/${DTD}/cmc"
export FILE2b=`echo ${FILE0} | cut -d'.' -f2`
export FILE2="${FILE2a}.${FILE2b}.bcp"

cat ${FILE0} | tr '\n' ' ' | sed -f sed.sed > ${FILE2}

mysql coins -e "LOAD DATA local INFILE '${FILE2}' INTO TABLE cmc_api(x);"

exit

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 

create table cmc_api (
    x     json default null,
    lst   datetime   GENERATED ALWAYS AS (from_unixtime(json_unquote(json_extract(`x`,'$.BTC.last_updated')))) VIRTUAL,
    lstd  bigint(20) GENERATED ALWAYS AS (json_unquote(json_extract(`x`,'$.BTC.last_updated'))) VIRTUAL,

    index ix01_cmc_api (lst),
    index ix02_cmc_api (lstd)
) engine = innodb default charset utf8;

mysql> select x->'$.status.timestamp' from cmc_api;
+----------------------------+
| x->'$.status.timestamp'    |
+----------------------------+
| "2019-01-03T21:40:01.359Z" |
+----------------------------+
1 row in set (0.00 sec)

mysql> select json_unquote(x->'$.status.timestamp') from cmc_api;
+---------------------------------------+
| json_unquote(x->'$.status.timestamp') |
+---------------------------------------+
| 2019-01-03T21:40:01.359Z              |
| 2019-01-03T22:00:02.401Z              |
+---------------------------------------+
2 rows in set (0.00 sec)

mysql> select substring(json_unquote(x->'$.status.timestamp'),1,19) from cmc_api;
+-------------------------------------------------------+
| substring(json_unquote(x->'$.status.timestamp'),1,19) |
+-------------------------------------------------------+
| 2019-01-03T21:40:01                                   |
| 2019-01-03T22:00:02                                   |
+-------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> select str_to_date(substring(json_unquote(x->'$.status.timestamp'),1,19), '%Y-%m-%dT%H:%i:%s') from cmc_api;
+-----------------------------------------------------------------------------------------+
| str_to_date(substring(json_unquote(x->'$.status.timestamp'),1,19), '%Y-%m-%dT%H:%i:%s') |
+-----------------------------------------------------------------------------------------+
| 2019-01-03 21:40:01                                                                     |
| 2019-01-03 22:00:02                                                                     |
+-----------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> select unix_timestamp(str_to_date(substring(json_unquote(x->'$.status.timestamp'),1,19), '%Y-%m-%dT%H:%i:%s')) from cmc_api;
+---------------------------------------------------------------------------------------------------------+
| unix_timestamp(str_to_date(substring(json_unquote(x->'$.status.timestamp'),1,19), '%Y-%m-%dT%H:%i:%s')) |
+---------------------------------------------------------------------------------------------------------+
|                                                                                              1546580401 |
|                                                                                              1546581602 |
+---------------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

