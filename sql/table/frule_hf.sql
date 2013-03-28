--
-- 手续费规则-划付规则
--

drop   table frule_hf;
create table frule_hf (
    fp_id    integer  not null,
    type     char(1)  not null,
    acct     integer  not null,
    period   char(1)  not null,
    delay    integer  not null,
    nwd      char(1)  not null
) in tbs_dat index in tbs_idx;

-- 表名称注释
comment on table  frule_hf         is '手续费划付规则';

-- 字段注释
comment on column frule_hf.fp_id   is '手续处理规则ID';
comment on column frule_hf.type    is '划付-类型, 1: 财务支付， 2: 非财务支付';
comment on column frule_hf.acct    is '划付-银行账户号ID';
comment on column frule_hf.period  is '划付-周期';
comment on column frule_hf.delay   is '划付-延迟';
comment on column frule_hf.nwd     is '划付-非工作日是否划付';

