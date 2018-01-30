
drop function if exists report06_funcs;
delimiter //

create function report06_funcs(actual_ts integer)
returns varchar(1024)
begin

    select 'return value' into @rvalue;
    cmc_correlation_hour.nhour

    return @rvalue;
end 
//

delimiter ;



