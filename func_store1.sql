
drop procedure if exists proc_store1;
delimiter //

create procedure proc_store1(in symbol varchar(8), in actual_date integer,
       in curr_datetime datetime, in icoins decimal(18,8))
begin

    select from_unixtime(actual_date) into @actual_datetime;

    set @sql = concat("insert into cmc_tmp_min_max (symbol, name, coins, xusd) select json_unquote(x->'$.",
               symbol,".symbol'), json_unquote(x->'$.",symbol,".name'), ",icoins,", json_unquote(x->'$.",symbol,
               ".price_usd') from cmc where json_unquote(x->'$.",symbol,".date_actual') = '",curr_datetime,"'");

    prepare stmt1 from @sql;
    execute stmt1;
    deallocate prepare stmt1;

    set @sql = concat("update cmc_tmp_min_max a, (select min(cast(json_unquote(b.x->'$.",symbol,
               ".price_usd') as decimal(18,8))) as xmin, max(cast(json_unquote(b.x->'$.",symbol,
               ".price_usd') as decimal(18,8))) as xmax, max(cast(json_unquote(b.x->'$.",symbol,
               ".price_usd') as decimal(18,8))) - min(cast(json_unquote(b.x->'$.",symbol,
               ".price_usd') as decimal(18,8))) as xdif from cmc b where b.lst > from_unixtime(",
               "(",actual_date,"))) z set a.xmin = z.xmin, a.xmax = z.xmax, ",
               "a.xdif = z.xdif where a.symbol = '",symbol,"';");

    prepare stmt1 from @sql;
    execute stmt1;
    deallocate prepare stmt1;

end

//
delimiter ;

