--
-- 出款勾兑不成功（银有我无，客户补单）
--
drop table yspz_0024;
create table yspz_0024 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_bj           integer not null,
    bfj_acct              integer not null,
    bi                    integer not null,
    wlzj_type             integer not null,
    p                     integer not null,
    period                date not null,
    zjbd_date_out_bj      date not null,
    zjbd_date_out         date not null,
    tx_date               date not null,
    ssn                   char(32) not null,
    c                     char(32) not null,
    wqr_c                 char(32) not null,
    cust_proto            char(32) not null,
    cfee                  bigint not null,
    cfee_back             bigint not null,
    cwws_cfee             bigint not null,
    cwws_cfee_back        bigint not null,
    bfee                  bigint not null,
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


comment on column yspz_0024.id                   is '原始凭证id';
comment on column yspz_0024.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0024.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0024.bfj_acct             is '备付金内扣银行账号';
comment on column yspz_0024.bi                   is '银行接口编号';
comment on column yspz_0024.wlzj_type            is '往来类型 - 客户手续费';
comment on column yspz_0024.p                    is '产品类型';
comment on column yspz_0024.period               is '会计期间';
comment on column yspz_0024.zjbd_date_out_bj     is '本金备付金银行出账日期';
comment on column yspz_0024.zjbd_date_out        is '备付金内扣银行出账日期';
comment on column yspz_0024.tx_date              is '交易日期';
comment on column yspz_0024.ssn                  is '交易流水编号';
comment on column yspz_0024.c                    is '客户编号';
comment on column yspz_0024.wqr_c                is '未确认客户编号';
comment on column yspz_0024.cust_proto           is '客户协议编号';
comment on column yspz_0024.cfee                 is '备付金内扣客户手续费金额';
comment on column yspz_0024.cfee_back            is '退回备付金内扣客户手续费金额';
comment on column yspz_0024.cwws_cfee            is '财务外收客户手续费金额';
comment on column yspz_0024.cwws_cfee_back       is '退回财务外收客户手续费金额';
comment on column yspz_0024.bfee                 is '确认的银行成本金额';
comment on column yspz_0024.tx_amt               is '出款金额';

comment on column yspz_0024.flag                 is '撤销标志';
comment on column yspz_0024.revoke_cause         is '撤销原因';
comment on column yspz_0024.ts_revoke            is '撤销时间';
comment on column yspz_0024.revoke_user          is '撤销者';
comment on column yspz_0024.memo                 is '说明';
comment on column yspz_0024.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0024;
create sequence seq_yspz_0024 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

