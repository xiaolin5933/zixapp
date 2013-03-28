-- 
-- 1122.02.002 : 应收账款-银行-自有资金银行短款
--
drop table book_bsc_zyzj;
create table book_bsc_zyzj (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    e_date                date not null,
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

comment on table book_bsc_zyzj            is '应收账款-银行-自有资金银行短款';
-- 核算项字典comment见 dict_book.sql
comment on column book_bsc_zyzj.ys_type   is '原始凭证类型';
comment on column book_bsc_zyzj.ys_id     is '原始凭证ID';
comment on column book_bsc_zyzj.jzpz_id   is '原始凭证类型';
comment on column book_bsc_zyzj.ts_c      is '创建时间';

-- id序列
drop sequence seq_bsc_zyzj;
create sequence seq_bsc_zyzj as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_bsc_zyzj as (
    select e_date as e_date,
        period as period,
        zyzj_acct as zyzj_acct,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_bsc_zyzj
    group by e_date, period, zyzj_acct
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_bsc_zyzj materialized query immediate unchecked;

