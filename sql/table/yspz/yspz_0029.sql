--
-- 勾兑成功出款
--
drop table yspz_0029;
create table yspz_0029 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_bj           integer not null,
    bfj_acct              integer not null,
    bi                    integer not null,
    p                     integer not null,
    fp                    integer not null,
    tx_type               integer not null,
    period                date not null,
    zjbd_date_out_bj      date not null,
    zjbd_date_out         date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
    c                     char(32) not null,
    bfee                  bigint not null,
    cwwf_bfee             bigint not null,
    zg_bfee               bigint not null,
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


comment on column yspz_0029.id                   is '原始凭证id';
comment on column yspz_0029.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0029.bfj_acct_bj          is '本金备付金银行账号';
comment on column yspz_0029.bfj_acct             is '备付金内扣银行账号';
comment on column yspz_0029.bi                   is '银行接口编号';
comment on column yspz_0029.p                    is '产品类型 - 结算';
comment on column yspz_0029.fp                   is '确认规则';
comment on column yspz_0029.tx_type              is '交易类型';
comment on column yspz_0029.period               is '会计期间';
comment on column yspz_0029.zjbd_date_out_bj     is '本金备付金银行出账日期';
comment on column yspz_0029.zjbd_date_out        is '备付金内扣银行出账日期';
comment on column yspz_0029.tx_date              is '交易日期';
comment on column yspz_0029.ssn                  is '交易流水编号';
comment on column yspz_0029.c                    is '客户编号';
comment on column yspz_0029.bfee                 is '备付金内扣银行手续费金额';
comment on column yspz_0029.cwwf_bfee            is '财务外付银行手续费金额';
comment on column yspz_0029.zg_bfee              is '暂估银行手续费金额';
comment on column yspz_0029.tx_amt               is '出款金额';

comment on column yspz_0029.flag                 is '撤销标志';
comment on column yspz_0029.revoke_cause         is '撤销原因';
comment on column yspz_0029.ts_revoke            is '撤销时间';
comment on column yspz_0029.revoke_user          is '撤销者';
comment on column yspz_0029.memo                 is '说明';
comment on column yspz_0029.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0029;
create sequence seq_yspz_0029 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

