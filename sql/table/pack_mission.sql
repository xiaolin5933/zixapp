-- 
-- 周期确认控制状态表
--
drop table pack_mission;
create table pack_mission (
    -- 工作id
    id                    bigint primary key not null,

    -- 确认规则,扫描日期
    ack_id                char(4) not null,
    sm_date               date    not null,

    -- 状态
    status                char(2) not null,

    -- 管理字段
    oper_id           integer,
    ts_u              timestamp default current timestamp,
    ts_c              timestamp default current timestamp
);

comment on table  pack_mission           is '周期确认控制状态表';
comment on column pack_mission.id        is 'id';
comment on column pack_mission.ack_id    is '确认规则id';
comment on column pack_mission.sm_date   is '扫描日期';
comment on column pack_mission.status    is '状态. 1 可开始; 2 导出成功; 3 确认中; 4 确认成功; -1 未达确认周期; -2 导出失败; -3 确认失败';
comment on column pack_mission.oper_id   is '操作者';
comment on column pack_mission.ts_u      is '更新时间';
comment on column pack_mission.ts_c      is '创建时间';

-- id序列
drop sequence seq_pack_mission;
create sequence seq_pack_mission as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


-- create index
create unique index idx_pack_mission_0 on pack_mission (ack_id, sm_date);
