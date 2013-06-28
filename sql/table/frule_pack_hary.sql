--
-- 周期确认-确认规则表
--
drop   table frule_pack_hary;
create table frule_pack_hary (
    -- 周期确认-确认规则ID, 确认名称
    id         integer not null,
    name       char(64) not null,

    -- 确认类型, 确认时间周期, 确认计算周期
    ack_type   char(1) not null,
    ack_period varchar(1024),   
    ack_sect   varchar(1024),

    -- 划付信息
    type       char(1) not null,
    acct       integer,
    period     char(1),
    delay      integer,
    nwd        char(1),

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp

) in tbs_dat index in tbs_idx;

comment on table  frule_pack_hary               is '周期确认-确认规则表';

--
comment on column frule_pack_hary.id            is '周期确认-确认规则ID';
comment on column frule_pack_hary.ack_type      is '确认类型。 1 包周期(月，年); 2 阶梯; 3 分段';
comment on column frule_pack_hary.type          is '划付类型. 1: 财务划付; 2: 非财务划付';
comment on column frule_pack_hary.acct          is '划付帐号';
comment on column frule_pack_hary.period        is '划付周期';
comment on column frule_pack_hary.delay         is '划付延迟';
comment on column frule_pack_hary.nwd           is '非工作日是否划付. 0 否; 1 是';

