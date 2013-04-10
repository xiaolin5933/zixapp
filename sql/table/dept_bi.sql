--
--  银行接口-部门映射表
--
drop table dept_bi;
create table dept_bi (

    id        integer  not null,     
    dept_id   integer  not null,
    dept_bi   char(32) not null, 
    bi        integer  not null,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id      char(8),
    ts_c         timestamp default current timestamp,
    ts_u         timestamp
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  dept_bi           is '银行接口部门映射表';

-- 字段注释
comment on column dept_bi.dept_id   is '部门ID';
comment on column dept_bi.dept_bi   is '部门银行接口';
comment on column dept_bi.bi        is '银行接口';

