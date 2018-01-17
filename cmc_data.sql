
drop table if exists cmc_data;

create table cmc_data (
    cmc_data_id     integer auto_increment,
    cmc_coin_id     integer,

    last_updated    datetime,
    last_actual_dt  varchar(32),
    last_actual_ts  integer,

    volume_usd_24h  double precision(20,4),
    pc_1h           double precision,
    pc_24h          double precision,
    pc_7d           double precision,
    price_usd       double precision,
    price_btc       double precision,
    rank            integer,

    primary key  (cmc_data_id),
    index ix01_cmc_data (cmc_coin_id, cmc_data_id)
) engine = innodb;

