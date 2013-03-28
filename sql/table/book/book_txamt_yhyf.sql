-- 
-- 2005.01 : 应付银行-已核应付交易款
--
drop table book_txamt_yhyf;
create table book_txamt_yhyf (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    bfj_acct              integer not null,
    period                date not null,
    zjbd_date             date not null,
    zjbd_type             integer not null,
  
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

comment on table book_txamt_yhyf            is '应付银行-已核应付交易款';
-- 核算项字典comment见 dict_book.sql
comment on column book_txamt_yhyf.ys_type   is '原始凭证类型';
comment on column book_txamt_yhyf.ys_id     is '原始凭证ID';
comment on column book_txamt_yhyf.jzpz_id   is '原始凭证类型';
comment on column book_txamt_yhyf.ts_c      is '创建时间';

-- id序列
drop sequence seq_txamt_yhyf;
create sequence seq_txamt_yhyf as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_txamt_yhyf as (
    select bfj_acct as bfj_acct,
        period as period,
        zjbd_date as zjbd_date,
        zjbd_type as zjbd_type,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_txamt_yhyf
    group by bfj_acct, period, zjbd_date, zjbd_type
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_txamt_yhyf materialized query immediate unchecked;

