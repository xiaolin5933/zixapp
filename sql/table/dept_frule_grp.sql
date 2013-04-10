--
--  部门ID,部门接口 =>  协议-规则组
--
drop table dept_frule_grp;
create table dept_frule_grp (
    id        integer not null,

    -- dept_bi的ID
    db_id     integer not null,
    matcher   char(32),
   
    -- 银行接口协议ID 
    bip       integer not null,

    -- 规则组ID
    gid       integer not null,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id   char(8),
    ts_c      timestamp default current timestamp,
    ts_u      timestamp

) in tbs_dat index in tbs_idx;


-- 表注释
comment on table dept_frule_grp           is '部门ID,部门接口ID,matcher => 银行接口协议,银行手续费规则组ID';

-- 字段注释
comment on column dept_frule_grp.id       is '记录ID';
comment on column dept_frule_grp.db_id    is 'dept_bi的ID-代表了唯一的(dept, dept_bi)';
comment on column dept_frule_grp.matcher  is '部门接口匹配串';
comment on column dept_frule_grp.bip      is '银行接口协议';
comment on column dept_frule_grp.gid      is '规则组ID';


