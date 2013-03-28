-- 
-- 备付金账号id
--
drop table dim_bfj_acct;
create table dim_bfj_acct (

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

comment on table  dim_bfj_acct                      is '备付金账号id';
comment on column dim_bfj_acct.id                   is 'id';

comment on column dim_bfj_acct.b_acct               is '备付金银行账号';
comment on column dim_bfj_acct.acct_name            is '开户人名称';
comment on column dim_bfj_acct.b_name               is '开户银行名称';
comment on column dim_bfj_acct.memo                 is '备注';

comment on column dim_bfj_acct.ts_c                 is '创建时间';

--
-- 初始化
--
