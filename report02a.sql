
-- echo -ne "\e[1;32;44m Hello, World! \e[m \n"
-- select 19540.74618207 into @num_drgn;

drop function if exists rep02a_num_coins;
delimiter //

create function rep02a_num_coins(sym varchar(16))
returns double
begin

    select numberofcoins into @value
      from tmp_list
     where symbol = sym;

    return @value;
end
//
delimiter ;

drop procedure if exists report02a;
delimiter //

create procedure report02a(in zhours int)
begin

    drop temporary table if exists tmp_list;
    create temporary table tmp_list (
        idx            integer auto_increment primary key,
        symbol         varchar(16),
        cmc_symbol     varchar(16)    null,
        exchange       varchar(16),
        numberofcoins  double         null,
        widthofvalue   smallint       null,
        unique index ix01_tmp_list (symbol, idx)
    );

    insert into tmp_list (symbol, cmc_symbol, exchange, numberofcoins)
    values ('XRP' ,null  ,'Poloniex' ,null),
           ('STR' ,'XLM' ,'Poloniex' ,null),
           ('NXT' ,null  ,'Poloniex' ,null),
           ('ETH' ,null  ,'Poloniex' ,null),
           ('BCH' ,null  ,'Poloniex' ,null),
           ('BTC' ,null  ,'Poloniex' ,0.0),
           ('TRX' ,null  ,'Binance'  ,0.0),
           ('POE' ,null  ,'Binance'  ,0.0),
           ('ENG' ,null  ,'Binance'  ,0.0),
           ('DRGN',null  ,'Kucoin'   ,19540.74618207);

    select max(lst) into @last_date from pol;
    select max(idx) into @tmp_idx from tmp_list;

    set @idx = 1;
    set @total = 0;

    label1: loop
        select symbol,exchange into @symbol,@exchange from tmp_list where idx = @idx;
        if @exchange = 'Poloniex' then
            set @sql = concat("select cast(json_unquote(x->'$.",@symbol,
                              "') as decimal(18,8)) into @num_coins from pol where lst = '",@last_date,"';");

            prepare stmt1 from @sql;
            execute stmt1;
            deallocate prepare stmt1;

            update tmp_list set numberofcoins = @num_coins where idx = @idx;
        end if;

        if @idx = @tmp_idx then
            leave label1;
        end if;
        set @idx = @idx + 1;
    end loop label1;

    -- select cmc_name from cmc_coin where cmc_symbol = 'TRX';

    -- use @sql to create a temp table:
    -- time across the top the X axis, last 8 time periods
    -- coins, details along the Y axis
    -- below, summary data

    drop table if exists tmp_time_coins;
    create temporary table tmp_time_coins (
        idx           integer auto_increment primary key,
        time_values   json,
        time_value01  varchar(16),
        time_value02  varchar(16),

        coin_symbol   varchar(16),
        coin_name     varchar(32),
        coin_number   double,

        index ix01_tmp_time_coins (idx)
    ) engine = innodb;

    -- select json_unquote(x->'$.BTC.date_actual') from cmc order by 1 desc limit 8;

    drop table if exists cmc_tmp_values;
    create table cmc_tmp_values
    select json_unquote(x->'$.BTC.date_actual') as 'Date Time',
           round(json_unquote(x->'$.DRGN.price_usd'),3) as 'Dragon___',
           round((cast(json_unquote(x->'$.DRGN.price_usd') as decimal(18,8)) * rep02a_num_coins('DRGN')),2) as DTotal,

           round(json_unquote(x->'$.TRX.price_usd'),3)  as 'Tron____',
           round(json_unquote(x->'$.XLM.price_usd'),3)  as 'Stellar_',
           round(json_unquote(x->'$.XRP.price_usd'),3)  as 'Ripple__',
           round(json_unquote(x->'$.NXT.price_usd'),3)  as 'Next____',
           round(json_unquote(x->'$.ETH.price_usd'),3)  as 'Ethereum',
           round(json_unquote(x->'$.BCH.price_usd'),3)  as 'Bit Cash',
           round(json_unquote(x->'$.BTC.price_usd'),3)  as 'Bitcoin_',

           round(
           (cast(json_unquote(x->'$.XLM.price_usd')  as decimal(18,8)) * rep02a_num_coins('STR')) +
           (cast(json_unquote(x->'$.XRP.price_usd')  as decimal(18,8)) * rep02a_num_coins('XRP')) +
           (cast(json_unquote(x->'$.NXT.price_usd')  as decimal(18,8)) * rep02a_num_coins('NXT')) +
           (cast(json_unquote(x->'$.ETH.price_usd')  as decimal(18,8)) * rep02a_num_coins('ETH')) +
           (cast(json_unquote(x->'$.BTC.price_usd')  as decimal(18,8)) * rep02a_num_coins('BTC')) +
           (cast(json_unquote(x->'$.BCH.price_usd')  as decimal(18,8)) * rep02a_num_coins('BCH')),2) as CTotal,
           cast(0.0 as decimal(18,2)) as ZTotal
      from cmc
     where lst > from_unixtime((unix_timestamp(now()) - (3600 * zhours)))
     order by lst desc;

    update cmc_tmp_values set ZTotal = DTotal + CTotal;

    # main display statement
    select min(ztotal) into @min_ztotal from cmc_tmp_values;
    select 10.0 / (max(ztotal) - min(ztotal)) into @minmax_diff from cmc_tmp_values;

    select a.*,
           substring('**********', 1, round((a.ztotal - @min_ztotal) * @minmax_diff,0)) as 'Wave______'
      from cmc_tmp_values a
     order by 1 desc limit 36;

    drop temporary table if exists cmc_tmp_min_max;
    create temporary table cmc_tmp_min_max (
      idx       int auto_increment primary key,
      symbol    varchar(16)    null,
      name      varchar(16)    null,
      coins     decimal(18,8)  null,
      xmin      decimal(18,8)  null,
      xmax      decimal(18,8)  null,
      xdif      decimal(18,8)  null,
      diff_tot  decimal(18,8)  null,
      xusd      decimal(18,8)  null,
      curr_tot  decimal(18,8)  null);

    select unix_timestamp(json_unquote(x->'$.BTC.date_actual')) into @start_date
      from cmc
     where unix_timestamp(json_unquote(x->'$.BTC.date_actual')) > (unix_timestamp(now()) - (3600 * zhours))
     order by unix_timestamp(json_unquote(x->'$.BTC.date_actual'))
     limit 1;

    select max(json_unquote(x->'$.BTC.date_actual')) into @curr_datetime from cmc limit 1;

    select max(idx) into @tmp_idx from tmp_list;
    set @idx = 1;

    label1: loop
        select symbol,cmc_symbol into @symbol,@cmc_symbol from tmp_list where idx = @idx;

        if @cmc_symbol is not null then
            set @sql = concat("call proc_store1('",@cmc_symbol,"', @start_date, @curr_datetime, rep02a_num_coins('",@symbol,"'));");
        else
            set @sql = concat("call proc_store1('",@symbol,"', @start_date, @curr_datetime, rep02a_num_coins('",@symbol,"'));");
        end if;

        prepare stmt2 from @sql;
        execute stmt2;
        deallocate prepare stmt2;

        if @idx = @tmp_idx then
            leave label1;
        end if;
        set @idx = @idx + 1;
    end loop label1;

    update cmc_tmp_min_max
       set curr_tot = coins * xusd,
           diff_tot = coins * xdif;

    select * from cmc_tmp_min_max order by curr_tot desc;
    select sum(coins), sum(diff_tot), sum(curr_tot) from cmc_tmp_min_max;

end
//
delimiter ;

