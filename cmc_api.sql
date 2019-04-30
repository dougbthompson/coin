
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

    -- select records where greater than [ coins.cmc_api.lstd > max(coins_cmc.capi_time.lts) ]
    declare v_cursor1 cursor for
      select lst, x from coins.cmc_api
       where lstd > (
             select ifnull(max(t.lts),0)
               from coins_cmc.capi_time t
              where t.id = (select ifnull(max(time_id),0) from coins_cmc.capi_current)
             );

    select max(lst) into v_lst_max from coins.cmc_api;
    set v_done = 0;

    -- reset or add to capi_time
    -- truncate table coins_cmc.capi_time;

    insert into coins_cmc.capi_time (ts, lts)
    select lst, unix_timestamp(lst)
      from coins.cmc_api
     where unix_timestamp(lst) > (select ifnull(max(lts),0) from coins_cmc.capi_time);

    /*
    replace into coins_cmc.capi_time (ts, lts) 
    select substring(json_unquote(x->'$.status.timestamp'),1,19),
           unix_timestamp(date_format(substring(json_unquote(x->'$.status.timestamp'),1,19),'%Y-%m-%dT%k:%i:%s'))
      from coins.cmc_api;
    */

    -- reset or add to capi_symbol, capi_specs
    open v_cursor1;
    repeat
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
              from coins.cmc_api
             where lst = v_lst;

            if not exists (select 1 from capi_symbol where symbol = v_symbol) 
            then
                insert into coins_cmc.capi_symbol (symbol) values (v_symbol);
            end if;

            -- capi_specs

            -- capi_current
            select id into v_time_id   from coins_cmc.capi_time   where ts     = v_lst;
            select id into v_symbol_id from coins_cmc.capi_symbol where symbol = v_symbol;

            -- select
            --   case when json_unquote(json_extract(x->'$.data', concat('$[','51','].quote.USD.volume_24h'))) = "null" then '0.0'
            --    end
            --   from coins.cmc_api where lst = '2019-01-29 06:00:01';

            -- ,(select case when (json_unquote(json_extract(v_json->'$.data',
            --                     concat('$[',@vidx,'].quote.USD.volume_24h'))) = "null") then '0.0' end)

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

        -- select v_lst, v_lst_max;
        if v_lst = v_lst_max then set v_done = 1; end if;
    until v_done end repeat;

    close v_cursor1;
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

-- select json_unquote(v_json->'$.data[0].symbol') into v_symbol;
-- select json_unquote(json_extract(x->'$.data', concat('$[',@val,'].symbol'))) from cmc_api;

-- set @vidx = v_idx;
-- select json_unquote(json_extract(x->'$.data', concat('$[',@vidx,'].quote.USD.price'))) from cmc_api limit 1;
-- select json_extract(x->'$.data', '$[0].quote') into @vjson from coins.cmc_api limit 1; select json_extract(@vjson, '$.USD.price');

-- 2019-01-29 06:00:01     100     BTC     2019-01-29T05:54:25.000Z
-- ERROR 1366 (HY000) at line 101: Incorrect decimal value: 'null' for column 'volume_24h' at row 1

-- mysql> select time_id, count(1) from capi_current group by time_id having count(1) < 100 order by time_id;
-- +---------+----------+
-- | time_id | count(1) |
-- +---------+----------+
-- |    1790 |       51 |
-- |    1815 |       34 |
-- |    2348 |       99 |
-- |    6312 |       99 |
-- +---------+----------+
-- 4 rows in set (0.32 sec)


