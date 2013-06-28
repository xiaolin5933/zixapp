--
-- 手续费规则-规则组
--
drop table frule_group_hary;
create table frule_group_hary (

    -- 每个银行协议有一堆规则组
    id       integer  not null,
    name     char(64) not null,
    bip      integer  not null,
    dir      char(1)  not null,

    -- 
    rules    varchar(8192),

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id  char(8),
    ts_c     timestamp default current timestamp,
    ts_u     timestamp
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  frule_group_hary         is '手续费规则-处理规则组表';

-- 字段注释
comment on column frule_group_hary.id      is '手续费规则-处理规则组ID';
comment on column frule_group_hary.name    is '手续费规则-规则名称';
comment on column frule_group_hary.bip     is '手续费规则-银行接口协议ID';
comment on column frule_group_hary.dir     is '规则组-交易方向';
comment on column frule_group_hary.rules   is '规则组-规则条目';

