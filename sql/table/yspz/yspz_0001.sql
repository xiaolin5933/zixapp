--
-- 基金行业线-备付金内扣成本补充
--
drop table yspz_0001;
create table yspz_0001 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct              integer not null,
    zjbd_type             integer not null,
    zyzj_acct             integer not null,
    period                date not null,
    zjbd_date_in          date not null,
    zjbd_date_out         date not null,
    zjhb_amt              bigint not null,
    zyzj_bfee             bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0001.id                   is '原始凭证id';
comment on column yspz_0001.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0001.bfj_acct             is '备付金银行账号';
comment on column yspz_0001.zjbd_type            is '资金变动类型 - 资金调拨';
comment on column yspz_0001.zyzj_acct            is '自有资金银行账号';
comment on column yspz_0001.period               is '会计期间';
comment on column yspz_0001.zjbd_date_in         is '备付金银行入账日期';
comment on column yspz_0001.zjbd_date_out        is '自有资金银行出账日期';
comment on column yspz_0001.zjhb_amt             is '资金划拨金额';
comment on column yspz_0001.zyzj_bfee            is '自有资金银行手续手续费';

comment on column yspz_0001.flag                 is '撤销标志';
comment on column yspz_0001.revoke_cause         is '撤销原因';
comment on column yspz_0001.ts_revoke            is '撤销时间';
comment on column yspz_0001.revoke_user          is '撤销者';
comment on column yspz_0001.memo                 is '说明';
comment on column yspz_0001.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0001;
create sequence seq_yspz_0001 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

