--
--  周期确认-确认规则-确认周期区间
--
drop table frule_pack_period;
create table frule_pack_period (
    id        integer  not null,     

    -- frule_pack中的ID
    fp_id     char(32) not null, 

    -- 确认区间信息[begin, end] [begin, end) 
    begin     date not null,
    end       date not null,
    -- 周期区间封顶，保底
    ceiling   bigint,
    floor     bigint,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id      char(8),
    ts_c         timestamp default current timestamp,
    ts_u         timestamp

) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  frule_pack_period           is '周期确认-确认规则-确认周期区间';

-- 字段注释
comment on column frule_pack_period.id        is '周期确认-确认规则-确认周期区间ID';
comment on column frule_pack_period.fp_id     is '确认规则ID: frule_pack.ID';
comment on column frule_pack_period.begin     is '开始日期';
comment on column frule_pack_period.end       is '结束日期';
comment on column frule_pack_period.ceiling   is '封顶';
comment on column frule_pack_period.floor     is '保底';

