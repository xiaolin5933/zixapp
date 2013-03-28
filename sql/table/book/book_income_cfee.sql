-- 
-- 6021.01 : 收入-客户手续费收入
--
drop table book_income_cfee;
create table book_income_cfee (
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

comment on table book_income_cfee            is '收入-客户手续费收入';
-- 核算项字典comment见 dict_book.sql
comment on column book_income_cfee.ys_type   is '原始凭证类型';
comment on column book_income_cfee.ys_id     is '原始凭证ID';
comment on column book_income_cfee.jzpz_id   is '原始凭证类型';
comment on column book_income_cfee.ts_c      is '创建时间';

-- id序列
drop sequence seq_income_cfee;
create sequence seq_income_cfee as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_income_cfee as (
    select c as c,
        p as p,
        period as period,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_income_cfee
    group by c, p, period
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_income_cfee materialized query immediate unchecked;

