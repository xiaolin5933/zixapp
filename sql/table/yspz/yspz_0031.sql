--
-- 周期确认
--
drop table yspz_0031;
create table yspz_0031 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct              integer,
    bi                    integer not null,
    fp                    integer not null,
    p                     integer not null,
    period                date not null,
    zjbd_date_out         date,
    tx_date               date not null,
    sm_date               date not null,
    cn                    char(32) not null,
    c                     char(32) not null,
    comm                  varchar(512) not null,
    rp_bfee               bigint not null,
    cc_bfee               bigint not null,
    cc_cwwf_bfee          bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0031.id                   is '原始凭证id';
comment on column yspz_0031.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0031.bfj_acct             is '备付金内扣银行账号';
comment on column yspz_0031.bi                   is '银行接口编号';
comment on column yspz_0031.fp                   is '确认规则';
comment on column yspz_0031.p                    is '产品类型';
comment on column yspz_0031.period               is '会计期间';
comment on column yspz_0031.zjbd_date_out        is '备付金内扣银行出账日期';
comment on column yspz_0031.tx_date              is '交易日期';
comment on column yspz_0031.sm_date              is '扫描日期';
comment on column yspz_0031.cn                   is '确认编号';
comment on column yspz_0031.c                    is '客户编号';
comment on column yspz_0031.comm                 is '备注';
comment on column yspz_0031.rp_bfee              is '冲销暂估银行手续费金额';
comment on column yspz_0031.cc_bfee              is '周期确认备付金内扣银行手续费金额';
comment on column yspz_0031.cc_cwwf_bfee         is '周期确认财务外付银行手续费金额';

comment on column yspz_0031.flag                 is '撤销标志';
comment on column yspz_0031.revoke_cause         is '撤销原因';
comment on column yspz_0031.ts_revoke            is '撤销时间';
comment on column yspz_0031.revoke_user          is '撤销者';
comment on column yspz_0031.memo                 is '说明';
comment on column yspz_0031.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0031;
create sequence seq_yspz_0031 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

