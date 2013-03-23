--
--
--
--
--
drop table dict;
create table dict (
    class     char(16)    not null,
    key       varchar(64) not null,
    val       varchar(512),
    memo      varchar(128) default null,
    ts_c      timestamp  default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 表格字段取值范围字典
--
comment on table  dict          is '其他表格字段范围字典';
comment on column dict.class    is '分类';
comment on column dict.key      is '取值键';
comment on column dict.val      is '取值';
comment on column dict.memo     is '取值描述';

-- book
insert into dict( class, key, val, memo) values
('class', '1', '资产类', '资产类'),
('class', '2', '负债类', '负债类'),
('class', '3', '共同类', '共同类'),
('class', '4', '往来类', '往来类'),
('class', '5', '损益类', '损益类'),
('attr',  '0', '财务',   '财务'),
('attr',  '1', '备付',   '备付'),
('jd',    '1', '借方',   '借方'),
('jd',    '2', '贷方',   '贷方'),
('jd',    '3', '双向',   '双向');
