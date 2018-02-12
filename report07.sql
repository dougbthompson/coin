
-- 
-- 
-- 
-- Choe's list
-- 2018-02-04
-- 01 WTC  02 VEN  03 ENG  04 QSP  05 ICX  06 GTO  07 EOS  08 POE  09 ADA  10 XLM
-- 11 ZRX  12 NANO 13 IOTA 14 XVG  15 RDD  16 XRP  17 NEBL 18 TRX  19 XMR  20 BTS

drop procedure if exists report06;
delimiter //
create procedure report06()
begin

    create table if not exists cmc_choe_list (
        cmc_d       date,
        cmc_rank    integer,  -- 1:best, 2:good
        cmc_symbol  varchar(16),
        index ix01_cmc_choe_list (cmc_d, cmc_symbol)
    );
    insert into cmc_choe_list values
          ('2018-02-04',1, 'WTC'),('2018-02-04',1, 'VEN'),
          ('2018-02-04',1, 'ENG'),('2018-02-04',1, 'QSP'),('2018-02-04',1, 'ICX'),('2018-02-04',1, 'GTO'),
          ('2018-02-04',1, 'EOS'),('2018-02-04',1, 'POE'),('2018-02-04',1, 'ADA'),('2018-02-04',1, 'XLM'),
          ('2018-02-04',2, 'ZRX'),('2018-02-04',2,'NANO'),
          ('2018-02-04',2,'IOTA'),('2018-02-04',2, 'XVG'),('2018-02-04',2, 'RDD'),('2018-02-04',2, 'XRP'),
          ('2018-02-04',2,'NEBL'),('2018-02-04',2, 'TRX'),('2018-02-04',2, 'XMR'),('2018-02-04',2, 'BTS');

    select max(cmc_d) into @max_date from cmc_choe_list;

    select *
      from cmc_choe_list
     where cmc_dt = @max_date
     order by cmc_ramk, cmc_symbol;


    select c.cmc_symbol,
           a.last_actual_dt,
           round(a.pc_24h,2) as pc_24h,
           round(a.pc_7d,2) as pc_7d,
           round(a.price_usd, 8) as price_usd

      from cmc_data a, cmc_coin b, cmc_choe_list c
     where a.cmc_coin_id = b.cmc_coin_id
       and b.cmc_symbol  = c.cmc_symbol;


end
//
delimiter ;


------------------------------------------------------

    -- determine start of time periods
    select cast(unix_timestamp(min(last_actual_dt)) as unsigned), 
           cast(unix_timestamp(max(last_actual_dt)) as unsigned)
      into @first_time_period, @max_time_period
      from cmc_data
     where cmc_coin_id = (
           select cmc_coin_id
             from cmc_coin
             where cmc_symbol = 'BTC');

    -- list of available time periods
    drop temporary table if exists cmc_time;
    create temporary table cmc_time 
    select last_actual_dt,
           last_actual_ts,
           0 as cmc_coin_id,
           cast('{"":""}' as json) as x
      from cmc_data
     where cmc_coin_id = (
           select cmc_coin_id
             from cmc_coin
            where cmc_symbol = 'BTC')
      order by last_actual_dt;

    alter table cmc_time add index ix01_cmc_time (actual_lst, actual_dt);
    alter table cmc_time add index ix02_cmc_time (actual_dt, actual_lst);

    -- this needs to be against all time periods, stored in cmc_time?
    -- single time period averages for the top 100 values
    select a.last_actual_ts,
           round(sum(a.volume_usd_24h/1000000.0),2) as TradeB,
           round(avg(a.pc_1h),2)  as PC01H,
           round(avg(a.pc_24h),2) as PC24H,
           round(avg(a.pc_7d),2)  as PC07D
      from cmc_data a, cmc_time b
     where a.last_actual_ts  = b.actual_lst
       and a.rank           <= 100
     group by a.last_actual_ts;

    select a.last_actual_ts,
           json_object('VOLUME', round(sum(a.volume_usd_24h/1000000.0),2),
                       'PC01H', round(avg(pc_1h),2)
           ) as json_value
      from cmc_data a, cmc_time b
     where a.last_actual_ts  = b.actual_lst
       and a.rank           <= 100
     group by a.last_actual_ts
     limit 8;

    select cmc_coin_id into @dbt100 from cmc_coin where cmc_symbol = 'DBT100';

    # cmc_correlation_hour.nhour

    truncate table js4;
    insert into js4 (x)
    select z.last_actual_ts, cast(z.json_value as json)
      from (
        select a.last_actual_ts,
               json_object('_VOLUME', round(sum(a.volume_usd_24h/1000000.0),2),
                           'PC01H', round(avg(pc_1h),2)
               ) as json_value
          from cmc_data a, cmc_time b
         where a.last_actual_ts  = b.actual_lst
           and a.rank           <= 100
         group by a.last_actual_ts) as z

    -- this needs to be against all time periods, stored in cmc_time?
    -- calc DBT100 index value for last time target
    select sum(a.price_usd * a.volume_usd_24h) / (1000.0 * 1000.0 * 1000.0) as DBT100
      from cmc_data a
     where a.rank           <= 100
       and a.last_actual_ts  = @max_time_period;

end
//
delimiter ;

