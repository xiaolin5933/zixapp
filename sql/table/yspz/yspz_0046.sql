--
-- POS收款勾兑不成功（银有我无，客户补单）
--
drop table yspz_0046;
create table yspz_0046 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bi                    integer not null,
    tx_type               integer not null,
    wlzj_type             integer not null,
    p                     integer not null,
    fp                    integer not null,
    period                date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
    c                     char(32) not null,
    cust_proto            char(32) not null,
    wqr_c                 char(32) not null,
    bfee_1                bigint not null,
    bfee_2                bigint not null,
    bfee_3                bigint not null,
    cwwf_bfee_1           bigint not null,
    cwwf_bfee_2           bigint not null,
    cwwf_bfee_3           bigint not null,
    zg_bfee_1             bigint not null,
    zg_bfee_2             bigint not null,
    zg_bfee_3             bigint not null,
    cfee                  bigint not null,
    cwws_cfee             bigint not null,
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


comment on column yspz_0046.id                   is '原始凭证id';
comment on column yspz_0046.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0046.bi                   is '银行接口编号';
comment on column yspz_0046.tx_type              is '交易类型';
comment on column yspz_0046.wlzj_type            is '往来资金类型 - 客户手续费';
comment on column yspz_0046.p                    is '产品类型';
comment on column yspz_0046.fp                   is '确认规则';
comment on column yspz_0046.period               is '会计期间';
comment on column yspz_0046.tx_date              is '交易日期';
comment on column yspz_0046.ssn                  is '交易流水编号';
comment on column yspz_0046.c                    is '客户编号';
comment on column yspz_0046.cust_proto           is '客户协议编号';
comment on column yspz_0046.wqr_c                is '未确认的客户编号';
comment on column yspz_0046.bfee_1               is '备付金内扣银行成本1金额';
comment on column yspz_0046.bfee_2               is '备付金内扣银行成本2金额';
comment on column yspz_0046.bfee_3               is '备付金内扣银行成本3金额';
comment on column yspz_0046.cwwf_bfee_1          is '财务外付银行成本1金额';
comment on column yspz_0046.cwwf_bfee_2          is '财务外付银行成本2金额';
comment on column yspz_0046.cwwf_bfee_3          is '财务外付银行成本3金额';
comment on column yspz_0046.zg_bfee_1            is '暂估周期确认银行成本1金额';
comment on column yspz_0046.zg_bfee_2            is '暂估周期确认银行成本2金额';
comment on column yspz_0046.zg_bfee_3            is '暂估周期确认银行成本3金额';
comment on column yspz_0046.cfee                 is '备付金内扣客户手续费金额';
comment on column yspz_0046.cwws_cfee            is '财务外收客户手续费金额';
comment on column yspz_0046.tx_amt               is '收款金额';

comment on column yspz_0046.flag                 is '撤销标志';
comment on column yspz_0046.revoke_cause         is '撤销原因';
comment on column yspz_0046.ts_revoke            is '撤销时间';
comment on column yspz_0046.revoke_user          is '撤销者';
comment on column yspz_0046.memo                 is '说明';
comment on column yspz_0046.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0046;
create sequence seq_yspz_0046 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

