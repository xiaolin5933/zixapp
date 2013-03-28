-- 
-- 产品id
--
drop table dim_p;
create table dim_p (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    name                  char(32),
    memo                  varchar(512),

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_p                      is '产品id';
comment on column dim_p.id                   is 'id';

comment on column dim_p.name                 is '产品名称';
comment on column dim_p.memo                 is '备注';

comment on column dim_p.ts_c                 is '创建时间';

--
-- 初始化
--
-- zark begin
insert into dim_p(id, name) values
( 1, 'pos收单');
-- zark end
