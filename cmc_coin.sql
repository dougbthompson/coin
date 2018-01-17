
drop table if exists cmc_coin;

create table cmc_coin (
    cmc_coin_id  integer auto_increment,
    cmc_symbol   varchar(16),
    cmc_name     varchar(32),
    primary key  (cmc_coin_id),
    index ix01_cmc_coin (cmc_symbol, cmc_coin_id)
) engine = innodb;

