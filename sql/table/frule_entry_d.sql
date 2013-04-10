--
-- 直接确认规则总表
--
drop   table frule_entry_d;
create table frule_entry_d (

-- 是frule_entry表中ack = 1的某个条目的扩展信息
    id       integer  not null,

-- 划付信息
    type     char(1)  not null,
    acct     integer  not null,

    period   char(1)  not null,
    delay    integer  not null,
    nwd      char(1)  not null,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp

) in tbs_dat index in tbs_idx;

comment on table  frule_entry_d        is '直接确认规则条目表';

--
comment on column frule_entry_d.id     is '直接确认规则ID-关联frule_entry的ID';

-- 划付信息
comment on column frule_entry_d.type    is '划付类型，1: 财务划付， 2: 非财务划付';
comment on column frule_entry_d.acct    is '划付账号';
comment on column frule_entry_d.period  is '划付周期';
comment on column frule_entry_d.delay   is '划付延迟';
comment on column frule_entry_d.nwd     is '划付-非工作日是否划付';

