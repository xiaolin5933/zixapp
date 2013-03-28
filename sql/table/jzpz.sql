--
-- 记账凭证
--
drop table jzpz;
create table jzpz (
-- id
    id              bigint primary key not null,

-- 记账关联    
    j_id            bigint     not null,
    d_id            bigint     not null,
    jb_id           int        not null,
    db_id           int        not null,
    ys_type         char(4)    not null,
    ys_id           bigint     not null,

    fid             char(10),
    period          date not null,

-- 创建时间
    ts_c            timestamp  default current timestamp
  
) in tbs_dat index in tbs_idx; 

comment on table  jzpz           is '记账凭证表';
comment on column jzpz.j_id      is '借方科目的记录id';
comment on column jzpz.d_id      is '贷方科目的记录id';
comment on column jzpz.jb_id     is '借方科目内部id';
comment on column jzpz.db_id     is '贷方科目内部id';
comment on column jzpz.ys_type   is '原始凭证类型';
comment on column jzpz.ys_id     is '原始凭证id';
comment on column jzpz.fid       is '分录编号';
comment on column jzpz.period    is '科目说明';

drop sequence seq_jzpz;
create sequence seq_jzpz as bigint start with 1 increment by 1 minvalue 1 no maxvalue no cycle cache 200 order;

