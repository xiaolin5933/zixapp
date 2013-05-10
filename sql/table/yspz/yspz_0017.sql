--
-- 直联POS代清算收款反向交易勾兑成功
--
drop table yspz_0017;
create table yspz_0017 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_1            integer not null,
    bfj_acct_2            integer not null,
    bfj_acct_bj           integer not null,
    bi                    integer not null,
    wlzj_type             integer not null,
    p                     integer not null,
    period                date not null,
    zjbd_date_out         date not null,
    zjbd_date_in_1        date not null,
    zjbd_date_in_2        date not null,
    tx_date               date not null,
    ssn                   char(32) not null,
    c                     char(32) not null,
    psp_c                 char(32) not null,
    cust_proto            char(32) not null,
    bfee_th               bigint not null,
    bfee_1_th             bigint not null,
    bfee_2_th             bigint not null,
    cfee_th               bigint not null,
    psp_amt_th            bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0017.id                   is '原始凭证id';
comment on column yspz_0017.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0017.bfj_acct_1           is '银行成本1备付金银行账号';
comment on column yspz_0017.bfj_acct_2           is '银行成本2备付金银行账号';
comment on column yspz_0017.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0017.bi                   is '银行接口编号';
comment on column yspz_0017.wlzj_type            is '往来类型 - 客户手续费';
comment on column yspz_0017.p                    is '产品类型';
comment on column yspz_0017.period               is '会计期间';
comment on column yspz_0017.zjbd_date_out        is '本金备付金银行出账日期';
comment on column yspz_0017.zjbd_date_in_1       is '银行成本1备付金银行入账日期';
comment on column yspz_0017.zjbd_date_in_2       is '银行成本2备付金银行入账日期';
comment on column yspz_0017.tx_date              is '交易日期';
comment on column yspz_0017.ssn                  is '交易流水编号';
comment on column yspz_0017.c                    is '客户编号';
comment on column yspz_0017.psp_c                is '分润客户编号';
comment on column yspz_0017.cust_proto           is '分润客户协议编号';
comment on column yspz_0017.bfee_th              is '退回银联银行成本数额';
comment on column yspz_0017.bfee_1_th            is '退回银行成本1备付金扣金额';
comment on column yspz_0017.bfee_2_th            is '退回银行成本2备付金扣金额';
comment on column yspz_0017.cfee_th              is '退回备付金扣客户手续费金额';
comment on column yspz_0017.psp_amt_th           is '退回备付金扣实时分润金额';

comment on column yspz_0017.flag                 is '撤销标志';
comment on column yspz_0017.revoke_cause         is '撤销原因';
comment on column yspz_0017.ts_revoke            is '撤销时间';
comment on column yspz_0017.revoke_user          is '撤销者';
comment on column yspz_0017.memo                 is '说明';
comment on column yspz_0017.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0017;
create sequence seq_yspz_0017 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

