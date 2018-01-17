
drop procedure if exists report02;
delimiter //
create procedure report02(in zhours int)
begin
    declare last_date datetime;
    declare num_xlm decimal(18.8);
    declare num_xrp decimal(18.8);
    declare num_nxt decimal(18.8);
    declare num_eth decimal(18.8);
    declare num_sc  decimal(18.8);
    declare num_bch decimal(18.8);
    declare num_btc decimal(18.8);

    select max(lst) into last_date from pol;

    select cast(json_unquote(x->'$.STR') as decimal(18,8)) into num_xlm from pol where lst = last_date;
    select cast(json_unquote(x->'$.XRP') as decimal(18,8)) into num_xrp from pol where lst = last_date;
    select cast(json_unquote(x->'$.NXT') as decimal(18,8)) into num_nxt from pol where lst = last_date;
    select cast(json_unquote(x->'$.ETH') as decimal(18,8)) into num_eth from pol where lst = last_date;
    select cast(json_unquote(x->'$.SC')  as decimal(18,8)) into num_sc  from pol where lst = last_date;
    select cast(json_unquote(x->'$.BCH') as decimal(18,8)) into num_bch from pol where lst = last_date;
    select cast(json_unquote(x->'$.BTC') as decimal(18,8)) into num_btc from pol where lst = last_date;

    select num_xlm;

    drop table if exists cmc_tmp_values;

    create temporary table cmc_tmp_values
    select lst as DTime,
           round(json_unquote(x->'$.DRGN.price_usd'),4) as Dragon,
           round((cast(json_unquote(x->'$.DRGN.price_usd') as decimal(8,4)) * 19540.0),2) as DTotal,

           round(json_unquote(x->'$.XLM.price_usd'),4)  as Stellar,
           round(json_unquote(x->'$.XRP.price_usd'),4)  as Ripple,
           round(json_unquote(x->'$.NXT.price_usd'),4)  as Next,
           round(json_unquote(x->'$.ETH.price_usd'),4)  as Ethereum,
           round(json_unquote(x->'$.SC.price_usd'),4)   as Siacoin,
           round(json_unquote(x->'$.BCH.price_usd'),4)  as 'Bit Cash',
           round(json_unquote(x->'$.BTC.price_usd'),4)  as Bitcoin,

           round(
           (cast(json_unquote(x->'$.XLM.price_usd')  as decimal(8,4)) * num_xlm) +
           (cast(json_unquote(x->'$.XRP.price_usd')  as decimal(8,4)) * 84190.0) +
           (cast(json_unquote(x->'$.NXT.price_usd')  as decimal(8,4)) * 76688.0) +
           (cast(json_unquote(x->'$.ETH.price_usd')  as decimal(8,4)) * 18.1894) +
           (cast(json_unquote(x->'$.SC.price_usd')   as decimal(8,4)) * 9032.36) +
           (cast(json_unquote(x->'$.BCH.price_usd')  as decimal(8,4)) * 0.0003),2) as CTotal,
           cast(0.0 as decimal(18,2)) as ZTotal
      from cmc
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

    update cmc_tmp_values
       set ZTotal = DTotal + CTotal;

    select * from cmc_tmp_values;

    select min(cast(json_unquote(x->'$.DRGN.price_usd') as decimal(8,4))) as MN_DRGM, 
           max(cast(json_unquote(x->'$.DRGN.price_usd') as decimal(8,4))) as MX_DRGN,
           min(cast(json_unquote(x->'$.XLM.price_usd')  as decimal(8,4))) as MN_XLM,  
           max(cast(json_unquote(x->'$.XLM.price_usd')  as decimal(8,4))) as MX_XLM,
           min(cast(json_unquote(x->'$.XRP.price_usd')  as decimal(8,4))) as MN_XRP,  
           max(cast(json_unquote(x->'$.XRP.price_usd')  as decimal(8,4))) as MX_XRP,
           min(cast(json_unquote(x->'$.NXT.price_usd')  as decimal(8,4))) as MN_NXT,  
           max(cast(json_unquote(x->'$.NXT.price_usd')  as decimal(8,4))) as MX_NXT,
           min(cast(json_unquote(x->'$.SC.price_usd')   as decimal(8,4))) as MN_SC,   
           max(cast(json_unquote(x->'$.SC.price_usd')   as decimal(8,4))) as MX_SC,
           min(cast(json_unquote(x->'$.BCH.price_usd')  as decimal(8,4))) as MN_BCH,  
           max(cast(json_unquote(x->'$.BCH.price_usd')  as decimal(8,4))) as MX_BCH,
           min(cast(json_unquote(x->'$.BTC.price_usd')  as decimal(9,4))) as MN_BTC,  
           max(cast(json_unquote(x->'$.BTC.price_usd')  as decimal(9,4))) as MX_BTC
      from cmc 
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

end
//
delimiter ;

