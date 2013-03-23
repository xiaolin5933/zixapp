drop table yspz_0000;
create table yspz_0000 (

    -- primary key
    id             bigint primary key not null,

    -- 
    cause           varchar(1024) not null,
    creator         integer not null   default 0,

    -- 撤销
    flag            char(2) not null   default '0',
    revoke_cause    varchar(1024),
    revoke_ts       timestamp,
    revoke_user     integer,

    -- 会计期间(tp)
    period          date,

    ts_c            timestamp default current timestamp
  
) in tbs_dat index in tbs_idx;

comment on column yspz_0000.id           is '原始配置id';
comment on column yspz_0000.cause        is '特种调账原因';
comment on column yspz_0000.creator      is '创建者';
comment on column yspz_0000.ts_c         is '创建时间';

comment on column yspz_0000.flag         is '撤销标志';
comment on column yspz_0000.revoke_cause is '撤销原因';
comment on column yspz_0000.revoke_ts    is '撤销时间';
comment on column yspz_0000.revoke_user  is '撤销者';

drop sequence seq_yspz_0000;
create sequence seq_yspz_0000 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle no cache order;



