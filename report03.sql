
-- 
-- 
-- note: symbols that start with a number [0-9] are a problem for the
-- json processing functions, so probably need to be ignored
--

drop procedure if exists report03;
delimiter //
create procedure report03(in zhours int)
begin

    -- "keys" are the list of symbols being tracked
    truncate table js;
    insert into js (x) select json_keys(x) from cmc limit 1;

    -- the number of symbols
    select json_length(x) into @xlength from js;

    -- save away a single "line item", for keys
    truncate table js1; 
    insert into js1(x) select json_unquote(x->'$.BTC') from cmc limit 1;

    -- save away the list of "actual dates", the cron way run
    truncate table js2_date_actual;
    insert into js2_date_actual
    select json_unquote(x->'$.BTC.date_actual') from cmc;

    -- scroll through the list of 1418 symbols
    set @idx = 0;
    set @xlength = 10;

    label1: loop

        if @idx = @xlength then
            leave label1;
        else -- the list of symbols
            set @sql = concat("select json_extract(x, '$[",@idx,"]') from js;");
            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            select '2', @idx;
            set @idx = @idx + 1;
            iterate label1;
        end if;

    end loop label1;

end
//
delimiter ;


truncate table js; 
insert into js(x) select json_unquote(x->'$.BTC') from cmc limit 1;

-- = 16
select json_length(json_keys(x->'$.BTC')) from cmc limit 1;
select json_extract(json_keys(x->'$.BTC'), '$[*]') from cmc limit 1;

select * from cmc_coin where cmc_symbol = 'BTC';
select cmc_coin_id from cmc_coin where cmc_symbol = 'BTC';

truncate table js3;

insert into js3(x) select distinct json_unquote(x->'$.BTC') from cmc;

insert into cmc_data (cmc_coin_id, last_updated, last_actual_dt, last_actual_ts,
       volume_usd_24h, pc_1h, pc_24h, pc_7d, price_usd, price_btc, rank)
select (select cmc_coin_id from cmc_coin where cmc_symbol = 'BTC'),
       json_unquote(x->'$.last_updated'),
       json_unquote(x->'$.date_actual'),
       round(unix_timestamp(json_unquote(x->'$.date_actual')),0),
       json_unquote(x->'$.volume_usd_24h'),
       json_unquote(x->'$.percent_change_1h'),
       json_unquote(x->'$.percent_change_24h'),
       json_unquote(x->'$.percent_change_7d'),
       json_unquote(x->'$.price_usd'),
       json_unquote(x->'$.price_btc'),
       json_unquote(x->'$.rank')
  from js3;

insert into cmc_data (cmc_data_id, last_updated, last_actual_dt, last_actual_ts,
       volume_usd_24h, pc_1h, pc_24h, pc_7d, price_usd, price_btc, rank)
select 


