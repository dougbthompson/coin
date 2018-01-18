
drop procedure if exists report02;
delimiter //
create procedure report02(in zhours int)
begin
    declare last_date datetime;
    declare num_drgn decimal(18,8);
    declare num_xlm  decimal(18.8);
    declare num_xrp  decimal(18.8);
    declare num_nxt  decimal(18.8);
    declare num_eth  decimal(18.8);
    declare num_sc   decimal(18.8);
    declare num_bch  decimal(18.8);
    declare num_btc  decimal(18.8);

    select 19540.0 into num_drgn;
    select max(lst) into last_date from pol;

    select cast(json_unquote(x->'$.STR') as decimal(18,8)) into num_xlm from pol where lst = last_date;
    select cast(json_unquote(x->'$.XRP') as decimal(18,8)) into num_xrp from pol where lst = last_date;
    select cast(json_unquote(x->'$.NXT') as decimal(18,8)) into num_nxt from pol where lst = last_date;
    select cast(json_unquote(x->'$.ETH') as decimal(18,8)) into num_eth from pol where lst = last_date;
    select cast(json_unquote(x->'$.SC')  as decimal(18,8)) into num_sc  from pol where lst = last_date;
    select cast(json_unquote(x->'$.BCH') as decimal(18,8)) into num_bch from pol where lst = last_date;
    select cast(json_unquote(x->'$.BTC') as decimal(18,8)) into num_btc from pol where lst = last_date;

    drop temporary table if exists cmc_tmp_values;
    create temporary table cmc_tmp_values
    select json_unquote(x->'$.BTC.date_actual') as 'Date Time',
           round(json_unquote(x->'$.DRGN.price_usd'),4) as 'Dragon___',
           round((cast(json_unquote(x->'$.DRGN.price_usd') as decimal(8,4)) * num_drgn),2) as DTotal,

           round(json_unquote(x->'$.XLM.price_usd'),4)  as 'Stellar__',
           round(json_unquote(x->'$.XRP.price_usd'),4)  as 'Ripple___',
           round(json_unquote(x->'$.NXT.price_usd'),4)  as 'Next_____',
           round(json_unquote(x->'$.ETH.price_usd'),4)  as 'Ethereum_',
           round(json_unquote(x->'$.SC.price_usd'),4)   as 'Siacoin__',
           round(json_unquote(x->'$.BCH.price_usd'),4)  as 'Bit Cash_',
           round(json_unquote(x->'$.BTC.price_usd'),4)  as 'Bitcoin__',

           round(
           (cast(json_unquote(x->'$.XLM.price_usd')  as decimal(8,4)) * num_xlm) +
           (cast(json_unquote(x->'$.XRP.price_usd')  as decimal(8,4)) * num_xrp) +
           (cast(json_unquote(x->'$.NXT.price_usd')  as decimal(8,4)) * num_nxt) +
           (cast(json_unquote(x->'$.ETH.price_usd')  as decimal(8,4)) * num_eth) +
           (cast(json_unquote(x->'$.SC.price_usd')   as decimal(8,4)) * num_sc)  +
           (cast(json_unquote(x->'$.BCH.price_usd')  as decimal(8,4)) * num_bch),2) as CTotal,
           cast(0.0 as decimal(18,2)) as ZTotal
      from cmc
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

    update cmc_tmp_values
       set ZTotal = DTotal + CTotal;

    select * from cmc_tmp_values;

    drop temporary table if exists cmc_tmp_min_max;
    create temporary table cmc_tmp_min_max (
      idx     int auto_increment primary key,
      symbol  varchar(16)   null,
      name    varchar(16)   null,
      xmin    decimal(8,4)  null,
      xmax    decimal(8,4)  null,
      xdif    decimal(8,4)  null);
    
    insert into cmc_tmp_min_max (symbol, name)
    select json_unquote(x->'$.DRGN.symbol'), json_unquote(x->'$.DRGN.name') from cmc limit 1;

    update cmc_tmp_min_max a, (
           select min(cast(json_unquote(b.x->'$.DRGN.price_usd') as decimal(8,4))) as xmin,
                  max(cast(json_unquote(b.x->'$.DRGN.price_usd') as decimal(8,4))) as xmax,
                  max(cast(json_unquote(b.x->'$.DRGN.price_usd') as decimal(8,4))) -
                  min(cast(json_unquote(b.x->'$.DRGN.price_usd') as decimal(8,4))) as xdif
             from cmc b
            where b.lst > from_unixtime((unix_timestamp(now()) - (3600 * 8)))) z
        set a.xmin = z.xmin, a.xmax = z.xmax, a.xdif = z.xdif
      where a.symbol = 'DRGN';

    select * from cmc_tmp_min_max order by symbol;

    drop temporary table if exists cmc_tmp_minmax;
    create temporary table cmc_tmp_minmax
    select min(cast(json_unquote(x->'$.DRGN.price_usd') as decimal(8,4))) as MN_DRGM, 
           max(cast(json_unquote(x->'$.DRGN.price_usd') as decimal(8,4))) as MX_DRGN, cast(0.0 as decimal(8,4)) as MM_DRGN,
           min(cast(json_unquote(x->'$.XLM.price_usd')  as decimal(8,4))) as MN_XLM,  
           max(cast(json_unquote(x->'$.XLM.price_usd')  as decimal(8,4))) as MX_XLM,  cast(0.0 as decimal(8,4)) as MM_XLM,
           min(cast(json_unquote(x->'$.XRP.price_usd')  as decimal(8,4))) as MN_XRP,  
           max(cast(json_unquote(x->'$.XRP.price_usd')  as decimal(8,4))) as MX_XRP,  cast(0.0 as decimal(8,4)) as MM_XRP,
           min(cast(json_unquote(x->'$.NXT.price_usd')  as decimal(8,4))) as MN_NXT,  
           max(cast(json_unquote(x->'$.NXT.price_usd')  as decimal(8,4))) as MX_NXT,  cast(0.0 as decimal(8,4)) as MM_NXT,
           min(cast(json_unquote(x->'$.ETH.price_usd')  as decimal(8,4))) as MN_ETH,  
           max(cast(json_unquote(x->'$.ETH.price_usd')  as decimal(8,4))) as MX_ETH,  cast(0.0 as decimal(8,4)) as MM_ETH,
           min(cast(json_unquote(x->'$.SC.price_usd')   as decimal(8,4))) as MN_SC,   
           max(cast(json_unquote(x->'$.SC.price_usd')   as decimal(8,4))) as MX_SC,   cast(0.0 as decimal(8,4)) as MM_SC,
           min(cast(json_unquote(x->'$.BCH.price_usd')  as decimal(8,4))) as MN_BCH,  
           max(cast(json_unquote(x->'$.BCH.price_usd')  as decimal(8,4))) as MX_BCH,  cast(0.0 as decimal(8,4)) as MM_BCH,
           min(cast(json_unquote(x->'$.BTC.price_usd')  as decimal(9,4))) as MN_BTC,  
           max(cast(json_unquote(x->'$.BTC.price_usd')  as decimal(9,4))) as MX_BTC,  cast(0.0 as decimal(8,4)) as MM_BTC
      from cmc 
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

    update cmc_tmp_minmax
       set MM_DRGN = MX_DRGN - MN_DRGM,
           MM_XLM  = MX_XLM  - MN_XLM,
           MM_XRP  = MX_XRP  - MN_XRP,
           MM_NXT  = MX_NXT  - MN_NXT,
           MM_ETH  = MX_ETH  - MN_ETH,
           MM_SC   = MX_SC   - MN_SC,
           MM_BCH  = MX_BCH  - MN_BCH,
           MM_BTC  = MX_BTC  - MN_BTC;

    select MN_DRGM,   MX_DRGN,   MM_DRGN,   round(MM_DRGN * num_drgn, 2) as 'DIFF_DRGN' from cmc_tmp_minmax;
    select 'MN_XLM ', 'MX_XLM ', 'MM_XLM ', round(MM_XLM  * num_xlm,  2) as 'DIFF_XLM ' from cmc_tmp_minmax;

end
//
delimiter ;


