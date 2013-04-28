-- 
-- 凭证导入状态控制表
--
drop table load_mission;
create table load_mission (
    -- 工作id
    id                    bigint primary key not null,

    -- 日期,类型
    type                  char(4) not null,
    date                  date    not null,

    -- 记录数,失败数,成功数,状态
    total                 integer not null,
    fail                  integer not null,
    succ                  integer not null,
    status                char(2) not null,

    -- 管理字段
    oper_id           integer,
    ts_u              timestamp default current timestamp,
    ts_c              timestamp default current timestamp
);

comment on table load_mission            is '凭证导入状态控制表';
comment on column load_mission.id        is 'id';
comment on column load_mission.type      is '凭证类型';
comment on column load_mission.date      is '日期';
comment on column load_mission.total     is '记录数';
comment on column load_mission.fail      is '失败数';
comment on column load_mission.succ      is '成功数';
comment on column load_mission.status    is '状态. 1 可开始; 2 下载中; 3 可分配; 4 分配中; 5 可运行; 6 运行中; 7 运行成功; -1 下载失败; -2 分配失败; -3 运行失败';
comment on column load_mission.oper_id   is '操作者';
comment on column load_mission.ts_u      is '更新时间';
comment on column load_mission.ts_c      is '创建时间';

-- id序列
drop sequence seq_load_mission;
create sequence seq_load_mission as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


-- create index
create unique index idx_load_mission_0 on load_mission (type, date);
