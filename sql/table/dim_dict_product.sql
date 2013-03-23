--
--
--
--
--
drop table dim_dict_product;
create table dim_dict_product (
    id                  integer       not null primary key,
    p_num               char(18)      not null,
    name                varchar(128)  not null,
    ts_c                timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 产品类型信息
--

comment on table  dim_dict_product               is '产品类型信息';
comment on column dim_dict_product.id            is 'id';
comment on column dim_dict_product.p_num         is '产品类型编号';
comment on column dim_dict_product.name          is '产品类型名称';



-- data

insert into dim_dict_product(id, p_num, name) values
    (1, '1', '直联银联POS收单'),
    (2, '2', '结算');

