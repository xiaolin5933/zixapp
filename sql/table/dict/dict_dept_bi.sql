--
--  银行接口-部门映射表
--
drop table dict_dept_bi;
create table dict_dept_bi (
    dept_id   integer  not null,
    dept_bi   char(32) not null, 
    bi        integer  not null
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  dict_dept_bi           is '银行接口部门映射表';

-- 字段注释
comment on column dict_dept_bi.dept_id   is '部门ID';
comment on column dict_dept_bi.dept_bi   is '部门银行接口';
comment on column dict_dept_bi.bi        is '银行接口';

