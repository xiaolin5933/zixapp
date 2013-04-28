--
-- 基金线-委托收款结算
--
drop table yspz_0007;
create table yspz_0007 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    ssn                   char(32) not null,
    bfj_acct_bj           integer not null,
    bi                    integer not null,
    p                     integer not null,
    c                     char(32) not null,
    period                date not null,
    tx_date               date not null,
    zjbd_date_out         date not null,
    tx_amt                bigint not null,
    cwwf_bfee             bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0007.id                   is '原始凭证id';
comment on column yspz_0007.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0007.ssn                  is '交易流水编号';
comment on column yspz_0007.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0007.bi                   is '银行接口编号';
comment on column yspz_0007.p                    is '产品类型 - 基金结算';
comment on column yspz_0007.c                    is '客户编号';
comment on column yspz_0007.period               is '会计期间';
comment on column yspz_0007.tx_date              is '交易日期';
comment on column yspz_0007.zjbd_date_out        is '本金备付金银行出账日期';
comment on column yspz_0007.tx_amt               is '出款金额';
comment on column yspz_0007.cwwf_bfee            is '财务外付银行手续费';

comment on column yspz_0007.flag                 is '撤销标志';
comment on column yspz_0007.revoke_cause         is '撤销原因';
comment on column yspz_0007.ts_revoke            is '撤销时间';
comment on column yspz_0007.revoke_user          is '撤销者';
comment on column yspz_0007.memo                 is '说明';
comment on column yspz_0007.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0007;
create sequence seq_yspz_0007 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

