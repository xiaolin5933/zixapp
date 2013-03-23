--
drop table book_bfee_cwwf;
create table book_bfee_cwwf (

    -- primary key
    id          bigint primary key not null,
    
    -- dimension
    bi       integer  not null,
    tx_date     date     not null,
    -- dimension (tp)
    period      date         not null,
    
    -- jz data
    j       bigint default 0 not null,
    d       bigint default 0 not null,

    -- jzpz 
    ys_type     char(4)      not null,
    ys_id       bigint       not null,
    jzpz_id     bigint       not null,

    
    -- misc
    --rec_c_ts    timestamp default current timestamp
    ts_c        timestamp default current timestamp

) in tbs_dat index in tbs_idx;


drop sequence seq_bfee_cwwf;
create sequence seq_bfee_cwwf as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


--
-- 应付账款-银行-财务外付银行手续费 
--


comment on table  book_bfee_cwwf           is '应付账款-银行-财务外付银行手续费';
comment on column book_bfee_cwwf.id        is '主键';
comment on column book_bfee_cwwf.bi        is '银行接口编号';
comment on column book_bfee_cwwf.tx_date   is '交易日期';
comment on column book_bfee_cwwf.period    is '会计期间';
comment on column book_bfee_cwwf.j         is '借方发生额';




-- MQT
create table sum_bfee_cwwf as (
    select bi	     as bi,
	   tx_date   as tx_date,
	   period     as period,
	   sum(j)    as j,
	   sum(d)    as d,
	   count(*)  as cnt
    from book_bfee_cwwf
    group by bi, tx_date, period
)
data initially deferred refresh immediate
in tbs_dat;


-- integrity unchecked
set integrity for sum_bfee_cwwf materialized query immediate unchecked;
