-- 
-- 6421.01 : 成本-银行手续费支出
--
drop table book_cost_bfee;
create table book_cost_bfee (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    bi                    integer not null,
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

comment on table book_cost_bfee            is '成本-银行手续费支出';
-- 核算项字典comment见 dict_book.sql
comment on column book_cost_bfee.ys_type   is '原始凭证类型';
comment on column book_cost_bfee.ys_id     is '原始凭证ID';
comment on column book_cost_bfee.jzpz_id   is '原始凭证类型';
comment on column book_cost_bfee.ts_c      is '创建时间';

-- id序列
drop sequence seq_cost_bfee;
create sequence seq_cost_bfee as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_cost_bfee as (
    select bi as bi,
        c as c,
        p as p,
        period as period,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_cost_bfee
    group by bi, c, p, period
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_cost_bfee materialized query immediate unchecked;

