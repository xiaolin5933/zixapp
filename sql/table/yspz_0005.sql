drop table yspz_0005;
create table yspz_0005 (

-- id
-- 处理状态

    id                   bigint primary key not null,
    status               char(1),   
    
--- tp  : 
    period               date       not null,

--- book
    ssn                  char(22)   not null,
    bfj_acct_bj          integer    not null,
    zjbd_date_in         date       not null, 
    bi                   integer    not null,
    tx_date              date       not null,
    c                    integer    not null,
    p                    integer    not null,
    tx_amt               bigint     not null,
    bfj_bfee             bigint     not null,
    bfj_acct_bfee        integer    not null,
    zjbd_date_out        date       not null,
    cwwf_cfee            bigint     not null,
    
    

-- revoke-concerned
    flag                 char(1),
    revoke_cause         varchar(512),
    revoke_user          int,
    ts_revoke            timestamp,

    memo                 varchar(512),
    ts_c                 timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0005.id             is '原始配置id';
comment on column yspz_0005.status         is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';
comment on column yspz_0005.period         is '会计期间';

comment on column yspz_0005.ssn            is '交易流水编号';
comment on column yspz_0005.bfj_acct_bj    is '本金备付金银行账号';
comment on column yspz_0005.zjbd_date_in   is '本金备付金银行入账日期';
comment on column yspz_0005.bi             is '银行接口编号';
comment on column yspz_0005.tx_date        is '交易日期';
comment on column yspz_0005.c              is '客户编号';
comment on column yspz_0005.p              is '产品类型 - 基金收款';
comment on column yspz_0005.tx_amt         is '支付金额';
comment on column yspz_0005.bfj_bfee       is '备付金银行手续费';
comment on column yspz_0005.bfj_acct_bfee  is '备付金银行账号';
comment on column yspz_0005.zjbd_date_out  is '备付金银行出账日期';
comment on column yspz_0005.cwwf_bfee      is '财务外付银行手续费';

comment on column yspz_0005.flag           is '撤销标志';
comment on column yspz_0005.revoke_cause   is '撤销原因';
comment on column yspz_0005.ts_revoke      is '撤销时间';
comment on column yspz_0005.revoke_user    is '撤销者';

comment on column yspz_0005.memo           is '说明';
comment on column yspz_0005.ts_c           is '创建时间';

-- seq

drop sequence seq_yspz_0005;
create sequence seq_yspz_0005 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


