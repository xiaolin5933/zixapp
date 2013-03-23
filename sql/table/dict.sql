--
--
--
--
--
drop table dict;
create table dict (
    tbl                  varchar(32) not null,                
    col                  char(16)    not null,
    key                  varchar(64) not null,
    val                  varchar(512),
    comment              varchar(128) default null,
    ts_c                 timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 表格字段取值范围字典
--
comment on table  dict          is '其他表格字段范围字典';
comment on column dict.tbl      is '数据表名';
comment on column dict.col      is '字段名';
comment on column dict.key      is '取值范围键';
comment on column dict.val      is '取值范围值';
comment on column dict.comment  is '取值描述';

-- book
insert into dict( tbl, col, key, val, comment) values
	('dict_book', 'class', '1', '资产类', '资产类'),
	('dict_book', 'class', '2', '负债类', '负债类'),
	('dict_book', 'class', '3', '共同类', '共同类'),
	('dict_book', 'class', '4', '往来类', '往来类'),
	('dict_book', 'class', '5', '损益类', '损益类'),
	('dict_book', 'attr',  '0', '财务', '财务'),
	('dict_book', 'attr',  '1', '备付', '备付'),
	('dict_book', 'jd',    '1', '借方', '借方'),
	('dict_book', 'jd',    '2', '贷方', '贷方'),
	('dict_book', 'jd',    '3', '双向', '双向');
