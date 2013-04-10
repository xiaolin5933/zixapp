--
--  
--
drop table dict_dept_xxx;
create table dict_dept_ (
    -- id  <===> dept_id + dept_bi
    id        integer  not null,     
    matcher   char(32),
    bip       integer  not null,

    grp_id    integer not null 
    
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  dict_dept_bi           is '银行接口部门映射表';

-- 字段注释
comment on column dict_dept_bi.dept_id   is '部门ID';
comment on column dict_dept_bi.dept_bi   is '部门银行接口';
comment on column dict_dept_bi.bi        is '银行接口';

