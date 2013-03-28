-- 
-- 6603.01 : 财务费用-账户利息收入
--
drop table book_income_zhlx;
create table book_income_zhlx (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    acct                  integer not null,
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

comment on table book_income_zhlx            is '财务费用-账户利息收入';
-- 核算项字典comment见 dict_book.sql
comment on column book_income_zhlx.ys_type   is '原始凭证类型';
comment on column book_income_zhlx.ys_id     is '原始凭证ID';
comment on column book_income_zhlx.jzpz_id   is '原始凭证类型';
comment on column book_income_zhlx.ts_c      is '创建时间';

-- id序列
drop sequence seq_income_zhlx;
create sequence seq_income_zhlx as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_income_zhlx as (
    select acct as acct,
        period as period,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_income_zhlx
    group by acct, period
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_income_zhlx materialized query immediate unchecked;

