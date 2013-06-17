--
-- 周期确认-确认规则-确认计算区间
--
drop   table frule_pack_sect;
create table frule_pack_sect (
    id       integer not null, 

    -- frule_pack 的ID
    fp_id    integer not null,

    -- 暂估手续费汇总区间, [开始，结束) 
    begin    bigint  not null,
    end      bigint  not null,

    -- 打折比例
    ratio    integer,

    -- 定额
    -- quota    integer,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp

) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  frule_pack_sect          is '周期确认-确认规则-确认计算区间';

-- 字段注释
comment on column frule_pack_sect.id       is '周期确认-确认规则-确认计算区间ID';
comment on column frule_pack_sect.fp_id    is '确认规则ID';
comment on column frule_pack_sect.begin    is '区间开始值';
comment on column frule_pack_sect.end      is '区间结束值';
comment on column frule_pack_sect.ratio    is '比例-百万分之几';

