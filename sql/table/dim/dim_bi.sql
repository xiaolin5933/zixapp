-- 
-- 银行接口编号
--
drop table dim_bi;
create table dim_bi (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    type                  char(2),
    name                  varchar(128),
    memo                  varchar(512),

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_bi                      is '银行接口编号';
comment on column dim_bi.id                   is 'id';

comment on column dim_bi.type                 is '银行接口类型. 1 出款; 2 收款; 3 其他';
comment on column dim_bi.name                 is '名称';
comment on column dim_bi.memo                 is '备注';

comment on column dim_bi.ts_c                 is '创建时间';

--
-- 初始化
--
insert into dim_bi(id, type, name, memo) values
(0, '3', '其他', '其他');
