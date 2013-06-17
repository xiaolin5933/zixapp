--
-- 直接确认规则-计算区间表
--
drop   table frule_d_sect;
create table frule_d_sect (
    id       integer not null, 

    -- frule_entry_direct的ID
    e_id     integer not null,

    -- 区间ID, [开始，结束)
    begin    bigint  not null,
    end      bigint  not null,

    -- 1: 按比列 or 2: 定额
    mode     char(1) not null,

    -- 按比列，则有封顶，保底
    ratio    integer,
    ceiling  integer,
    floor    integer,

    -- 定额
    quota    integer,

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp

) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  frule_d_sect          is '直接确认规则-计算区间表';

-- 字段注释
comment on column frule_d_sect.id       is '区间ID';
comment on column frule_d_sect.ed_id    is '处理规则ID';
comment on column frule_d_sect.begin    is '区间开始值';
comment on column frule_d_sect.end      is '区间结束值';
comment on column frule_d_sect.mode     is '计算方式, 1: 按比例,  2: 定额';
comment on column frule_d_sect.ratio    is '比例-百万分之几';
comment on column frule_d_sect.ceiling  is '封顶';
comment on column frule_d_sect.floor    is '保底';
comment on column frule_d_sect.quota    is '定额';

