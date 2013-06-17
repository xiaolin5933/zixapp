--
-- 周期确认-确认规则表
--
drop   table frule_pack;
create table frule_pack (
    -- 周期确认-确认规则ID:
    id         integer not null primary key,

    -- 是否回溯
    ack_type   char(1) not null,

    -- 划付信息
    type       char(1) not null,
    acct       integer,
    period     char(1),
    delay      integer,
    nwd        char(1),

    -- 取整规则
    round      char(1) not null,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp

) in tbs_dat index in tbs_idx;

comment on table  frule_pack               is '周期确认-确认规则表';

--
comment on column frule_pack.id            is '周期确认-确认规则ID';
comment on column frule_pack.ack_type      is '确认类型。 1 包周期(月，年); 2 阶梯; 3 分段';
comment on column frule_pack.type          is '划付类型. 1: 财务划付; 2: 非财务划付';
comment on column frule_pack.acct          is '划付帐号';
comment on column frule_pack.period        is '划付周期';
comment on column frule_pack.delay         is '划付延迟';
comment on column frule_pack.nwd           is '非工作日是否划付. 0 否; 1 是';
comment on column frule_pack.round         is '取整规则. 1 四舍五入; 2 向上取整; 3 向下取整';

