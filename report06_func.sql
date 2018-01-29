
drop function if exists report06_funcs;
delimiter //

create function report06_funcs(actual_ts integer)
returns varchar(1024)
begin

    select 'return value' into @rvalue;

    return @rvalue;
end 
//

delimiter ;

    cmc_correlation_hour.nhour

    select a.last_actual_ts,
           json_object('VOLUME', round(sum(a.volume_usd_24h/1000000.0),2),
                       'PC01H', round(avg(pc_1h),2)
           ) as json_value
      from cmc_data a, cmc_time b
     where a.last_actual_ts  = b.actual_lst
       and a.rank           <= 100
     group by a.last_actual_ts
     limit 8;

