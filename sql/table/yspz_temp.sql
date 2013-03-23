drop table yspz_temp;
create table yspz_temp (

-- id
-- 处理状态

    id                   bigint primary key not null,
    status               char(1) not null,

--- tp  : 
    period               date       not null,

-- revoke-concerned
    flag                 char(1),
    revoke_cause         varchar(512),
    revoke_user          int,
    ts_revoke            timestamp,

    memo                 varchar(512),
    ts_c                 timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 

drop sequence seq_yspz_temp;
create sequence seq_yspz_temp as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

