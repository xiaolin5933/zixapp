-- 
-- 凭证导入任务表
--
drop table load_job;
create table load_job (
    -- 任务id
    id                    bigint primary key not null,

    -- 日期,类型
    type                  char(4) not null,
    date                  date    not null,
    index                 integer not null,

    -- 工作id
    mission_id            bigint  not null,

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

comment on table  load_job              is '凭证导入任务表';
comment on column load_job.id           is '任务id';
comment on column load_job.type         is '凭证类型';
comment on column load_job.date         is '日期';
comment on column load_job.index        is '任务顺序号';
comment on column load_job.mission_id   is '工作id';
comment on column load_job.total        is '记录数';
comment on column load_job.fail         is '失败数';
comment on column load_job.succ         is '成功数';
comment on column load_job.status       is '状态. 1 可运行; 2 运行中; 3 运行成功; -1 运行失败';
comment on column load_job.oper_id      is '操作者';
comment on column load_job.ts_u         is '更新时间';
comment on column load_job.ts_c         is '创建时间';

-- id序列
drop sequence seq_load_job;
create sequence seq_load_job as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


-- create index
create unique index idx_load_job_0 on load_job (type, date, index);
