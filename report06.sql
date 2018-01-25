
--
-- report on "beta" with bitcoin, ethereum, top 100 marketcap coins
--

create table cmc_baseline (
    cmc_coin_id  integer,  -- bitcoin, ethereum, dbt100
    cmc_run_dt   datetime,
    cmc_run_lst  integer,
    delta        json,     -- {"H01":"-1.27","H04":"-2.46","H08":"1.01","H16":"4.35","H32":"8.27"}
    index ix01_cmc_baseline (cmc_coin_id, cmc_run_lst)
) engine = innodb;

create table cmc_beta (
    cmc_coin_id   integer,
    cmc_
) engine = innodb;


select round(sum(volume_usd_24h/1000000.0),2) as TradeB,
       round(avg(pc_1h),2)  as PC01H,
       round(avg(pc_24h),2) as PC24H,
       round(avg(pc_7d),2)  as PC07D
  from cmc_data
 where last_actual_dt  = '2018-01-16 14:15:00'
   and rank           <= 100;

select round(sum(volume_usd_24h/1000000.0),2) as TradeB,
       round(avg(pc_1h),2)  as PC01H,
       round(avg(pc_24h),2) as PC24H,
       round(avg(pc_7d),2)  as PC07D, sum(rank)
  from cmc_data
 where last_actual_dt >= '2018-01-16 14:15:00'
   and last_actual_dt  < '2018-01-17 14:15:00'
   and cmc_coin_id     = 146;

