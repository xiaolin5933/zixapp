--
-- 成功出款请求
--
drop table yspz_0028;
create table yspz_0028 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    wlzj_type             integer not null,
    p                     integer not null,
    period                date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
    c                     char(32) not null,
    cust_proto            char(32) not null,
    cfee                  bigint,
    cfee_back             bigint,
    cwws_cfee             bigint,
    cwws_cfee_back        bigint,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0028.id                   is '原始凭证id';
comment on column yspz_0028.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0028.wlzj_type            is '往来类型 - 客户手续费';
comment on column yspz_0028.p                    is '产品类型 - 结算';
comment on column yspz_0028.period               is '会计期间';
comment on column yspz_0028.tx_date              is '交易日期';
comment on column yspz_0028.ssn                  is '交易流水编号';
comment on column yspz_0028.c                    is '客户编号';
comment on column yspz_0028.cust_proto           is '客户协议编号';
comment on column yspz_0028.cfee                 is '备付金内扣客户手续费金额';
comment on column yspz_0028.cfee_back            is '退回备付金内扣客户手续费金额';
comment on column yspz_0028.cwws_cfee            is '财务外收客户手续费金额';
comment on column yspz_0028.cwws_cfee_back       is '退回财务外收客户手续费金额';

comment on column yspz_0028.flag                 is '撤销标志';
comment on column yspz_0028.revoke_cause         is '撤销原因';
comment on column yspz_0028.ts_revoke            is '撤销时间';
comment on column yspz_0028.revoke_user          is '撤销者';
comment on column yspz_0028.memo                 is '说明';
comment on column yspz_0028.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0028;
create sequence seq_yspz_0028 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

