
--
-- report04: selection criteria reports
-- candidate coin report
--
-- let us use ETH as a sample coin, for testing purposes
-- 

drop procedure if exists report04;
delimiter //
create procedure report04(in zhours int)
begin
    declare last_date   datetime;

    select cmc_coin_id into @cmc_coin_id from cmc_coin where cmc_symbol = 'ETH';

    x
end
//
delimiter ;
