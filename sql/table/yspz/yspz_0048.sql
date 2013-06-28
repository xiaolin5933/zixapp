--
-- POS收款原接口反向交易勾兑（银有我无）
--
drop table yspz_0048;
create table yspz_0048 (

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
    zjbd_date_out         date not null,
    zjbd_date_in_1        date not null,
    zjbd_date_in_2        date not null,
    zjbd_date_in_3        date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
    wqr_c                 char(32) not null,
    bfee_1_back           bigint not null,
    bfee_2_back           bigint not null,
    bfee_3_back           bigint not null,
    cwwf_bfee_1_back      bigint not null,
    cwwf_bfee_2_back      bigint not null,
    cwwf_bfee_3_back      bigint not null,
    zg_bfee_1_back        bigint not null,
    zg_bfee_2_back        bigint not null,
    zg_bfee_3_back        bigint not null,
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


comment on column yspz_0048.id                   is '原始凭证id';
comment on column yspz_0048.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0048.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0048.bfj_acct_1           is '银行成本1备付金银行账号';
comment on column yspz_0048.bfj_acct_2           is '银行成本2备付金银行账号';
comment on column yspz_0048.bfj_acct_3           is '银行成本3备付金银行账号';
comment on column yspz_0048.bi                   is '银行接口编号';
comment on column yspz_0048.tx_type              is '交易类型';
comment on column yspz_0048.p                    is '产品类型';
comment on column yspz_0048.fp                   is '确认规则';
comment on column yspz_0048.period               is '会计期间';
comment on column yspz_0048.zjbd_date_out        is '本金备付金银行出账日期';
comment on column yspz_0048.zjbd_date_in_1       is '银行成本1备付金银行入账日期';
comment on column yspz_0048.zjbd_date_in_2       is '银行成本2备付金银行入账日期';
comment on column yspz_0048.zjbd_date_in_3       is '银行成本3备付金银行入账日期';
comment on column yspz_0048.tx_date              is '交易日期';
comment on column yspz_0048.ssn                  is '交易流水编号';
comment on column yspz_0048.wqr_c                is '未确认的客户编号';
comment on column yspz_0048.bfee_1_back          is '退回备付金扣银行成本1金额';
comment on column yspz_0048.bfee_2_back          is '退回备付金扣银行成本2金额';
comment on column yspz_0048.bfee_3_back          is '退回备付金扣银行成本3金额';
comment on column yspz_0048.cwwf_bfee_1_back     is '退回财务外付银行成本1金额';
comment on column yspz_0048.cwwf_bfee_2_back     is '退回财务外付银行成本2金额';
comment on column yspz_0048.cwwf_bfee_3_back     is '退回财务外付银行成本3金额';
comment on column yspz_0048.zg_bfee_1_back       is '退回暂估周期确认银行成本1金额';
comment on column yspz_0048.zg_bfee_2_back       is '退回暂估周期确认银行成本2金额';
comment on column yspz_0048.zg_bfee_3_back       is '退回暂估周期确认银行成本3金额';
comment on column yspz_0048.tx_amt               is '收款反向交易金额';

comment on column yspz_0048.flag                 is '撤销标志';
comment on column yspz_0048.revoke_cause         is '撤销原因';
comment on column yspz_0048.ts_revoke            is '撤销时间';
comment on column yspz_0048.revoke_user          is '撤销者';
comment on column yspz_0048.memo                 is '说明';
comment on column yspz_0048.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0048;
create sequence seq_yspz_0048 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

