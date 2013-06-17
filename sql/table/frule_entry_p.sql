--
-- 周期确认-计算规则总表
--
drop   table frule_entry_p;
create table frule_entry_p (

    -- 是frule_entry表中ack = 2的某个条目的扩展信息
    id       integer not null,

    -- 确认规则ID
    fp_id    integer not null,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp

) in tbs_dat index in tbs_idx;

comment on table  frule_entry_p        is '周期确认-计算规则总表';

--
comment on column frule_entry_p.id     is '周期确认-计算规则ID-关联frule_entry的ID';
comment on column frule_entry_p.fp_id  is '确认规则ID';

