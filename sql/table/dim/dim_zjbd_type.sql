-- 
-- 资金变动类型
--
drop table dim_zjbd_type;
create table dim_zjbd_type (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    name                  char(32),
    memo                  varchar(512),

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_zjbd_type                      is '资金变动类型';
comment on column dim_zjbd_type.id                   is 'id';

comment on column dim_zjbd_type.name                 is '资金变动类型名称';
comment on column dim_zjbd_type.memo                 is '备注';

comment on column dim_zjbd_type.ts_c                 is '创建时间';

--
-- 初始化
--
-- zark begin
insert into dim_zjbd_type(id, name) values
(1, '银行接口编号'),
(2, '账户利息'),
(3, '账户管理费'),
(4, '资金调拨');
-- zark end