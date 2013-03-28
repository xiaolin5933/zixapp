-- 
-- 1122.02.001 : 应收账款-银行-备付金银行短款
--
drop table book_bsc;
create table book_bsc (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    bfj_acct              integer not null,
    e_date                date not null,
    period                date not null,
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

comment on table book_bsc            is '应收账款-银行-备付金银行短款';
-- 核算项字典comment见 dict_book.sql
comment on column book_bsc.ys_type   is '原始凭证类型';
comment on column book_bsc.ys_id     is '原始凭证ID';
comment on column book_bsc.jzpz_id   is '原始凭证类型';
comment on column book_bsc.ts_c      is '创建时间';

-- id序列
drop sequence seq_bsc;
create sequence seq_bsc as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_bsc as (
    select bfj_acct as bfj_acct,
        e_date as e_date,
        period as period,
        zjbd_type as zjbd_type,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_bsc
    group by bfj_acct, e_date, period, zjbd_type
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_bsc materialized query immediate unchecked;

