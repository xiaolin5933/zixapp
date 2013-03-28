-- 
-- 1002.02 : 银行存款-自有资金存款
--
drop table book_deposit_zyzj;
create table book_deposit_zyzj (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    period                date not null,
    zyzj_acct             integer not null,
  
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

comment on table book_deposit_zyzj            is '银行存款-自有资金存款';
-- 核算项字典comment见 dict_book.sql
comment on column book_deposit_zyzj.ys_type   is '原始凭证类型';
comment on column book_deposit_zyzj.ys_id     is '原始凭证ID';
comment on column book_deposit_zyzj.jzpz_id   is '原始凭证类型';
comment on column book_deposit_zyzj.ts_c      is '创建时间';

-- id序列
drop sequence seq_deposit_zyzj;
create sequence seq_deposit_zyzj as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_deposit_zyzj as (
    select period as period,
        zyzj_acct as zyzj_acct,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_deposit_zyzj
    group by period, zyzj_acct
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_deposit_zyzj materialized query immediate unchecked;

