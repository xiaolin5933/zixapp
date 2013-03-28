--
-- 手续费规则-处理规则
--
drop table frule_proc;
create table frule_proc (
    id       integer not null,
    bip_id   integer not null
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  frule_proc         is '手续费规则-处理规则表';

-- 字段注释
comment on column frule_proc.id      is '手续费规则-处理规则ID';
comment on column frule_proc.bip_id  is '手续费规则-银行接口协议ID';

