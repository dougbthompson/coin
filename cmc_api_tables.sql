
drop table if exists capi_symbol;
create table capi_symbol (
    id        integer      not null primary key auto_increment,
    symbol    varchar(16)  not null,

    index ix01_capi_symbol (symbol)
);

drop table if exists capi_time;
create table capi_time (
    id    integer      not null primary key auto_increment,
    ts    varchar(32)  not null,
    lts   integer      not null,

    index ix01_capi_time (lts),
    unique index ix02_capi_time (ts)
);

drop table if exists capi_specs;
create table capi_specs (
    time_id        integer      not null,
    symbol_id      integer      not null,
    dataid         integer          null,
    platformid     integer          null,
    name           varchar(64)      null,
    token_address  varchar(128)     null,
    date_added     varchar(32)      null,
    last_updated   varchar(32)      null,
    max_supply     bigint           null,
    total_supply   bigint           null,
    num_pairs      integer          null,
    circulating    bigint           null,

    index ix01_capi_specs (time_id, symbol_id),
    index ix02_capi_specs (symbol_id, time_id)
);

drop table if exists capi_current;
create table capi_current (
    time_id             integer      not null,
    symbol_id           integer      not null,
    price               decimal(24,16)  not null default 0.0,
    market_cap          decimal(24,16)  not null default 0.0,
    volume_24h          decimal(24,16)  not null default 0.0,
    last_updated        decimal(24,16)  not null default 0.0,
    percent_change_1h   decimal(24,16)  not null default 0.0,
    percent_change_7d   decimal(24,16)  not null default 0.0,
    percent_change_24h  decimal(24,16)  not null default 0.0,
    rank                integer             null,

    index ix01_capi_current (time_id, symbol_id),
    index ix02_capi_current (symbol_id, time_id)
);

