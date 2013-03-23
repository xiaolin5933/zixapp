--
--
--
--
--
drop table dict_yspz;
create table dict_yspz (
    num                  char(4)    not null primary key,
    name                 varchar(128) not null,
    ts_c                 timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 原始凭证类型信息
--
comment on table  dict_yspz               is '原始凭证类型信息';
comment on column dict_yspz.num           is '凭证编号';
comment on column dict_yspz.name          is '凭证名称';

-- book
insert into dict_yspz( num, name) values
	('0001', ''),
	('0002', ''),
	('0003', ''),
	('0004', ''),
	('0005', ''),
	('0006', ''),
	('0007', ''),
	('0008', ''),
	('0009', ''),
	('0010', ''),
	('0011', ''),
	('0012', ''),
	('0013', ''),
	('0014', ''),
	('0015', ''),
	('0016', ''),
	('0017', '');

