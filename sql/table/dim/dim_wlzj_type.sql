-- 
-- 往来资金类型
--
drop table dim_wlzj_type;
create table dim_wlzj_type (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    name                  char(32),
    memo                  varchar(512),

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_wlzj_type                      is '往来资金类型';
comment on column dim_wlzj_type.id                   is 'id';

comment on column dim_wlzj_type.name                 is '往来资金类型名称';
comment on column dim_wlzj_type.memo                 is '备注';

comment on column dim_wlzj_type.ts_c                 is '创建时间';

--
-- 初始化
--
-- zark begin
insert into dim_wlzj_type(id, name) values
(1, '客户手续费'),
(2, '利息收入');
-- zark end
