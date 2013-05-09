-- 
-- 1122.01.002 : 应收账款-客户-分润方承担品牌费
--
drop table book_lfee_psp;
create table book_lfee_psp (
    -- 主键
    id                    bigint primary key not null,

    -- 核算项字段(核算项按名称排序)
    c                     char(32) not null,
    cust_proto            char(32) not null,
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

comment on table book_lfee_psp            is '应收账款-客户-分润方承担品牌费';
-- 核算项字典comment见 dict_book.sql
comment on column book_lfee_psp.ys_type   is '原始凭证类型';
comment on column book_lfee_psp.ys_id     is '原始凭证ID';
comment on column book_lfee_psp.jzpz_id   is '原始凭证类型';
comment on column book_lfee_psp.ts_c      is '创建时间';

-- id序列
drop sequence seq_lfee_psp;
create sequence seq_lfee_psp as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

-- MQT表
create table sum_lfee_psp as (
    select c as c,
        cust_proto as cust_proto,
        period as period,
        tx_date as tx_date,
        sum(j)     as j,
        sum(d)     as d,
        count(*)   as cnt
    from book_lfee_psp
    group by c, cust_proto, period, tx_date
)
data initially deferred refresh immediate
in tbs_dat;

-- integrity unchecked
set integrity for sum_lfee_psp materialized query immediate unchecked;

