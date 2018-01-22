
-- 
-- report03: this populates the table 'cmc_data' pulling vales from the 'cmc'
-- table records and populating cmc_data, non-relational to relation storage
-- 
-- note: symbols that start with a number [0-9] can be a problem for the
-- mysql json processing functions, so probably need to be ignored, but not yet
--
-- subsequent runs, to add new data to the cmc_data table
-- 1) check for data in the cmc_data table, extract the max(x->'$.BTC.date_actual') value
-- 2) inserts into js3 will be based on the existing max(date_actual) value
--    modify the ks3 insert code for > max(date_actual) value
--

drop procedure if exists report03;
delimiter //
create procedure report03()
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

    select count(1) into @knt from cmc_data;

    truncate table js3;
    truncate table cmc_data;

    label1: loop

        if @idx = @xlength then
            leave label1;
        else -- the list of symbols
            set @sql = concat("select json_unquote(json_extract(x, '$[",@idx,"]')) into @symbol from js;");
            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            select @idx, @symbol;

            truncate table js3;
            if @knt > 0 theh
              set @sql = concat("")
            else
              set @sql = concat("insert into js3(x) select distinct json_unquote(x->'$.",@symbol,"') from cmc;");
            end if;
            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            update js3 set x = json_set(x, '$.price_usd',          '0.0') where json_unquote(x->'$.price_usd')          = 'null';
            update js3 set x = json_set(x, '$.price_btc',          '0.0') where json_unquote(x->'$.price_btc')          = 'null';
            update js3 set x = json_set(x, '$.last_updated',         '0') where json_unquote(x->'$.last_updated')       = 'null';
            update js3 set x = json_set(x, '$.volume_usd_24h',     '0.0') where json_unquote(x->'$.volume_usd_24h')     = 'null';
            update js3 set x = json_set(x, '$.percent_change_1h',  '0.0') where json_unquote(x->'$.percent_change_1h')  = 'null';
            update js3 set x = json_set(x, '$.percent_change_24h', '0.0') where json_unquote(x->'$.percent_change_24h') = 'null';
            update js3 set x = json_set(x, '$.percent_change_7d',  '0.0') where json_unquote(x->'$.percent_change_7d')  = 'null';

            set @sql = concat("insert into cmc_data (cmc_coin_id, last_updated, last_actual_dt, last_actual_ts, volume_usd_24h, pc_1h, pc_24h, pc_7d, price_usd, price_btc, rank) select (select cmc_coin_id from cmc_coin where cmc_symbol = '",@symbol,"'), json_unquote(x->'$.last_updated'), json_unquote(x->'$.date_actual'), round(unix_timestamp(json_unquote(x->'$.date_actual')),0), json_unquote(x->'$.volume_usd_24h'), json_unquote(x->'$.percent_change_1h'), json_unquote(x->'$.percent_change_24h'), json_unquote(x->'$.percent_change_7d'), json_unquote(x->'$.price_usd'), json_unquote(x->'$.price_btc'), json_unquote(x->'$.rank') from js3;");
            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            set @idx = @idx + 1;
            iterate label1;
        end if;

    end loop label1;

end
//
delimiter ;

-- update js3 set x = json_set(x, '$.percent_change_24h', '0.0') where json_unquote(x->'$.percent_change_24h') = 'null';

