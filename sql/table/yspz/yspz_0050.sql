--
-- POS收款反向交易勾兑不成功（银有我无，追回）
--
drop table yspz_0050;
create table yspz_0050 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_bj           integer not null,
    bi                    integer not null,
    tx_type               integer not null,
    period                date not null,
    zjbd_date_in          date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
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


comment on column yspz_0050.id                   is '原始凭证id';
comment on column yspz_0050.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0050.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0050.bi                   is '银行接口编号';
comment on column yspz_0050.tx_type              is '交易类型';
comment on column yspz_0050.period               is '会计期间';
comment on column yspz_0050.zjbd_date_in         is '本金备付金银行入账日期';
comment on column yspz_0050.tx_date              is '交易日期';
comment on column yspz_0050.ssn                  is '交易流水编号';
comment on column yspz_0050.tx_amt               is '追回出款金额';

comment on column yspz_0050.flag                 is '撤销标志';
comment on column yspz_0050.revoke_cause         is '撤销原因';
comment on column yspz_0050.ts_revoke            is '撤销时间';
comment on column yspz_0050.revoke_user          is '撤销者';
comment on column yspz_0050.memo                 is '说明';
comment on column yspz_0050.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0050;
create sequence seq_yspz_0050 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;
