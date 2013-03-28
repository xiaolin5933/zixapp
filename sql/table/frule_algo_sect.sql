--
-- 收入费规则-计算区间表
--
drop   table frule_algo_sect;
create table frule_algo_sect (
    
    -- 管理的处理规则ID 
    fp_id    integer not null,

    -- 区间ID, [开始，结束)
    sect_id  integer not null,
    begin    bigint  not null,
    end      bigint  not null,

    -- 1: 按比列 or 2: 定额
    mode     char(1) not null,

    -- 按比列，则有封顶，保底
    ratio    integer,
    ceiling  integer,
    floor    integer,

    -- 定额
    quota    integer
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  frule_algo_sect          is '手续费规则-计算区间表';

-- 字段注释
comment on column frule_algo_sect.fp_id    is '处理规则ID';
comment on column frule_algo_sect.sect_id  is '区间ID';
comment on column frule_algo_sect.begin    is '区间开始值';
comment on column frule_algo_sect.end      is '区间结束值';
comment on column frule_algo_sect.mode     is '计算方式, 1: 按比例,  2: 定额';
comment on column frule_algo_sect.ratio    is '比例-百万分之几';
comment on column frule_algo_sect.ceiling  is '封顶';
comment on column frule_algo_sect.floor    is '保底';
comment on column frule_algo_sect.quota    is '定额';

