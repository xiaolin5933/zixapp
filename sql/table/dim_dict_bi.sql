--
--
--
--
--
drop table dim_dict_bi;
create table dim_dict_bi (
    id          integer       not null primary key,
    name        varchar(128)  not null,
    memo        varchar(128),
    ts_c                timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

--
-- 银行接口
--

comment on table  dim_dict_bi           is '银行接口';
comment on column dim_dict_bi.id        is 'id';
comment on column dim_dict_bi.name      is '银行接口名称';
comment on column dim_dict_bi.memo      is '银行接口说明';


