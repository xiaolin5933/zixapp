-- 
-- 1020.04 : 应收银行-已核应收银行手续费
--
drop table book_bfee_yhys;
create table book_bfee_yhys (
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

comment on table book_bfee_yhys            is '应收银行-已核应收银行手续费';
-- 核算项字典comment见 dict_book.sql
comment on column book_bfee_yhys.ys_type   is '原始凭证类型';
comment on column book_bfee_yhys.ys_id     is '原始凭证ID';
comment on column book_bfee_yhys.jzpz_id   is '原始凭证类型';
comment on column book_bfee_yhys.ts_c      is '创建时间';

-- id序列
drop sequence seq_bfee_yhys;
create sequence seq_bfee_yhys as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_bfee_yhys as (
    select bfj_acct as bfj_acct,
        period as period,
        zjbd_date as zjbd_date,
        zjbd_type as zjbd_type,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_bfee_yhys
    group by bfj_acct, period, zjbd_date, zjbd_type
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_bfee_yhys materialized query immediate unchecked;

