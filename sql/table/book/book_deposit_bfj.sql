-- 
-- 1002.01 : 银行存款-备付金存款
--
drop table book_deposit_bfj;
create table book_deposit_bfj (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    bfj_acct              integer not null,
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

comment on table book_deposit_bfj            is '银行存款-备付金存款';
-- 核算项字典comment见 dict_book.sql
comment on column book_deposit_bfj.ys_type   is '原始凭证类型';
comment on column book_deposit_bfj.ys_id     is '原始凭证ID';
comment on column book_deposit_bfj.jzpz_id   is '原始凭证类型';
comment on column book_deposit_bfj.ts_c      is '创建时间';

-- id序列
drop sequence seq_deposit_bfj;
create sequence seq_deposit_bfj as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_deposit_bfj as (
    select bfj_acct as bfj_acct,
        period as period,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_deposit_bfj
    group by bfj_acct, period
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_deposit_bfj materialized query immediate unchecked;

