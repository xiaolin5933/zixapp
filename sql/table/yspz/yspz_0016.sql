--
-- 直联POS代清算收款勾兑成功
--
drop table yspz_0016;
create table yspz_0016 (

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
    wlzj_type             integer not null,
    p                     integer not null,
    period                date not null,
    zjbd_date_in          date not null,
    zjbd_date_out_1       date,
    zjbd_date_out_2       date,
    zjbd_date_out_3       date,
    tx_date               date not null,
    ssn                   char(32) not null unique,
    c                     char(32) not null,
    psp_c                 char(32) not null,
    cust_proto            char(32) not null,
    bfee                  bigint not null,
    bfee_1                bigint not null,
    bfee_2                bigint not null,
    bfee_3                bigint not null,
    lfee                  bigint not null,
    psp_lfee              bigint not null,
    cfee                  bigint not null,
    psp_amt               bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0016.id                   is '原始凭证id';
comment on column yspz_0016.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0016.bfj_acct_1           is '银行成本1备付金银行账号';
comment on column yspz_0016.bfj_acct_2           is '银行成本2备付金银行账号';
comment on column yspz_0016.bfj_acct_3           is '银行成本3备付金银行账号';
comment on column yspz_0016.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0016.bi                   is '银行接口编号';
comment on column yspz_0016.wlzj_type            is '往来类型 - 客户手续费';
comment on column yspz_0016.p                    is '产品类型';
comment on column yspz_0016.period               is '会计期间';
comment on column yspz_0016.zjbd_date_in         is '本金备付金银行入账日期';
comment on column yspz_0016.zjbd_date_out_1      is '银行成本1备付金银行出账日期';
comment on column yspz_0016.zjbd_date_out_2      is '银行成本2备付金银行出账日期';
comment on column yspz_0016.zjbd_date_out_3      is '银行成本3备付金银行出账日期';
comment on column yspz_0016.tx_date              is '交易日期';
comment on column yspz_0016.ssn                  is '交易流水编号';
comment on column yspz_0016.c                    is '客户编号';
comment on column yspz_0016.psp_c                is '分润客户编号';
comment on column yspz_0016.cust_proto           is '分润客户协议编号';
comment on column yspz_0016.bfee                 is '银联银行成本数额';
comment on column yspz_0016.bfee_1               is '银行成本1备付金扣金额';
comment on column yspz_0016.bfee_2               is '银行成本2备付金扣金额';
comment on column yspz_0016.bfee_3               is '银行成本3备付金扣金额';
comment on column yspz_0016.lfee                 is '银联品牌费数额';
comment on column yspz_0016.psp_lfee             is '分润方承担的品牌费';
comment on column yspz_0016.cfee                 is '备付金扣客户手续费收入';
comment on column yspz_0016.psp_amt              is '备付金扣实时分润金额';

comment on column yspz_0016.flag                 is '撤销标志';
comment on column yspz_0016.revoke_cause         is '撤销原因';
comment on column yspz_0016.ts_revoke            is '撤销时间';
comment on column yspz_0016.revoke_user          is '撤销者';
comment on column yspz_0016.memo                 is '说明';
comment on column yspz_0016.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0016;
create sequence seq_yspz_0016 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

