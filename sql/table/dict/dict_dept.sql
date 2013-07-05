--
--  部门字典表
--
drop table dict_dept;
create table dict_dept (
    id    integer  not null,
    name  char(32) not null
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  dict_dept       is '部门字典表';

-- 字段注释
comment on column dict_dept.id    is '部门ID';
comment on column dict_dept.name  is '部门名称';


--
-- 初始化
--
insert into dict_dept(id, name) values
(1, '未知部门');
