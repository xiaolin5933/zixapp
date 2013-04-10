--
-- 规则条目
--
drop table frule_entry;

create table frule_entry (

    id    integer not null,
    gid   integer not null,
    ack   char(1) not null,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id      char(8),
    ts_c         timestamp default current timestamp,
    ts_u         timestamp

) in tbs_dat index in tbs_idx;

comment on table  frule_entry      is '规则条目';
comment on column frule_entry.id   is '规则条目ID';
comment on column frule_entry.gid  is '规则条目所属组';
comment on column frule_entry.ack  is '规则确认方式, 1: 直接确认 2: 周期确认';

