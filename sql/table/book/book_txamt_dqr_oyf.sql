-- 
-- 2241.01 : 其他应付款-待确认交易款
--
drop table book_txamt_dqr_oyf;
create table book_txamt_dqr_oyf (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    bi                    integer not null,
    period                date not null,
    tx_date               date not null,
  
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

comment on table book_txamt_dqr_oyf            is '其他应付款-待确认交易款';
-- 核算项字典comment见 dict_book.sql
comment on column book_txamt_dqr_oyf.ys_type   is '原始凭证类型';
comment on column book_txamt_dqr_oyf.ys_id     is '原始凭证ID';
comment on column book_txamt_dqr_oyf.jzpz_id   is '原始凭证类型';
comment on column book_txamt_dqr_oyf.ts_c      is '创建时间';

-- id序列
drop sequence seq_txamt_dqr_oyf;
create sequence seq_txamt_dqr_oyf as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_txamt_dqr_oyf as (
    select bi as bi,
        period as period,
        tx_date as tx_date,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_txamt_dqr_oyf
    group by bi, period, tx_date
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_txamt_dqr_oyf materialized query immediate unchecked;

