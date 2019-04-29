
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
       where lstd > (select max(lts) - (3600 * 12) from coins_cmc.capi_time);

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
            select id into v_time_id from coins_cmc.capi_time where lts = v_lst;
            select id into v_symbol_id from coins_cmc.capi_symbol where symbol = v_symbol;

            set v_idx = v_idx + 1;
        end while;

        if v_lst = v_lst_max then set v_done = 1; end if;
    until v_done end repeat;

    close v_cursor1;
end
//
delimiter ;

call cmc_api_01(0);

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

