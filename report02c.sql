
drop procedure if exists report02c;
delimiter //
create procedure report02c(in zhours int)
begin
    declare last_date   datetime;

    select 19540.74618207  into @num_drgn;
    select 527739.970      into @num_trx;
    select 411235.353      into @num_poe;
    select 113036.850      into @num_ncash;

    select max(lst) into last_date from pol;

    select cast(json_unquote(x->'$.BTC')  as decimal(18,8)) into @num_btc from pol where lst = last_date;
    select cast(json_unquote(x->'$.ETH')  as decimal(18,8)) into @num_eth from pol where lst = last_date;
    select cast(json_unquote(x->'$.OMG')  as decimal(18,8)) into @num_omg from pol where lst = last_date;
    select cast(json_unquote(x->'$.SC')   as decimal(18,8)) into @num_sai from pol where lst = last_date;
    select cast(json_unquote(x->'$.STR')  as decimal(18,8)) into @num_xlm from pol where lst = last_date;
    select cast(json_unquote(x->'$.USDT') as decimal(18,8)) into @num_usd from pol where lst = last_date;
    select cast(json_unquote(x->'$.XRP')  as decimal(18,8)) into @num_xrp from pol where lst = last_date;

    select @num_sai;
end
//
delimiter ;

call report02c(4);

