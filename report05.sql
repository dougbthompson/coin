
insert into cmc_pc_avg 
select cmc_coin_id, year(last_actual_dt) as Year, week(last_actual_dt) as Week, hour(last_actual_dt) as Hour,
       round(avg(pc_1h),2) as PC01H, round(avg(pc_24h),2) as PC24H, round(avg(pc_7d),2) as PC07D
  from cmc_data
 where last_actual_dt is not null
 group by 1, 2, 3, 4;

Query OK, 67104 rows affected (5.32 sec)
Records: 67104  Duplicates: 0  Warnings: 0

CREATE TABLE cmc_pc_avg (
  cmc_coin_id  int(11) NOT NULL,
  cmc_year     int(11) NOT NULL,
  cmc_week     int(11) NOT NULL,
  cmc_hour     int(11) NOT NULL,
  cmc_pc01h    double DEFAULT NULL,
  cmc_pc24h    double DEFAULT NULL,
  cmc_pc07d    double DEFAULT NULL,
  PRIMARY KEY (`cmc_coin_id`,`cmc_year`,`cmc_week`,`cmc_hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

select a.cmc_coin_id, a.cmc_year, a.cmc_week, round(avg(a.cmc_pc01h),2) as PC01H, round(avg(a.cmc_pc24h),2) as PC24H, (select b.cmc_name from cmc_coin b where b.cmc_co
in_id = a.cmc_coin_id) as Name from cmc_pc_avg a where a.cmc_week = 3 group by 1,2,3 order by 5 desc limit 32;

# Run: 2017-01-24 14:00

select a.cmc_coin_id, a.cmc_year, a.cmc_week, round(avg(a.cmc_pc01h),2) as PC01H, round(avg(a.cmc_pc24h),2) as PC24H,
       round(avg(a.cmc_pc07d),2) as PC07D,
       (select b.cmc_name from cmc_coin b where b.cmc_coin_id = a.cmc_coin_id) as Name
  from cmc_pc_avg a
 where a.cmc_week = 3
 group by 1,2,3
 order by 6 desc
 limit 32;

+-------------+----------+----------+-------+--------+---------+--------------------+
| cmc_coin_id | cmc_year | cmc_week | PC01H | PC24H  | PC07D   | Name               |
+-------------+----------+----------+-------+--------+---------+--------------------+
|        1225 |     2018 |        3 | -1.27 | -24.96 | 1586.69 | Safe Trade Coin    |
|         115 |     2018 |        3 |  0.10 |  12.27 | 1020.59 | First Bitcoin      |
|         328 |     2018 |        3 |  8.17 |  93.94 |  394.44 | GBCGoldCoin        |
|        1368 |     2018 |        3 |  0.25 |   5.23 |  381.98 | Tychocoin          |
|         665 |     2018 |        3 |  4.27 | 191.62 |  334.91 | Sojourn            |
|         961 |     2018 |        3 |  0.05 |   2.55 |  266.78 | eBitcoin           |
|         375 |     2018 |        3 | -0.60 | -13.16 |  253.74 | HelloGold          |
|         183 |     2018 |        3 |  0.48 |  10.71 |  242.93 | Cindicator         |
|         425 |     2018 |        3 |  0.08 |   9.13 |  221.87 | Kubera Coin        |
|         917 |     2018 |        3 | -0.09 |   1.24 |  214.75 | CryptoEscudo       |
|          14 |     2018 |        3 |  2.00 |  56.23 |  158.85 | Cryptojacks        |
|         894 |     2018 |        3 |  0.24 |  11.30 |  142.56 | BoostCoin          |
|         299 |     2018 |        3 | -0.05 |  -0.01 |  132.02 | Faceblock          |
|        1337 |     2018 |        3 |  2.21 | 110.87 |  123.96 | Pirate Blocks      |
|        1212 |     2018 |        3 |  3.81 |  76.97 |  119.53 | Wink               |
|         948 |     2018 |        3 | -0.14 |  -0.03 |  115.10 | DIBCOIN            |
|         943 |     2018 |        3 |  0.01 |  -0.31 |  112.13 | DeltaCredits       |
|        1081 |     2018 |        3 |  1.53 |  39.66 |   99.07 | Newbium            |
|        1090 |     2018 |        3 |  0.57 |   6.36 |   98.72 | NVO                |
|         650 |     2018 |        3 | -0.31 |  -4.49 |   90.65 | SHACoin            |
|        1359 |     2018 |        3 | -0.11 |   5.24 |   89.80 | TeslaCoilCoin      |
|         759 |     2018 |        3 |  6.47 |  22.51 |   89.18 | Virtacoin          |
|        1095 |     2018 |        3 |  0.23 |  -2.87 |   87.81 | Opescoin           |
|        1167 |     2018 |        3 |  9.27 |  43.78 |   87.75 | STEX               |
|         339 |     2018 |        3 |  3.94 |  17.44 |   85.63 | Global Jobcoin     |
|         653 |     2018 |        3 |  0.65 |   7.14 |   80.82 | Skeincoin          |
|         230 |     2018 |        3 |  1.25 |   1.74 |   79.85 | Digital Money Bits |
|        1222 |     2018 |        3 |  2.63 |  54.23 |   79.24 | Xios               |
|         670 |     2018 |        3 |  0.66 |  19.80 |   78.04 | SIRIN LABS Token   |
|        1389 |     2018 |        3 |  4.32 |  21.56 |   77.46 | CCMiner            |
|         541 |     2018 |        3 |  0.89 |  14.93 |   74.30 | OP Coin            |
|         857 |     2018 |        3 |  1.40 |   1.66 |   73.04 | Asiadigicoin       |
+-------------+----------+----------+-------+--------+---------+--------------------+

