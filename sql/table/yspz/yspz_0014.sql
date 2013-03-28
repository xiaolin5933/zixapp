--
-- 基金线-账户利息收入
--
drop table yspz_0014;
create table yspz_0014 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct              integer not null,
    zjbd_type             integer not null,
    wlzj_type             integer not null,
    period                date not null,
    zjbd_date_in          date not null,
    zhlx_amt              bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0014.id                   is '原始配置id';
comment on column yspz_0014.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0014.bfj_acct             is '备付金银行账号';
comment on column yspz_0014.zjbd_type            is '资金变动类型 - 账户利息';
comment on column yspz_0014.wlzj_type            is '往来资金类型 - 利息收入';
comment on column yspz_0014.period               is '会计期间';
comment on column yspz_0014.zjbd_date_in         is '备付金银行入账日期';
comment on column yspz_0014.zhlx_amt             is '账户利息收入金额';

comment on column yspz_0014.flag                 is '撤销标志';
comment on column yspz_0014.revoke_cause         is '撤销原因';
comment on column yspz_0014.ts_revoke            is '撤销时间';
comment on column yspz_0014.revoke_user          is '撤销者';
comment on column yspz_0014.memo                 is '说明';
comment on column yspz_0014.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0014;
create sequence seq_yspz_0014 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

