--
--
--
--
--
drop table dict_dim;
create table dict_dim (
    dim          char(30)      not null,
    name         varchar(64)   not null,
    memo         varchar(128),
    ts_c         timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

--
-- 核算项字典表
--
comment on table  dict_dim               is '核算项字典表';
comment on column dict_dim.dim 	         is '核算项';
comment on column dict_dim.name          is '核算项中文名';
comment on column dict_dim.memo          is '核算项描述';

insert into dict_dim(dim, name) values
( 'acct', '资金账号， 包括自有资金与备付金账号' ),
( 'bfj_acct', '备付金账号id' ),
( 'bi', '银行接口编号' ),
( 'c', '客户id' ),
( 'cust_proto', '客户协议' ),
( 'e_date', '差错日期' ),
( 'fp', '周期确认规则' ),
( 'p', '产品id' ),
( 'period', '期间日期' ),
( 'tx_date', '交易日期' ),
( 'wlzj_type', '往来资金类型' ),
( 'zjbd_date', '资金变动日期' ),
( 'zjbd_type', '资金变动类型' ),
( 'zyzj_acct', '自有资金账号id' );
