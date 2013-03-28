-- 
-- 资金账号， 包括自有资金与备付金账号
--
drop table dim_acct;
create table dim_acct (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    sub_type              integer not null,
    sub_id                integer not null,

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_acct                      is '资金账号， 包括自有资金与备付金账号';
comment on column dim_acct.id                   is 'id';

comment on column dim_acct.sub_type             is '账号子类型';
comment on column dim_acct.sub_id               is '子类型ID';

comment on column dim_acct.ts_c                 is '创建时间';

--
-- 初始化
--
-- zark begin
insert into dim_acct(id, sub_type, sub_id) values
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5),
(6, 1, 6),
(7, 1, 7),
(8, 1, 8),
(9, 1, 9),
(10, 1, 10),
(11, 1, 11),
(12, 1, 12),
(10001, 2, 1);
-- zark end
