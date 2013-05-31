--
-- 特种调账单
--
drop table yspz_init;
create table yspz_init (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    content               blob(2g) not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx long in tbs_long; 


comment on column yspz_init.id                   is '原始凭证id';
comment on column yspz_init.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';
comment on column yspz_init.content              is '存放历史账薄报表文件';
comment on column yspz_init.flag                 is '撤销标志';
comment on column yspz_init.revoke_cause         is '撤销原因';
comment on column yspz_init.ts_revoke            is '撤销时间';
comment on column yspz_init.revoke_user          is '撤销者';
comment on column yspz_init.memo                 is '说明';
comment on column yspz_init.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_init;
create sequence seq_yspz_init as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

