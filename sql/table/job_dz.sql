--
-- 每日对账任务表
--
drop table  job_dz;
create table job_dz
(
        id          bigint     not null,
        zjdz_date   date       not null, 
        type        char(1)    not null,
        b_acct      integer    not null,
        status      char(1)    not null,
        ts_c        timestamp  default current timestamp,
        ts_u        timestamp
);

comment on table  job_dz            is '每日对账任务表';
comment on column job_dz.id         is 'id';
comment on column job_dz.zjdz_date  is '资金对账日期';
comment on column job_dz.type       is '帐号类型; 1 备付金; 2 自有资金';
comment on column job_dz.b_acct     is '帐号id';
comment on column job_dz.status     is '对账状态; 1 未处理; 2 成功; -1 失败';

drop sequence seq_job_dz;
create sequence seq_job_dz as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;


-- create index
create unique index idx_job_dz_0 on job_dz (zjdz_date, type, b_acct);
