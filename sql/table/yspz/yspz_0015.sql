--
-- 基金线-备付金账户间资金划拨
--
drop table yspz_0015;
create table yspz_0015 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct_in           integer not null,
    bfj_acct_out          integer not null,
    zjbd_type             integer not null,
    period                date not null,
    zjbd_date_out         date not null,
    zjbd_date_in          date not null,
    zjhb_amt              bigint not null,
    bfj_bfee              bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0015.id                   is '原始配置id';
comment on column yspz_0015.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0015.bfj_acct_in          is '入款备付金银行账号';
comment on column yspz_0015.bfj_acct_out         is '出款备付金银行账号';
comment on column yspz_0015.zjbd_type            is '资金变动类型 - 资金调拨';
comment on column yspz_0015.period               is '会计期间';
comment on column yspz_0015.zjbd_date_out        is '出款备付金银行出账日期';
comment on column yspz_0015.zjbd_date_in         is '入款备付金银行入账日期';
comment on column yspz_0015.zjhb_amt             is '资金划拨金额';
comment on column yspz_0015.bfj_bfee             is '备付金银行手续费金额';

comment on column yspz_0015.flag                 is '撤销标志';
comment on column yspz_0015.revoke_cause         is '撤销原因';
comment on column yspz_0015.ts_revoke            is '撤销时间';
comment on column yspz_0015.revoke_user          is '撤销者';
comment on column yspz_0015.memo                 is '说明';
comment on column yspz_0015.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0015;
create sequence seq_yspz_0015 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

