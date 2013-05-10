--
--  matcher ---> 规则组映射
--
drop table dept_fgrp;
create table dept_fgrp (

    -- dept_matcher的ID
    dbm_id        integer not null,

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
comment on table dept_fgrp           is 'matcher => 银行接口协议,银行手续费规则组ID';

-- 字段注释
comment on column dept_fgrp.dbm_id   is '部门matcher记录ID';
comment on column dept_fgrp.bip      is '银行接口协议';
comment on column dept_fgrp.gid      is '规则组ID';

