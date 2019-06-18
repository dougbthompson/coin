
drop procedure if exists cmc_api_01;
delimiter //

create procedure cmc_api_01 (in z int)
begin
    declare v_data_length integer default 0;
    declare v_done        boolean default 0;
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
       where lstd > (
             select ifnull(max(t.lts),0)
               from coins_cmc.capi_time t
              where t.id = (select ifnull(max(time_id),0) from coins_cmc.capi_current));

    declare v_cursor2 cursor for
      select lst, x from coins.cmc_api
       where lstd > (
             select ifnull(max(t.lts),0)
               from coins_cmc.capi_time t
              where t.id = (select ifnull(max(time_id),0) from coins_cmc.capi_specs));

    insert into coins_cmc.capi_time (ts, lts)
    select lst, unix_timestamp(lst)
      from coins.cmc_api
     where unix_timestamp(lst) > (select ifnull(max(lts),0) from coins_cmc.capi_time);

    select max(lst) into v_lst_max from coins.cmc_api;
    set v_done = 0;

    -- reset or add to capi_symbol, capi_current
    select 'Process new capi_current data...' as 'Which table';
    open v_cursor1;
    repeat
        fetch v_cursor1 into v_lst, v_json;
        select json_length(v_json->'$.data') into v_data_length; 

        set v_idx = 0;
        while v_idx < v_data_length
        do
            set @vidx = v_idx;
            select json_unquote(json_extract(x->'$.data', concat('$[',@vidx,'].symbol'))) into v_symbol
              from coins.cmc_api where lst = v_lst;

            if not exists (select 1 from capi_symbol where symbol = v_symbol) 
            then insert into coins_cmc.capi_symbol (symbol) values (v_symbol);
            end if;

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
        if v_lst = v_lst_max then set v_done = 1; end if;
    until v_done end repeat;
    close v_cursor1;


    -- reset or add to capi_symbol, capi_specs
    select 'Process new capi_recs data...' as 'Which table';
    set v_done = 0;
    open v_cursor2;
    repeat
        fetch v_cursor2 into v_lst, v_json;
        select json_length(v_json->'$.data') into v_data_length;

        set v_idx = 0;
        while v_idx < v_data_length
        do
            set @vidx = v_idx;
            select json_unquote(json_extract(x->'$.data', concat('$[',@vidx,'].symbol'))) into v_symbol
              from coins.cmc_api where lst = v_lst;

            if not exists (select 1 from capi_symbol where symbol = v_symbol)
            then insert into coins_cmc.capi_symbol (symbol) values (v_symbol);
            end if;

            -- capi_specs
            select id into v_time_id   from coins_cmc.capi_time   where ts     = v_lst;
            select id into v_symbol_id from coins_cmc.capi_symbol where symbol = v_symbol;

            insert into coins_cmc.capi_specs (time_id, symbol_id, dataid, platformid, name, token_address, date_added,
                        last_updated, max_supply, total_supply, num_pairs, circulating)
            select v_time_id
              ,v_symbol_id
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].id')))
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].platform.id')))
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].name')))
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].platform.token_address')))
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].date_added')))
              ,json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].last_updated')))
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].max_supply'))) = "null")
                  then '0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].max_supply'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].total_supply'))) = "null")
                  then '0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].total_supply'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].num_market_pairs'))) = "null")
                  then '0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].num_market_pairs'))) end)
              ,(select case when (json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].circulating_supply'))) = "null")
                  then '0' else json_unquote(json_extract(v_json->'$.data', concat('$[',@vidx,'].circulating_supply'))) end)
              from coins.cmc_api
             where lst = (select ts from coins_cmc.capi_time where id = v_time_id);

            set v_idx = v_idx + 1;
        end while;
        if v_lst = v_lst_max then set v_done = 1; end if;
    until v_done end repeat;
    close v_cursor2;

end
//
delimiter ;

-- call cmc_api_01(0);

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
/*
mysql> desc coins_cmc.capi_specs;
+---------------+--------------+------+-----+---------+-------+
| Field         | Type         | Null | Key | Default | Extra |
+---------------+--------------+------+-----+---------+-------+
| time_id       | int(11)      | NO   | MUL | NULL    |       |
| symbol_id     | int(11)      | NO   | MUL | NULL    |       |
| dataid        | int(11)      | YES  |     | NULL    |       |
| platformid    | int(11)      | YES  |     | NULL    |       |
| name          | varchar(64)  | YES  |     | NULL    |       |
| token_address | varchar(128) | YES  |     | NULL    |       |
| date_added    | varchar(32)  | YES  |     | NULL    |       |
| last_updated  | varchar(32)  | YES  |     | NULL    |       |
| max_supply    | bigint(20)   | YES  |     | NULL    |       |
| total_supply  | bigint(20)   | YES  |     | NULL    |       |
| num_pairs     | int(11)      | YES  |     | NULL    |       |
| circulating   | bigint(20)   | YES  |     | NULL    |       |
+---------------+--------------+------+-----+---------+-------+
*/

