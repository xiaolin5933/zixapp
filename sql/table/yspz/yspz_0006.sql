--
-- 基金线-委托收款勾兑不成功（银有我无，补付客户备付金）
--
drop table yspz_0006;
create table yspz_0006 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    ssn                   char(32) not null,
    bi                    integer not null,
    p                     integer not null,
    yqr_c                 char(32),
    wqr_c                 char(32) not null,
    period                date not null,
    tx_date               date not null,
    tx_amt                bigint not null,
    bfee                  bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0006.id                   is '原始凭证id';
comment on column yspz_0006.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0006.ssn                  is '交易流水编号';
comment on column yspz_0006.bi                   is '银行接口编号';
comment on column yspz_0006.p                    is '产品类型 - 基金收款';
comment on column yspz_0006.yqr_c                is '已确认的委托收款客户编号';
comment on column yspz_0006.wqr_c                is '无法确认的委托收款客户编号';
comment on column yspz_0006.period               is '会计期间';
comment on column yspz_0006.tx_date              is '交易日期';
comment on column yspz_0006.tx_amt               is '支付金额';
comment on column yspz_0006.bfee                 is '确认的银行手续费';

comment on column yspz_0006.flag                 is '撤销标志';
comment on column yspz_0006.revoke_cause         is '撤销原因';
comment on column yspz_0006.ts_revoke            is '撤销时间';
comment on column yspz_0006.revoke_user          is '撤销者';
comment on column yspz_0006.memo                 is '说明';
comment on column yspz_0006.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0006;
create sequence seq_yspz_0006 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

