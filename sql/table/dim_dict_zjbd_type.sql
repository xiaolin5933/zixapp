--
--
--
--
--
drop table dim_dict_zjbd_type;
create table dim_dict_zjbd_type (
-- primary key
    id          integer  primary key not null,
    name        varchar(32)          not null,
    memo        varchar(128),    
-- mis
    ts_c                timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 资金变动类型字典
--

comment on table   dim_dict_zjbd_type               is '易宝资金账户号字典';
comment on column  dim_dict_zjbd_type.id            is 'id';
comment on column  dim_dict_zjbd_type.name          is '资金变动类型名';
comment on column  dim_dict_zjbd_type.memo          is '描述';


-- default data
insert into dim_dict_zjbd_type(id, name) values
       (1, '银行接口编号'),
       (2, '账户利息'),
       (3, '账户管理费'),
       (4, '资金调拨');


