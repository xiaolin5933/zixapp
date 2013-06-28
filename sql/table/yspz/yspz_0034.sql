--
-- POS收款勾兑成(我有银无，银行追回)
--
drop table yspz_0034;
create table yspz_0034 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_1            integer,
    bfj_acct_2            integer,
    bfj_acct_3            integer,
    bfj_acct_bj           integer not null,
    bi                    integer not null,
    tx_type               integer not null,
    p                     integer not null,
    fp                    integer not null,
    period                date not null,
    e_date                date not null,
    tx_date               date not null,
    zjbd_date_out_1       date,
    zjbd_date_out_2       date,
    zjbd_date_out_3       date,
    c                     char(32) not null,
    ssn                   char(32) not null unique,
    bfee_1                bigint not null,
    bfee_2                bigint not null,
    bfee_3                bigint not null,
    cwwf_bfee_1           bigint not null,
    cwwf_bfee_2           bigint not null,
    cwwf_bfee_3           bigint not null,
    cc_bfee_1             bigint not null,
    cc_bfee_2             bigint not null,
    cc_bfee_3             bigint not null,
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


comment on column yspz_0034.id                   is '原始凭证id';
comment on column yspz_0034.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0034.bfj_acct_1           is '银行成本1备付金银行账号';
comment on column yspz_0034.bfj_acct_2           is '银行成本2备付金银行账号';
comment on column yspz_0034.bfj_acct_3           is '银行成本3备付金银行账号';
comment on column yspz_0034.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0034.bi                   is '银行接口编号';
comment on column yspz_0034.tx_type              is '交易类型';
comment on column yspz_0034.p                    is '产品类型';
comment on column yspz_0034.fp                   is '确认规则';
comment on column yspz_0034.period               is '会计期间';
comment on column yspz_0034.e_date               is '差错日期';
comment on column yspz_0034.tx_date              is '交易日期';
comment on column yspz_0034.zjbd_date_out_1      is '银行成本1备付金银行出账日期';
comment on column yspz_0034.zjbd_date_out_2      is '银行成本2备付金银行出账日期';
comment on column yspz_0034.zjbd_date_out_3      is '银行成本3备付金银行出账日期';
comment on column yspz_0034.c                    is '客户编号';
comment on column yspz_0034.ssn                  is '交易流水编号';
comment on column yspz_0034.bfee_1               is '备付金扣银行成本1金额';
comment on column yspz_0034.bfee_2               is '备付金扣银行成本2金额';
comment on column yspz_0034.bfee_3               is '备付金扣银行成本3金额';
comment on column yspz_0034.cwwf_bfee_1          is '财务外付银行成本1金额';
comment on column yspz_0034.cwwf_bfee_2          is '财务外付银行成本2金额';
comment on column yspz_0034.cwwf_bfee_3          is '财务外付银行成本3金额';
comment on column yspz_0034.cc_bfee_1            is '暂估周期确认银行成本1金额';
comment on column yspz_0034.cc_bfee_2            is '暂估周期确认银行成本2金额';
comment on column yspz_0034.cc_bfee_3            is '暂估周期确认银行成本3金额';
comment on column yspz_0034.tx_amt               is '收款金额';

comment on column yspz_0034.flag                 is '撤销标志';
comment on column yspz_0034.revoke_cause         is '撤销原因';
comment on column yspz_0034.ts_revoke            is '撤销时间';
comment on column yspz_0034.revoke_user          is '撤销者';
comment on column yspz_0034.memo                 is '说明';
comment on column yspz_0034.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0034;
create sequence seq_yspz_0034 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

