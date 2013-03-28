create table dict_holi (
    year     integer  not null,
    days     integer  not null,
    holiday  varchar(2048) not null
) in tbs_dat index in tbs_idx;

comment on table  dict_holi          is  '节假日信息表';
comment on column dict_holi.year     is  '年份';
comment on column dict_holi.days     is  '天数';
comment on column dict_holi.holiday  is  '假日列表';
