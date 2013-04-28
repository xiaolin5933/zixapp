--
-- 基金线资金对账银行少付（银行短款）
--
drop table yspz_0012;
create table yspz_0012 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct              integer,
    zyzj_acct             integer,
    bfj_zjbd_type         integer,
    zyzj_zjbd_type        integer,
    period                date not null,
    zjbd_date_out_bfj     date,
    zjbd_date_in_bfj      date,
    e_date_bfj            date,
    zjbd_date_out_zyzj    date,
    zjbd_date_in_zyzj     date,
    e_date_zyzj           date,
    yhys_txamt            bigint not null,
    yhys_bamt             bigint not null,
    yhys_bfee             bigint not null,
    yhyf_txamt            bigint not null,
    yhyf_bamt             bigint not null,
    yhyf_bfee             bigint not null,
    bfj_bsc               bigint,
    zyzj_bsc              bigint,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0012.id                   is '原始凭证id';
comment on column yspz_0012.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0012.bfj_acct             is '备付金银行账号';
comment on column yspz_0012.zyzj_acct            is '自有资金银行账号';
comment on column yspz_0012.bfj_zjbd_type        is '备付金资金变动类型';
comment on column yspz_0012.zyzj_zjbd_type       is '自有资金资金变动类型';
comment on column yspz_0012.period               is '会计期间';
comment on column yspz_0012.zjbd_date_out_bfj    is '备付金银行出账日期';
comment on column yspz_0012.zjbd_date_in_bfj     is '备付金银行入账日期';
comment on column yspz_0012.e_date_bfj           is '备付金银行差错日期';
comment on column yspz_0012.zjbd_date_out_zyzj   is '自有资金银行出账日期';
comment on column yspz_0012.zjbd_date_in_zyzj    is '自有资金银行入账日期';
comment on column yspz_0012.e_date_zyzj          is '自有资金银行差错日期';
comment on column yspz_0012.yhys_txamt           is '已核应收交易款借方汇总';
comment on column yspz_0012.yhys_bamt            is '已核应收银行款借方汇总';
comment on column yspz_0012.yhys_bfee            is '已核应收银行手续费借方汇总';
comment on column yspz_0012.yhyf_txamt           is '已核应付交易款贷方汇总';
comment on column yspz_0012.yhyf_bamt            is '已核应付银行款贷方汇总';
comment on column yspz_0012.yhyf_bfee            is '已核应付银行手续费贷方汇总';
comment on column yspz_0012.bfj_bsc              is '备付金银行短款金额';
comment on column yspz_0012.zyzj_bsc             is '自有资金银行短款金额';

comment on column yspz_0012.flag                 is '撤销标志';
comment on column yspz_0012.revoke_cause         is '撤销原因';
comment on column yspz_0012.ts_revoke            is '撤销时间';
comment on column yspz_0012.revoke_user          is '撤销者';
comment on column yspz_0012.memo                 is '说明';
comment on column yspz_0012.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0012;
create sequence seq_yspz_0012 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

