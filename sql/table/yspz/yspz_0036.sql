--
-- POS收款勾兑成功(我有银无,确认损失)
--
drop table yspz_0036;
create table yspz_0036 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bi                    integer not null,
    tx_type               integer not null,
    p                     integer not null,
    period                date not null,
    tx_date               date not null,
    ssn                   char(32) not null unique,
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


comment on column yspz_0036.id                   is '原始凭证id';
comment on column yspz_0036.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0036.bi                   is '银行接口编号';
comment on column yspz_0036.tx_type              is '交易类型';
comment on column yspz_0036.p                    is '产品类型';
comment on column yspz_0036.period               is '会计期间';
comment on column yspz_0036.tx_date              is '交易日期';
comment on column yspz_0036.ssn                  is '交易流水编号';
comment on column yspz_0036.tx_amt               is '收款损失金额';

comment on column yspz_0036.flag                 is '撤销标志';
comment on column yspz_0036.revoke_cause         is '撤销原因';
comment on column yspz_0036.ts_revoke            is '撤销时间';
comment on column yspz_0036.revoke_user          is '撤销者';
comment on column yspz_0036.memo                 is '说明';
comment on column yspz_0036.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0036;
create sequence seq_yspz_0036 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

