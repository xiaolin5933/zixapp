-- 
-- 6422 : 内部成本
--
drop table book_cost_in;
create table book_cost_in (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    c                     char(32) not null,
    p                     integer not null,
    period                date not null,
  
    -- 记账数据
    j                     bigint default 0 not null,
    d                     bigint default 0 not null,

    -- 记账凭证关联数据
    ys_type               char(4) not null,
    ys_id                 bigint  not null,
    jzpz_id               bigint  not null,
    
    -- 创建时间戳
    ts_c	          timestamp default current timestamp
);

comment on table book_cost_in            is '内部成本';
-- 核算项字典comment见 dict_book.sql
comment on column book_cost_in.ys_type   is '原始凭证类型';
comment on column book_cost_in.ys_id     is '原始凭证ID';
comment on column book_cost_in.jzpz_id   is '原始凭证类型';
comment on column book_cost_in.ts_c      is '创建时间';

-- id序列
drop sequence seq_cost_in;
create sequence seq_cost_in as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_cost_in as (
    select c as c,
        p as p,
        period as period,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_cost_in
    group by c, p, period
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_cost_in materialized query immediate unchecked;

