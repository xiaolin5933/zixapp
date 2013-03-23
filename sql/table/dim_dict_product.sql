--
--
--
--
--
drop table dim_dict_product;
create table dim_dict_product (
    id          integer    not null primary key,
    name        char(32)     not null,
    memo        varchar(32),
    ts_c        timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 产品类型信息
--

comment on table  dim_dict_product               is '产品类型信息';
comment on column dim_dict_product.id            is 'id';
comment on column dim_dict_product.name          is '产品类型名称';
comment on column dim_dict_product.memo          is '描述';


-- data

insert into dim_dict_product(id, name) values
    (1, '直联银联POS收单'),
    (2, '结算');

