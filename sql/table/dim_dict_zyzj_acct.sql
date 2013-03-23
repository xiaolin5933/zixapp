--
--
--
--
--
drop table dim_dict_zyzj_acct;
create table dim_dict_zyzj_acct (
-- primary key
    id                  integer  primary key not null,

    b_acct              char(32)             not null,
    acct_name           varchar(128)         not null,
    b_name              varchar(128)         not null,
    remark              varchar(1024),
    
-- mis
    ts_c                timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 自有资金账户信息
--

comment on table   dim_dict_zyzj_acct               is '自有资金账户信息';
comment on column  dim_dict_zyzj_acct.id            is 'id';
comment on column  dim_dict_zyzj_acct.b_acct        is '自有资金银行账号';
comment on column  dim_dict_zyzj_acct.acct_name     is '开户人名称';
comment on column  dim_dict_zyzj_acct.b_name        is '开户银行名称';
comment on column  dim_dict_zyzj_acct.remark        is '自有资金银行账号备注信息';


-- data
insert into dim_dict_zyzj_acct(id, b_acct, acct_name, b_name, remark) values
       (1,  '002477419700010',         '北京通融通信息技术有限公司', '包商银行北京分行',       '目前没用');
