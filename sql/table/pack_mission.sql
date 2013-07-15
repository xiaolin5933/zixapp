-- 
-- 周期确认控制状态表
--
drop table pack_mission;
create table pack_mission (
    -- 工作id
    id                    bigint primary key not null,

    -- 确认规则,扫描日期
    sm_date               date    not null,

    -- 状态
    status                char(2) not null,

    -- pack id集合, 用","隔开
    packs                 varchar(512),

    -- 管理字段
    oper_id           integer,
    ts_u              timestamp default current timestamp,
    ts_c              timestamp default current timestamp
);

comment on table  pack_mission           is '周期确认控制状态表';
comment on column pack_mission.id        is 'id';
comment on column pack_mission.sm_date   is '扫描日期';
comment on column pack_mission.status    is '状态. 1 可生成; 2 生成中; 3 生成成功; -1 无; -2 生成失败';
comment on column pack_mission.packs     is 'pack id集合, 用","隔开';
comment on column pack_mission.oper_id   is '操作者';
comment on column pack_mission.ts_u      is '更新时间';
comment on column pack_mission.ts_c      is '创建时间';

-- id序列
drop sequence seq_pack_mission;
create sequence seq_pack_mission as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


-- create index
create unique index idx_pack_mission_0 on pack_mission (sm_date);
