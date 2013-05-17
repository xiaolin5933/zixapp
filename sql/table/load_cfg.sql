--
-- 凭证导入配置表
--
drop table load_cfg;
create table load_cfg (
    type   char(4)         not null primary key,
    host   char(32)        not null,
    user   varchar(32)     not null,
    pass   varchar(32)     not null,
    rdir   varchar(128)    not null,
    fname  varchar(128)    not null
) in tbs_dat index in tbs_idx;

comment on table   load_cfg        is '凭证导入配置表';
comment on column  load_cfg.type   is '凭证类型';
comment on column  load_cfg.host   is '服务器地址';
comment on column  load_cfg.user   is '登录用户名';
comment on column  load_cfg.pass   is '登录密码';
comment on column  load_cfg.rdir   is '远程服务器文件所在位置';
comment on column  load_cfg.fname  is '远程服务器文件名称';

-- data
insert into load_cfg(type, host, user, pass, rdir, fname) values
    ('0002', '127.0.0.1', 'cain', 'cain', 'tmp/data/fund',      'fund-0002.dat'),
    ('0003', '127.0.0.1', 'cain', 'cain', 'tmp/data/fund',      'fund-0003.dat'),
    ('0004', '127.0.0.1', 'cain', 'cain', 'tmp/data/fund',      'fund-0004.dat'),
    ('0007', '127.0.0.1', 'cain', 'cain', 'tmp/data/fund',      'fund-0007.dat'),
    ('0009', '127.0.0.1', 'cain', 'cain', 'tmp/data/fund',      'fund-0009.dat'),
    ('0016', '127.0.0.1', 'cain', 'cain', 'tmp/data/pos-hn',    'pos-hn-0016.dat'),
    ('0017', '127.0.0.1', 'cain', 'cain', 'tmp/data/pos-hn',    'pos-hn-0017.dat');
