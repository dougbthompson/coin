
--
-- report04: selection criteria reports
-- candidate coin report
--
-- let us use ETH as a sample coin, for testing purposes
-- 

drop procedure if exists report04;
delimiter //
create procedure report04(in volume_usd_24h double precision, in volumn_ratio double precision)
begin

    create temporary table tmp1
    select a.cmc_coin_id, max(a.last_actual_dt) as last_actual_dt
      from cmc_data a group by 1; 

    select a.cmc_coin_id as ID,
           (select c.cmc_symbol from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as Symbol,
           (select c.cmc_name from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as CoinName,
           round(a.pc_1h,2) as H1, round(a.pc_24h,2) as H24, round(a.pc_7d,2) as D7,
           round(a.volume_usd_24h,0) as VOL, round(a.price_btc,8) as PBTC, round(a.price_usd,6) as PUSD,
           round((50.0 / a.price_usd), 0) as 50AMT_K,
           round((50000.0 / a.price_usd)/a.volume_usd_24h,2) as VOLRatio
      from cmc_data a, tmp1 b
     where a.last_actual_dt = b.last_actual_dt
       and a.cmc_coin_id    = b.cmc_coin_id
       and a.price_usd      > 0.0
       and a.volume_usd_24h > 10000.0
     order by a.pc_24h desc
     limit 32;

    create temporary table tmp2
    select a.cmc_coin_id as ID,
           (select c.cmc_symbol from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as Symbol,
           (select c.cmc_name from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as CoinName,
           round(a.pc_1h,2) as H1, round(a.pc_24h,2) as H24, round(a.pc_7d,2) as D7,
           round(a.volume_usd_24h,0) as VOL, round(a.price_btc,8) as PBTC, round(a.price_usd,6) as PUSD,
           round((50.0 / a.price_usd), 0) as 50AMT_K,
           round((50000.0 / a.price_usd)/a.volume_usd_24h,2) as VOLRatio
      from cmc_data a, tmp1 b
     where a.last_actual_dt = b.last_actual_dt
       and a.cmc_coin_id    = b.cmc_coin_id
       and a.price_usd      > 0.0
       and a.volume_usd_24h > 10000.0
     order by a.pc_24h desc
     limit 128;

    select * from tmp2 order by VOL desc limit 32;

    select a.cmc_coin_id as ID,
           (select c.cmc_symbol from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as Symbol,
           (select c.cmc_name from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as CoinName,
           round(a.pc_1h,2) as H1, round(a.pc_24h,2) as H24, round(a.pc_7d,2) as D7,
           round(a.volume_usd_24h,0) as VOL, round(a.price_btc,8) as PBTC, round(a.price_usd,6) as PUSD,
           round((50.0 / a.price_usd), 0) as 50AMT_K,
           round((50000.0 / a.price_usd)/a.volume_usd_24h,2) as VOLRatio
      from cmc_data a, tmp1 b
     where a.last_actual_dt = b.last_actual_dt
       and a.cmc_coin_id    = b.cmc_coin_id
       and a.price_usd      > 0.0
       and a.volume_usd_24h > 100000.0
     order by a.pc_24h desc
     limit 32;

    create temporary table tmp3
    select a.cmc_coin_id as ID,
           (select c.cmc_symbol from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as Symbol,
           (select c.cmc_name from cmc_coin c where c.cmc_coin_id = a.cmc_coin_id) as CoinName,
           round(a.pc_1h,2) as H1, round(a.pc_24h,2) as H24, round(a.pc_7d,2) as D7,
           round(a.volume_usd_24h,0) as VOL, round(a.price_btc,8) as PBTC, round(a.price_usd,6) as PUSD,
           round((50.0 / a.price_usd), 0) as 50AMT_K,
           round((50000.0 / a.price_usd)/a.volume_usd_24h,2) as VOLRatio
      from cmc_data a, tmp1 b
     where a.last_actual_dt = b.last_actual_dt
       and a.cmc_coin_id    = b.cmc_coin_id
       and a.price_usd      > 0.0010
       and a.volume_usd_24h > 10000.0
       and a.pc_7d          > 0.0
     order by a.pc_24h desc
     limit 128;

    select ID as 'ID___',
           Symbol as 'Symbol_',
           CoinName 'CoinName____________________',
           H1 as 'H1____',
           H24 as 'H24___',
           D7 as 'D7_____',
           VOL as 'VOL_______',
           PBTC as 'PBTC_______',
           PUSD as 'PUSD_______',
           50AMT_K as '50AMT_K_',
           VOLRatio as 'VOLRatio___'
    from tmp3 order by PUSD limit 32;

    select * from tmp3 order by PUSD limit 32;
    select * from tmp3 where VOLRatio < 12.0 order by PUSD limit 32;

end
//
delimiter ;
