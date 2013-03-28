-- 
-- 2202.01.001 : 应付账款-银行-备份金银行长款
--
drop table book_blc;
create table book_blc (
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

comment on table book_blc            is '应付账款-银行-备份金银行长款';
-- 核算项字典comment见 dict_book.sql
comment on column book_blc.ys_type   is '原始凭证类型';
comment on column book_blc.ys_id     is '原始凭证ID';
comment on column book_blc.jzpz_id   is '原始凭证类型';
comment on column book_blc.ts_c      is '创建时间';

-- id序列
drop sequence seq_blc;
create sequence seq_blc as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_blc as (
    select bfj_acct as bfj_acct,
        e_date as e_date,
        period as period,
        zjbd_type as zjbd_type,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_blc
    group by bfj_acct, e_date, period, zjbd_type
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_blc materialized query immediate unchecked;

