--
-- 客户备付金汇入
--
drop table yspz_0018;
create table yspz_0018 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_bj           integer not null,
    zjbd_type             integer not null,
    period                date not null,
    zjbd_date_in          date not null,
    c                     char(32) not null,
    tx_amt                bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0018.id                   is '原始凭证id';
comment on column yspz_0018.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0018.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0018.zjbd_type            is '资金变动类型 - 银行转账充值';
comment on column yspz_0018.period               is '会计期间';
comment on column yspz_0018.zjbd_date_in         is '本金备付金银行入账日期';
comment on column yspz_0018.c                    is '客户编号';
comment on column yspz_0018.tx_amt               is '客户备付金汇入金额';

comment on column yspz_0018.flag                 is '撤销标志';
comment on column yspz_0018.revoke_cause         is '撤销原因';
comment on column yspz_0018.ts_revoke            is '撤销时间';
comment on column yspz_0018.revoke_user          is '撤销者';
comment on column yspz_0018.memo                 is '说明';
comment on column yspz_0018.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0018;
create sequence seq_yspz_0018 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

