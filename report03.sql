
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
    insert into js (x) -- select json_keys(x) from cmc limit 1;
    select json_keys(a.x) from cmc a where a.lst = (select max(b.lst) from cmc b) limit 1;

    -- the number of symbols
    select json_length(x) into @xlength from js;

    -- save away a single "line item", for keys
    truncate table js1; 
    insert into js1(x) -- select json_unquote(x->'$.BTC') from cmc limit 1;
    select json_unquote(a.x->'$.BTC') from cmc a where a.lst = (select max(b.lst) from cmc b) limit 1;

    -- save away the list of "actual dates", the cron way run
    truncate table js2_date_actual;
    insert into js2_date_actual -- select json_unquote(x->'$.BTC.date_actual') from cmc;
    select json_unquote(a.x->'$.BTC.date_actual') from cmc a where a.lst = (select max(b.lst) from cmc b) limit 1;

    -- scroll through the list of 1418 symbols
    set @idx = 0;
    -- set @xlength = 20;

    truncate table js3;
    -- truncate table cmc_data;
    select count(1) into @knt from cmc_data;

    label1: loop

        if @idx = @xlength then
            leave label1;
        else -- the list of symbols
            set @sql = concat("select json_unquote(json_extract(x, '$[",@idx,"]')) into @symbol from js;");
            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            select locate('@', @symbol)+locate('$', @symbol) into @symbol_locate;
            select convert(substring(@symbol,1,1), signed integer) into @symbol_numberic;

            select @idx, @symbol, @symbol_locate, @symbol_numberic;
            if @symbol_numberic > 0 or @symbol_locate > 0 then
                set @idx = @idx + 1;
                iterate label1;
            end if;

            truncate table js3;
            if @knt > 0 then
              set @sql = concat("select cmc_coin_id into @cmc_coin_id from cmc_coin where cmc_symbol = '",@symbol,"';");
              prepare stmt1 from @sql;
              execute stmt1;
              deallocate prepare stmt1;

              set @sql = concat("select max(last_actual_dt) into @max_date_actual from cmc_data where cmc_coin_id = ",@cmc_coin_id," limit 1;");
              prepare stmt1 from @sql;
              execute stmt1;
              deallocate prepare stmt1;

select @symbol, @cmc_coin_id, @max_date_actual, @sql;

              set @sql = concat("insert into js3(x) select distinct json_unquote(a.x->'$.",@symbol,
                                "') from cmc a where json_unquote(a.x->'$.BTC.date_actual') > '",@max_date_actual,"';");
              -- select @sql;
            else
              set @sql = concat("insert into js3(x) select distinct json_unquote(a.x->'$.",@symbol,"') from cmc a;");
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

