
-- 
-- echo -ne "\e[1;32;44m Hello, World! \e[m \n"
-- 

drop procedure if exists report02;
delimiter //
create procedure report02(in zhours int)
begin
    declare last_date   datetime;

    select 19540.74618207  into @num_drgn;
    select 527739.970      into @num_trx;
    select 411235.353      into @num_poe;
    select 113036.850      into @num_ncash;

    select max(lst) into last_date from pol;

    select cast(json_unquote(x->'$.STR') as decimal(18,8)) into @num_xlm from pol where lst = last_date;
    select cast(json_unquote(x->'$.XRP') as decimal(18,8)) into @num_xrp from pol where lst = last_date;
    select cast(json_unquote(x->'$.ETH') as decimal(18,8)) into @num_eth from pol where lst = last_date;
    select cast(json_unquote(x->'$.BTC') as decimal(18,8)) into @num_btc from pol where lst = last_date;

    drop table if exists cmc_tmp_values;
    create table cmc_tmp_values
    select json_unquote(x->'$.BTC.date_actual') as 'Date Time',
           round(json_unquote(x->'$.DRGN.price_usd'),3) as 'Dragon',
           round((cast(json_unquote(x->'$.DRGN.price_usd') as decimal(18,8)) * @num_drgn),2) as DTotal,

           round(json_unquote(x->'$.TRX.price_usd'),4)   as 'Tron___', 
           round(json_unquote(x->'$.POE.price_usd'),4)   as 'Poe____',
           round(json_unquote(x->'$.NCASH.price_usd'),4) as 'NCash__',
           round(json_unquote(x->'$.XLM.price_usd'),4)   as 'Stellar',
           round(json_unquote(x->'$.XRP.price_usd'),4)   as 'Ripple_',
           round(json_unquote(x->'$.ETH.price_usd'),3)   as 'Eth_____',
           round(json_unquote(x->'$.BTC.price_usd'),3)   as 'Bitcoin__',

           round(
           (cast(json_unquote(x->'$.XLM.price_usd')   as decimal(18,8)) * @num_xlm) +
           (cast(json_unquote(x->'$.TRX.price_usd')   as decimal(18,8)) * @num_trx) +
           (cast(json_unquote(x->'$.POE.price_usd')   as decimal(18,8)) * @num_poe) +
           (cast(json_unquote(x->'$.NCASH.price_usd') as decimal(18,8)) * @num_ncash) +
           (cast(json_unquote(x->'$.XRP.price_usd')   as decimal(18,8)) * @num_xrp) +
           (cast(json_unquote(x->'$.ETH.price_usd')   as decimal(18,8)) * @num_eth) +
           0,2) as CTotal,
           cast(0.0 as decimal(18,2)) as ZTotal
      from cmc
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

    update cmc_tmp_values
       set ZTotal = DTotal + CTotal;

    # main display statement
    select 10.0 / (max(ztotal) - min(ztotal)) into @minmax_diff from cmc_tmp_values;

    # 1 ---> top display (last 24 hours, 100 records, display last 36
    select min(ztotal) into @min_ztotal from cmc_tmp_values;
    select a.*,
           substring('**********', 1, round((a.ztotal - @min_ztotal) * @minmax_diff,0)) as 'Wave______'
      from cmc_tmp_values a
     order by 1 desc limit 36;

    drop temporary table if exists cmc_tmp_min_max;
    create temporary table cmc_tmp_min_max (
      idx       int auto_increment primary key,
      symbol    varchar(16)    null,
      name      varchar(16)    null,
      coins     decimal(18,8)  null,
      xmin      decimal(18,8)  null,
      xmax      decimal(18,8)  null,
      xdif      decimal(18,8)  null,
      diff_tot  decimal(18,8)  null,
      xusd      decimal(18,8)  null,
      curr_tot  decimal(18,8)  null);

    select unix_timestamp(json_unquote(x->'$.BTC.date_actual')) into @start_date
      from cmc
     where unix_timestamp(json_unquote(x->'$.BTC.date_actual')) > (unix_timestamp(now()) - (3600 * zhours))
     order by unix_timestamp(json_unquote(x->'$.BTC.date_actual'))
     limit 1;

    select max(json_unquote(x->'$.BTC.date_actual')) into @curr_datetime from cmc limit 1;

    call proc_store1('DRGN',  @start_date, @curr_datetime, @num_drgn);
    call proc_store1('TRX',   @start_date, @curr_datetime, @num_trx);
    call proc_store1('POE',   @start_date, @curr_datetime, @num_poe);
    call proc_store1('NCASH', @start_date, @curr_datetime, @num_ncash);
    call proc_store1('XLM',   @start_date, @curr_datetime, @num_xlm);
    call proc_store1('XRP',   @start_date, @curr_datetime, @num_xrp);  
    call proc_store1('ETH',   @start_date, @curr_datetime, @num_eth);
    call proc_store1('BTC',   @start_date, @curr_datetime, @num_btc);

    update cmc_tmp_min_max
       set curr_tot = coins * xusd,
           diff_tot = coins * xdif;

    select * from cmc_tmp_min_max order by curr_tot desc;
    select round(sum(coins),4) as TotalCoins, round(sum(diff_tot),4) as DiffTotal,
           round(sum(curr_tot),4) as TotalValue from cmc_tmp_min_max;

end
//
delimiter ;

--

--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
