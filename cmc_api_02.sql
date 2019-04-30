
-- redo of an existing capi_time.id === p_time_id

drop procedure if exists cmc_api_02;
delimiter //

create procedure cmc_api_02 (in p_time_id int)
begin
    declare v_data_length integer default 0;
    declare v_idx         integer default 0;
    declare v_json        json;
    declare v_lst         datetime;
    declare v_lst_max     datetime;
    declare v_sql         varchar(1024);
    declare v_symbol      varchar(16);
    declare v_symbol_id   integer;
    declare v_time_id     integer;

    declare v_cursor1 cursor for
      select lst, x from coins.cmc_api
       where unix_timestamp(lst) = (select lts from coins_cmc.capi_time where id = p_time_id);

    -- value is already in coins_cmc.capi_time
    -- insert into coins_cmc.capi_time (ts, lts)
    -- select lst, unix_timestamp(lst)
    --   from coins.cmc_api
    --  where unix_timestamp(lst) > (select ifnull(max(lts),0) from coins_cmc.capi_time);

    open v_cursor1;
    fetch v_cursor1 into v_lst, v_json;
    select json_length(v_json->'$.data') into v_data_length; 

    select v_lst, v_data_length
          ,json_unquote(json_extract(v_json->'$.data', concat('$[0].symbol'))) as Symbol
          ,json_unquote(json_extract(v_json->'$.data', concat('$[0].last_updated'))) as LastUpdated;

    set v_idx = 0;
    while v_idx < v_data_length
    do
        set @vidx = v_idx;

        select json_unquote(json_extract(x->'$.data', concat('$[',@vidx,'].symbol'))) into v_symbol
          from coins.cmc_api where lst = v_lst;

        if not exists (select 1 from capi_symbol where symbol = v_symbol) 
        then
            insert into coins_cmc.capi_symbol (symbol) values (v_symbol);
        end if;

        -- capi_specs

        -- capi_current
        select id into v_time_id   from coins_cmc.capi_time   where ts     = v_lst;
        select id into v_symbol_id from coins_cmc.capi_symbol where symbol = v_symbol;

        insert into coins_cmc.capi_current (time_id, symbol_id, price, market_cap, volume_24h, last_updated,
                                            percent_change_1h, percent_change_7d, percent_change_24h, rank)
        select v_time_id
              ,v_symbol_id
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.price')))
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.market_cap'))) = "null")
                  then '0.0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.market_cap'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.volume_24h'))) = "null")
                  then '0.0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.volume_24h'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.last_updated'))) = "null") 
                  then '0.0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.last_updated'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.percent_change_1h'))) = "null") 
                  then '0.0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.percent_change_1h'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.percent_change_7d'))) = "null") 
                  then '0.0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.percent_change_7d'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.percent_change_24h'))) = "null") 
                  then '0.0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].quote.USD.percent_change_24h'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].cmc_rank'))) = "null") 
                  then '0'   else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].cmc_rank'))) end)
          from coins.cmc_api
         where lst = (select ts from coins_cmc.capi_time where id = v_time_id);

        set v_idx = v_idx + 1;
    end while;

    close v_cursor1;
end
//
delimiter ;

-- call cmc_api_02 (1790);

-- mysql> select time_id, count(1) from capi_current group by time_id having count(1) < 100 order by time_id;
-- +---------+----------+
-- | time_id | count(1) |
-- +---------+----------+
-- |    1790 |       51 |
-- |    1815 |       34 |
-- +---------+----------+

