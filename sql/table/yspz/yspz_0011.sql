--
-- 基金线资金对账银行多付（银行长款）
--
drop table yspz_0011;
create table yspz_0011 (

-- id
-- 处理状态
    id                    bigint primary key not null,
    status                char(1) not null,

-- 业务字段
    bfj_acct              integer not null,
    zyzj_acct             integer not null,
    zjbd_type             integer not null,
    zjbd_type_zjdb        integer not null,
    bi                    integer not null,
    period                date not null,
    zjbd_date_out_bfj     date not null,
    zjbd_date_in_bfj      date not null,
    e_date_bfj            date not null,
    zjbd_date_out_zyzj    date not null,
    zjbd_date_in_zyzj     date not null,
    e_date_zyzj           date not null,
    yhys_txamt            bigint not null,
    yhys_bamt             bigint not null,
    yhys_bfee             bigint not null,
    yhyf_txamt            bigint not null,
    yhyf_bamt             bigint not null,
    yhyf_bfee             bigint not null,
    bfj_blc               bigint not null,
    zyzj_blc              bigint not null,

-- revoke-concerned
    flag                  char(1),
    revoke_cause          varchar(512),
    revoke_user           integer,
    ts_revoke             timestamp,

-- 管理字段
    memo                  varchar(512),
    ts_c                  timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 


comment on column yspz_0011.id                   is '原始配置id';
comment on column yspz_0011.status               is '原始凭证处理状态. 0:  未处理   1: 处理成功   2: 处理失败。';

comment on column yspz_0011.bfj_acct             is '备付金银行账号';
comment on column yspz_0011.zyzj_acct            is '自有资金银行账号';
comment on column yspz_0011.zjbd_type            is '资金变动类型';
comment on column yspz_0011.zjbd_type_zjdb       is '资金变动类型 - 资金调拨';
comment on column yspz_0011.bi                   is '银行接口编号';
comment on column yspz_0011.period               is '会计期间';
comment on column yspz_0011.zjbd_date_out_bfj    is '备付金银行出账日期';
comment on column yspz_0011.zjbd_date_in_bfj     is '备付金银行入账日期';
comment on column yspz_0011.e_date_bfj           is '备付金银行差错日期';
comment on column yspz_0011.zjbd_date_out_zyzj   is '自有资金银行出账日期';
comment on column yspz_0011.zjbd_date_in_zyzj    is '自有资金银行入账日期';
comment on column yspz_0011.e_date_zyzj          is '自有资金银行差错日期';
comment on column yspz_0011.yhys_txamt           is '已核应收交易款借方汇总';
comment on column yspz_0011.yhys_bamt            is '已核应收银行款借方汇总';
comment on column yspz_0011.yhys_bfee            is '已核应收银行手续费借方汇总';
comment on column yspz_0011.yhyf_txamt           is '已核应付交易款贷方汇总';
comment on column yspz_0011.yhyf_bamt            is '已核应付银行款贷方汇总';
comment on column yspz_0011.yhyf_bfee            is '已核应付银行手续费贷方汇总';
comment on column yspz_0011.bfj_blc              is '备付金银行长款金额';
comment on column yspz_0011.zyzj_blc             is '自有资金银行长款金额';

comment on column yspz_0011.flag                 is '撤销标志';
comment on column yspz_0011.revoke_cause         is '撤销原因';
comment on column yspz_0011.ts_revoke            is '撤销时间';
comment on column yspz_0011.revoke_user          is '撤销者';
comment on column yspz_0011.memo                 is '说明';
comment on column yspz_0011.ts_c                 is '创建时间';

-- seq

drop sequence seq_yspz_0011;
create sequence seq_yspz_0011 as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

