
drop table if exists cmc;

create table cmc (
    x      json default null, 
    lst    datetime   generated always as (from_unixtime(json_unquote(x->'$.BTC.last_updated'))) virtual, 
    lstd   bigint(20) generated always as (json_unquote(x->'$.BTC.last_updated')) virtual
) engine = innodb;

