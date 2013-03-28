-- 
-- 自有资金账号id
--
drop table dim_zyzj_acct;
create table dim_zyzj_acct (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    b_acct                char(32) not null,
    acct_name             varchar(128) not null,
    b_name                varchar(128) not null,
    memo                  varchar(1024),

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_zyzj_acct                      is '自有资金账号id';
comment on column dim_zyzj_acct.id                   is 'id';

comment on column dim_zyzj_acct.b_acct               is '自有资金银行账号';
comment on column dim_zyzj_acct.acct_name            is '开户人名称';
comment on column dim_zyzj_acct.b_name               is '开户银行名称';
comment on column dim_zyzj_acct.memo                 is '备注';

comment on column dim_zyzj_acct.ts_c                 is '创建时间';

--
-- 初始化
--
-- zark begin
insert into dim_zyzj_acct(id, b_acct, acct_name, b_name) values
(1,  '002477419700010', '北京通融通信息技术有限公司', '包商银行北京分行');
-- zark end
