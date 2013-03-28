-- 
-- 2010.01 : 客户备付金-备付金
--
drop table book_bfj_cust;
create table book_bfj_cust (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    c                     char(32) not null,
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

comment on table book_bfj_cust            is '客户备付金-备付金';
-- 核算项字典comment见 dict_book.sql
comment on column book_bfj_cust.ys_type   is '原始凭证类型';
comment on column book_bfj_cust.ys_id     is '原始凭证ID';
comment on column book_bfj_cust.jzpz_id   is '原始凭证类型';
comment on column book_bfj_cust.ts_c      is '创建时间';

-- id序列
drop sequence seq_bfj_cust;
create sequence seq_bfj_cust as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_bfj_cust as (
    select c as c,
        period as period,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_bfj_cust
    group by c, period
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_bfj_cust materialized query immediate unchecked;

