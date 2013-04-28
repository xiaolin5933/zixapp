--
-- 银行接口协议表
--
drop table bip;
create table bip (

    -- 协议ID, 接口ID
    id           integer  not null,
    bi           integer  not null,
 
    -- 协议开始结束日期
    begin        date not null,
    end          date not null,
 
    -- 本金划付信息
    bjhf_acct    integer,
    bjhf_period  char(1),
    bjhf_delay   integer,
    bjhf_nwd     char(1), 
 
    -- 取整规则
    round        char(1)  not null,
 
    -- 失效
    disable      char(1)  not null default '0',
 
    -- 备注
    memo         varchar(1024),
 
    -- 最后操作者ID, 创建时间, 更新时间
    oper_id      char(8),
    ts_c         timestamp default current timestamp,
    ts_u         timestamp
) in tbs_dat index in tbs_idx;

-- 表名注释
comment on table  bip             is '银行接口协议';

-- 字段注释
comment on column bip.id          is '银行接口协议编号';
comment on column bip.bi          is '银行接口编号';
comment on column bip.begin       is '协议开始日期';
comment on column bip.end         is '协议结束日期';
comment on column bip.bjhf_acct   is '本金划付-备付金账号ID';
comment on column bip.bjhf_period is '本金划付-周期';
comment on column bip.bjhf_delay  is '本金划付-延迟';
comment on column bip.bjhf_nwd    is '本金划付-非工作日是否';
comment on column bip.round       is '取整规则';
comment on column bip.disable     is '失效';
comment on column bip.memo        is '备注';
comment on column bip.ts_c        is '创建时间';

