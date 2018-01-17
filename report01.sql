
drop procedure if exists report01;
delimiter //
create procedure report01()
begin
    declare num_keys int;
    declare cnt int;
    declare sym varchar(16);

    select json_length(json_keys(x)) into num_keys from cmc limit 1;
    select num_keys;

    set cnt = 0;
    -- while cnt < num_keys do
    while cnt < num_keys do

        -- select json_extract(json_keys(x), '$[16]') into @sym from cmc limit 1;

        set @sql = concat("select json_unquote(json_extract(json_keys(x), '$[", cnt, "]')) into @symbol from cmc limit 1;");
        prepare stmt1 from @sql;
        execute stmt1;
        deallocate prepare stmt1;

        if (@symbol <>    '42') && (@symbol <>   'B@') && (@symbol <>  '$$$') && (@symbol <>   '1ST') &&
           (@symbol <>   '300') && (@symbol <>  '611') && (@symbol <>  '808') && (@symbol <>   '888') &&
           (@symbol <>  '10MT') && (@symbol <> '1337') && (@symbol <> '8BIT') && (@symbol <> '2GIVE') &&
           (@symbol <> '9COIN')
        then
            set @sql = concat("select json_unquote(x->'$.", @symbol, ".name') into @name from cmc limit 1;");
            -- select @sql;
            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            replace into cmc_coin (cmc_symbol, cmc_name) values (@symbol, @name);
        else
            set @name = '"Illegal symbol"';
        end if;

        -- select cnt, @symbol, @name;
        set cnt = cnt + 1;
    end while;

end
//
delimiter ;

-- select lst,
--        json_unquote(x->'$.SC.price_usd') as PRice,
--        round(json_unquote(x->'$.SC.percent_change_1h'),3) as PC01H
--   from cmc
--  order by lst;

-- insert into js (x)
-- select json_extract(x->'$.DRGN', '$.symbol', '$.last_updated', '$.price_usd', '$.percent_change_1h', '$.percent_change_24h', '$.percent_change_7d')
--   from cmc
--  order by lst desc
--  limit 1;

-- mysql> select json_unquote(json_extract(x, '$[1]')) from js;
-- +---------------------------------------+
-- | json_unquote(json_extract(x, '$[1]')) |
-- +---------------------------------------+
-- | 1516137863                            |
-- +---------------------------------------+

-- mysql coins -e"select timestamp('${zDT}'), unix_timestamp(timestamp('${zDT}'));";
-- +-------------------------------+-----------------------------------------------+
-- | timestamp('2018-01-16 13:45') | unix_timestamp(timestamp('2018-01-16 13:45')) |
-- +-------------------------------+-----------------------------------------------+
-- | 2018-01-16 13:45:00           |                                    1516139100 |
-- +-------------------------------+-----------------------------------------------+

