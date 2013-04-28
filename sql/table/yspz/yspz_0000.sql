--
-- 特种调账单
--
drop table yspz_0000;
create table yspz_0000 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    cause                 varchar(512) not null,
    period                date not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0000.id                   is '原始凭证id';
comment on column yspz_0000.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0000.cause                is '调账原因';
comment on column yspz_0000.period               is '会计期间';

comment on column yspz_0000.flag                 is '撤销标志';
comment on column yspz_0000.revoke_cause         is '撤销原因';
comment on column yspz_0000.ts_revoke            is '撤销时间';
comment on column yspz_0000.revoke_user          is '撤销者';
comment on column yspz_0000.memo                 is '说明';
comment on column yspz_0000.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0000;
create sequence seq_yspz_0000 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

