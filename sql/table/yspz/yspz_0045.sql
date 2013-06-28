--
-- POS收款勾兑不成功
--
drop table yspz_0045;
create table yspz_0045 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_bj           integer not null,
    bfj_acct_1            integer not null,
    bfj_acct_2            integer not null,
    bfj_acct_3            integer not null,
    bi                    integer not null,
    tx_type               integer not null,
    p                     integer not null,
    fp                    integer not null,
    period                date not null,
    zjbd_date_in          date not null,
    zjbd_date_out_1       date not null,
    zjbd_date_out_2       date not null,
    zjbd_date_out_3       date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
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


comment on column yspz_0045.id                   is '原始凭证id';
comment on column yspz_0045.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0045.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0045.bfj_acct_1           is '银行成本1备付金银行账号';
comment on column yspz_0045.bfj_acct_2           is '银行成本2备付金银行账号';
comment on column yspz_0045.bfj_acct_3           is '银行成本3备付金银行账号';
comment on column yspz_0045.bi                   is '银行接口编号';
comment on column yspz_0045.tx_type              is '交易类型';
comment on column yspz_0045.p                    is '产品类型';
comment on column yspz_0045.fp                   is '确认规则';
comment on column yspz_0045.period               is '会计期间';
comment on column yspz_0045.zjbd_date_in         is '本金备付金银行入账日期';
comment on column yspz_0045.zjbd_date_out_1      is '银行成本1备付金银行出账日期';
comment on column yspz_0045.zjbd_date_out_2      is '银行成本2备付金银行出账日期';
comment on column yspz_0045.zjbd_date_out_3      is '银行成本3备付金银行出账日期';
comment on column yspz_0045.tx_date              is '交易日期';
comment on column yspz_0045.ssn                  is '交易流水编号';
comment on column yspz_0045.wqr_c                is '未确认的客户编号';
comment on column yspz_0045.bfee_1               is '备付金扣银行成本1金额';
comment on column yspz_0045.bfee_2               is '备付金扣银行成本2金额';
comment on column yspz_0045.bfee_3               is '备付金扣银行成本3金额';
comment on column yspz_0045.cwwf_bfee_1          is '财务外付银行成本1金额';
comment on column yspz_0045.cwwf_bfee_2          is '财务外付银行成本2金额';
comment on column yspz_0045.cwwf_bfee_3          is '财务外付银行成本3金额';
comment on column yspz_0045.zg_bfee_1            is '暂估周期确认银行成本1金额';
comment on column yspz_0045.zg_bfee_2            is '暂估周期确认银行成本2金额';
comment on column yspz_0045.zg_bfee_3            is '暂估周期确认银行成本3金额';
comment on column yspz_0045.tx_amt               is '交易金额';

comment on column yspz_0045.flag                 is '撤销标志';
comment on column yspz_0045.revoke_cause         is '撤销原因';
comment on column yspz_0045.ts_revoke            is '撤销时间';
comment on column yspz_0045.revoke_user          is '撤销者';
comment on column yspz_0045.memo                 is '说明';
comment on column yspz_0045.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0045;
create sequence seq_yspz_0045 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

