--
--
--
--
--
drop table dict_yspz;
create table dict_yspz (
    code         char(4)      not null primary key,
    memo         varchar(128) not null,
    enable       char(1)      default '0',
    ts_c         timestamp    default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 原始凭证类型信息
--
comment on table  dict_yspz           is '原始凭证类型信息';
comment on column dict_yspz.code      is '凭证编号';
comment on column dict_yspz.memo      is '凭证描述';
comment on column dict_yspz.enable    is '启用';

-- book
insert into dict_yspz( code, memo, enable) values
('0000', '特种调整单', '1');

