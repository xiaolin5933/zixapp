--
--  部门接口Matcher配置
--
drop table dept_matcher;
create table dept_matcher (
    id        integer not null,

    -- dept_bi的ID
    db_id     integer not null,
    matcher   varchar(8096),

    -- 最后操作者ID, 创建时间, 更新时间
    oper_id   char(8),
    ts_c      timestamp default current timestamp,
    ts_u      timestamp

) in tbs_dat index in tbs_idx;


-- 表注释
comment on table dept_matcher           is '部门ID,部门接口ID,matcher => 银行接口协议,银行手续费规则组ID';

-- 字段注释
comment on column dept_matcher.db_id    is 'dept_bi的ID-代表了唯一的(dept, dept_bi)';
comment on column dept_matcher.matcher  is '部门接口匹配串列表, 逗号分割';


