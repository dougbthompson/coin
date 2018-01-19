
drop procedure if exists report02;
delimiter //
create procedure report02(in zhours int)
begin
    declare last_date   datetime;

    select 19540.74618207 into @num_drgn;
    select max(lst) into last_date from pol;

    select cast(json_unquote(x->'$.STR') as decimal(18,8)) into @num_xlm from pol where lst = last_date;
    select cast(json_unquote(x->'$.XRP') as decimal(18,8)) into @num_xrp from pol where lst = last_date;
    select cast(json_unquote(x->'$.NXT') as decimal(18,8)) into @num_nxt from pol where lst = last_date;
    select cast(json_unquote(x->'$.ETH') as decimal(18,8)) into @num_eth from pol where lst = last_date;
    select cast(json_unquote(x->'$.SC')  as decimal(18,8)) into @num_sc  from pol where lst = last_date;
    select cast(json_unquote(x->'$.BCH') as decimal(14,8)) into @num_bch from pol where lst = last_date;
    select cast(json_unquote(x->'$.BTC') as decimal(18,8)) into @num_btc from pol where lst = last_date;

    drop temporary table if exists cmc_tmp_values;
    create temporary table cmc_tmp_values
    select json_unquote(x->'$.BTC.date_actual') as 'Date Time',
           round(json_unquote(x->'$.DRGN.price_usd'),4) as 'Dragon___',
           round((cast(json_unquote(x->'$.DRGN.price_usd') as decimal(18,8)) * @num_drgn),2) as DTotal,

           round(json_unquote(x->'$.XLM.price_usd'),4)  as 'Stellar__',
           round(json_unquote(x->'$.XRP.price_usd'),4)  as 'Ripple___',
           round(json_unquote(x->'$.NXT.price_usd'),4)  as 'Next_____',
           round(json_unquote(x->'$.ETH.price_usd'),4)  as 'Ethereum_',
           round(json_unquote(x->'$.SC.price_usd'), 4)  as 'Siacoin__',
           round(json_unquote(x->'$.BCH.price_usd'),4)  as 'Bit Cash_',
           round(json_unquote(x->'$.BTC.price_usd'),4)  as 'Bitcoin__',

           round(
           (cast(json_unquote(x->'$.XLM.price_usd')  as decimal(18,8)) * @num_xlm) +
           (cast(json_unquote(x->'$.XRP.price_usd')  as decimal(18,8)) * @num_xrp) +
           (cast(json_unquote(x->'$.NXT.price_usd')  as decimal(18,8)) * @num_nxt) +
           (cast(json_unquote(x->'$.ETH.price_usd')  as decimal(18,8)) * @num_eth) +
           (cast(json_unquote(x->'$.SC.price_usd')   as decimal(18,8)) * @num_sc)  +
           (cast(json_unquote(x->'$.BCH.price_usd')  as decimal(18,8)) * @num_bch),2) as CTotal,
           cast(0.0 as decimal(18,2)) as ZTotal
      from cmc
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

    update cmc_tmp_values
       set ZTotal = DTotal + CTotal;

    select * from cmc_tmp_values;

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

    call proc_store1('DRGN', @start_date, @curr_datetime, @num_drgn);
    call proc_store1('XLM',  @start_date, @curr_datetime, @num_xlm);
    call proc_store1('XRP',  @start_date, @curr_datetime, @num_xrp);  
    call proc_store1('NXT',  @start_date, @curr_datetime, @num_nxt);
    call proc_store1('SC',   @start_date, @curr_datetime, @num_sc);
    call proc_store1('ETH',  @start_date, @curr_datetime, @num_eth);
    call proc_store1('BCH',  @start_date, @curr_datetime, @num_bch);
    call proc_store1('BTC',  @start_date, @curr_datetime, @num_btc);

    update cmc_tmp_min_max
       set curr_tot = coins * xusd,
           diff_tot = coins * xdif;

    select * from cmc_tmp_min_max order by curr_tot desc;
    select sum(coins), sum(diff_tot), sum(curr_tot) from cmc_tmp_min_max;

end
//
delimiter ;

