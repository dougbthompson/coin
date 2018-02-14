
--
-- report on "beta", correlation with bitcoin, ethereum, top 100 marketcap coins

-- created 2018-01-26 11:00
-- create table cmc_baseline (
--     cmc_coin_id  integer,  -- bitcoin, ethereum, dbt100
--     cmc_run_dt   datetime,
--     cmc_run_lst  integer,
--     delta        json,     -- {"H01":"-1.27","H04":"-2.46","H08":"1.01","H16":"4.35","H32":"8.27"}
--     index ix01_cmc_baseline (cmc_coin_id, cmc_run_lst)
-- ) engine = innodb;

-- create table cmc_beta (
--     cmc_coin_id  integer,
--     cmc_
-- ) engine = innodb;

-- create table cmc_dbt (
--  dbt_actual_dt datetime not     null,
--  dbt_100       double   default null,
--  dbt_200       double   default null,
--  primary key (dbt_actual_dt)
-- ) engine = innodb;

-- create table cmc_hours (xhours int, primary key (xhours)) engine = innodb;

drop procedure if exists report06;
delimiter //
create procedure report06()
begin

    -- determine start of time periods, not currently used
    select cast(unix_timestamp(min(last_actual_dt)) as unsigned), 
           cast(unix_timestamp(max(last_actual_dt)) as unsigned)
      into @first_time_period, @max_time_period
      from cmc_data
     where cmc_coin_id = (
           select cmc_coin_id
             from cmc_coin
             where cmc_symbol = 'BTC');

    -- resave the list of "look back" hours to calculate
    replace into cmc_hours values (1),(2),(4),(8),(16),(32),(64),(128),(256),(512);

    -- what is the last actual timestamp value?
    select max(actual_ts) into @max_actual_ts from cmc_time;

    -- list of available time periods
    replace into cmc_time
    select last_actual_ts, last_actual_dt
      from cmc_data
     where last_actual_ts > @max_actual_ts
       and cmc_coin_id = (select cmc_coin_id from cmc_coin where cmc_symbol = 'BTC')
     order by last_actual_ts;

    -- save off dbt100, dbt200 index values for all time periods
    replace into cmc_dbt
    select z.actual_ts, z.actual_dt,
           round((
            select sum(a.price_usd * a.volume_usd_24h) / (1000.0 * 1000.0 * 1000.0)
              from cmc_data a
             where a.rank < 101 and a.last_actual_dt = z.actual_dt),2),
           round((
            select sum(b.price_usd * b.volume_usd_24h) / (1000.0 * 1000.0 * 1000.0)
              from cmc_data b
             where b.rank < 201 and b.last_actual_dt = z.actual_dt),2)
      from cmc_time z order by z.actual_ts;

    -- calculate volume averages per day for BTC and the dbt100, dbt200 index values
    select a.last_actual_ts,
           round(sum(a.volume_usd_24h/1000000.0),2) as TradeB,
           round(avg(a.pc_1h),2)  as PC01H,
           round(avg(a.pc_24h),2) as PC24H,
           round(avg(a.pc_7d),2)  as PC07D
      from cmc_data a, cmc_time b
     where a.last_actual_ts  = b.actual_lst
       and a.rank           <= 100
     group by a.last_actual_ts;

    -- calculate for each coin values for the "back" time periods being monitored
    -- 

    -- test case using BTC for log back logic, selecting differences based on the
    -- (current) time back hour time periods
    -- cmc_time where actual_dt >= '2018-02-01' and actual_dt < '218-02-02'

--  select '2018-02-01 00:00:00' into @actual_dt;
    select a.last_actual_dt, a.cmc_coin_id, round(a.price_usd,2) as price_usd, b.xhours,
           ifnull(round
           (
            (
             (ifnull(a.price_usd,1) -
              (select ifnull(z.price_usd,0)
                 from cmc_data z
                where z.last_actual_ts = (a.last_actual_ts - (b.xhours * 3600)) and z.cmc_coin_id = 146)
             ) * 100.0
            ) / ifnull(a.price_usd,1),2
           ),0) as Value
      from cmc_data a, cmc_hours b, cmc_time c
     where a.cmc_coin_id    = 146
       and a.last_actual_dt = c.actual_dt;
--     and c.actual_dt >= '2018-02-01 00:00:00' and c.actual_dt < '2018-02-01 06:00:00';
--     and a.last_actual_dt = @actual_dt;

    --
    select a.last_actual_ts,
           json_object('VOLUME', round(sum(a.volume_usd_24h/1000000.0),2), 'PC01H', round(avg(pc_1h),2)) as json_value
      from cmc_data a, cmc_time b
     where a.last_actual_ts  = b.actual_lst
       and a.rank           <= 100
     group by a.last_actual_ts
     limit 8;

    select cmc_coin_id into @dbt100 from cmc_coin where cmc_symbol = 'DBT100';
    select cmc_coin_id into @dbt200 from cmc_coin where cmc_symbol = 'DBT200';

    # cmc_correlation_hour.nhour

    truncate table js4;
    insert into js4 (actual_ts, x)
    select z.last_actual_ts, cast(z.json_value as json)
      from (
        select a.last_actual_ts,
               json_object('_VOLUME', round(sum(a.volume_usd_24h/1000000.0),2),
                           'PC01H', round(avg(pc_1h),2), 'PC24H', round(avg(pc_24h),2), 'PC07D', round(avg(pc_7d),2)
               ) as json_value
          from cmc_data a, cmc_time b
         where a.last_actual_ts  = b.actual_ts
           and a.rank           <= 100
         group by a.last_actual_ts) as z
     limit 16;

end
//
delimiter ;

-- one day average for BTC = 146
select round(sum(volume_usd_24h/1000000.0),2) as TradeM,
       round(avg(pc_1h),2)  as PC01H,
       round(avg(pc_24h),2) as PC24H,
       round(avg(pc_7d),2)  as PC07D,
       sum(rank)
  from cmc_data
 where last_actual_dt >= '2018-01-16 14:15:00'
   and last_actual_dt  < '2018-01-17 14:15:00'
   and cmc_coin_id     = 146;

insert into xjson(x)
values ('{"D001H":"1", "D004H":"4", "D008H":"8", "D016H":"16", "D032H":"32",
          "D064H":"64", "D128H":"128", "D256H":"256", "D512H":"512"}');

select '2018-02-01 00:00:00' into @actual_dt;
select a.last_actual_dt, a.price_usd, b.xhours,
       ifnull(round
       (
        (
         (ifnull(a.price_usd,1) -
          (select ifnull(z.price_usd,0)
             from cmc_data z
            where z.last_actual_ts = (a.last_actual_ts - (b.xhours * 3600)) and z.cmc_coin_id = 146)
         ) * 100.0
        ) / ifnull(a.price_usd,1),2
       ),0) as Value
  from cmc_data a, cmc_hours b
 where a.cmc_coin_id    = 146
   and a.last_actual_dt = @actual_dt;



select '2018-01-16 00:00:00' into @actual_dt;
select a.last_actual_dt,
       round(a.price_usd,4) as USD_CUR,

       -- 4 hour value, difference and percent
       round((
       select b.price_usd
         from cmc_data b 
        where b.last_actual_ts = (a.last_actual_ts - (4 * 3600))
          and b.cmc_coin_id    = 146),3) as USD_D04H_PAST,
       -- 4 hour difference
       round(a.price_usd - (
       select b.price_usd 
         from cmc_data b 
        where b.last_actual_ts = (a.last_actual_ts - (4 * 3600))
          and b.cmc_coin_id    = 146),3) as D04H_DIFF,
       -- 4 hour percent
       round(((a.price_usd - (
              select b.price_usd
                from cmc_data b
               where b.last_actual_ts = (a.last_actual_ts - (4 * 3600))
                 and b.cmc_coin_id    = 146))*100.0)/a.price_usd,3) as D04H_PERC
  from cmc_data a
 where a.cmc_coin_id    = 146
   and a.last_actual_dt = @actual_dt;


select '2018-02-01 00:00:00' into @actual_dt;
select sum(a.price_usd * a.volume_usd_24h) / (1000.0 * 1000.0 * 1000.0) as DBT100
  from cmc_data a
 where a.rank           < 101
   and a.last_actual_dt = @actual_dt;

+--------------------+
| DBT100             |
+--------------------+
| 184012.29455430064 |
+--------------------+


mysql> select * from cmc_data where cmc_coin_id = 146 limit 16;
+-------------+-------------+--------------+---------------------+----------------+------------------+-------+--------+--------+-----------+-----------+------+
| cmc_data_id | cmc_coin_id | last_updated | last_actual_dt      | last_actual_ts | volume_usd_24h   | pc_1h | pc_24h | pc_7d  | price_usd | price_btc | rank |
+-------------+-------------+--------------+---------------------+----------------+------------------+-------+--------+--------+-----------+-----------+------+
|      147595 |         146 |   1516061362 | 2018-01-15 16:15:00 |     1516061700 | 12737900000.0000 | -1.57 |   0.35 |  -9.24 |   13843.1 |         1 |    1 |
|      147585 |         146 |   1516062262 | 2018-01-15 16:30:00 |     1516062600 | 12555300000.0000 | -2.27 |   -1.1 | -10.44 |   13661.5 |         1 |    1 |
|      147593 |         146 |   1516063463 | 2018-01-15 16:45:00 |     1516063500 | 12472900000.0000 | -2.63 |  -2.38 | -11.48 |   13501.7 |         1 |    1 |
|      147571 |         146 |   1516064063 | 2018-01-15 17:00:00 |     1516064400 | 12672600000.0000 | -2.47 |   -2.3 | -11.42 |   13511.4 |         1 |    1 |
|      147576 |         146 |   1516064963 | 2018-01-15 17:15:00 |     1516065300 | 12629400000.0000 | -2.24 |  -2.42 |  -11.6 |   13483.4 |         1 |    1 |
|      147596 |         146 |   1516065862 | 2018-01-15 17:30:00 |     1516066200 | 12847900000.0000 | -1.08 |  -1.68 |    -11 |     13576 |         1 |    1 |
|      147589 |         146 |   1516066763 | 2018-01-15 17:45:00 |     1516067100 | 12601700000.0000 |  -1.6 |  -3.41 | -12.57 |   13335.7 |         1 |    1 |
|      147654 |         146 |   1516067662 | 2018-01-15 18:00:00 |     1516068000 | 12807600000.0000 | -2.49 |  -4.35 | -13.49 |   13195.8 |         1 |    1 |
|      147583 |         146 |   1516068563 | 2018-01-15 18:15:00 |     1516068900 | 12903200000.0000 | -1.77 |  -3.62 | -12.89 |     13289 |         1 |    1 |
|      147591 |         146 |   1516069463 | 2018-01-15 18:30:00 |     1516069800 | 12853000000.0000 | -2.05 |  -4.08 | -13.41 |   13212.1 |         1 |    1 |
|      147584 |         146 |   1516070362 | 2018-01-15 18:45:00 |     1516070700 | 13014200000.0000 | -0.83 |  -3.63 | -13.09 |   13263.8 |         1 |    1 |
|      147575 |         146 |   1516071261 | 2018-01-15 19:00:00 |     1516071600 | 13076000000.0000 |  0.18 |  -3.49 | -13.09 |   13269.8 |         1 |    1 |
|      147572 |         146 |   1516072162 | 2018-01-15 19:15:00 |     1516072500 | 13313700000.0000 |  1.01 |  -2.55 | -12.32 |     13390 |         1 |    1 |
|      147587 |         146 |   1516073063 | 2018-01-15 19:30:00 |     1516073400 | 13338200000.0000 |  0.86 |  -2.77 | -12.56 |   13353.2 |         1 |    1 |
|      147579 |         146 |   1516073963 | 2018-01-15 19:45:00 |     1516074300 | 13228800000.0000 | -0.23 |  -3.79 | -13.53 |   13205.8 |         1 |    1 |
|      147592 |         146 |   1516074863 | 2018-01-15 20:00:00 |     1516075200 | 13210600000.0000 | -0.97 |  -3.99 |  -13.7 |   13179.7 |         1 |    1 |
+-------------+-------------+--------------+---------------------+----------------+------------------+-------+--------+--------+-----------+-----------+------+
16 rows in set (0.00 sec)

