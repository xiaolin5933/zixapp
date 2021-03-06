-- 
-- 备付金账号id
--
drop table dim_bfj_acct;
create table dim_bfj_acct (

-- id字段
    id                    integer not null primary key,

-- 相关信息字段   
    b_acct                char(32) not null,
    acct_name             varchar(128) not null,
    b_name                varchar(128) not null,
    valid                 char(1) not null,
    memo                  varchar(1024),

-- 创建时间
    ts_c                  timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

comment on table  dim_bfj_acct                      is '备付金账号id';
comment on column dim_bfj_acct.id                   is 'id';

comment on column dim_bfj_acct.b_acct               is '备付金银行账号';
comment on column dim_bfj_acct.acct_name            is '开户人名称';
comment on column dim_bfj_acct.b_name               is '开户银行名称';
comment on column dim_bfj_acct.valid                is '是否有效';
comment on column dim_bfj_acct.memo                 is '备注';

comment on column dim_bfj_acct.ts_c                 is '创建时间';

--
-- 初始化
--
-- zark begin
insert into dim_bfj_acct(id, b_acct, acct_name, b_name, valid, memo) values
(1, '002477419700010', '北京通融通信息技术有限公司', '包商银行北京分行', '1', '目前没用'),
(2, '00130630500120109167292', '北京通融通信息技术有限公司', '北京银行上海分行营业部', '1', '目前没用'),
(3, '2107590019300023518', '北京通融通信息技术有限公司', '工商银行广西钦州分行', '1', '监管总户'),
(4, '2107590019300055838', '北京通融通信息技术有限公司', '工商银行广西钦州分行', '1', '工行收款、光大银联收款'),
(5, '35310188000063804', '北京通融通信息技术有限公司', '光大银行北京京广桥支行', '1', '光大收款'),
(6, '01541100000425', '北京通融通信息技术有限公司', '河北银行朝阳路支行', '1', '目前没用'),
(7, '11001042500053001473', '北京通融通信息技术有限公司', '建设银行北京建国支行', '1', '建行收款'),
(8, '41-004300040017055', '北京通融通信息技术有限公司', '农业银行深圳上步支行', '1', '农行收款'),
(9, '2000004743525', '北京通融通信息技术有限公司', '平安银行上海张江支行', '1', '目前没用'),
(10, '2000007916325', '北京通融通信息技术有限公司', '平安银行深圳分行', '1', '目前没用'),
(11, '91350154800005063', '北京通融通信息技术有限公司', '浦发银行北京北沙滩支行', '1', '目前没用'),
(12, '91350154800005071', '北京通融通信息技术有限公司', '浦发银行北京北沙滩支行', '1', '目前没用'),
(13, '017014908-03001762876', '北京通融通信息技术有限公司', '上海银行北京分行', '1', '目前没用'),
(14, '905000120190019139', '北京通融通信息技术有限公司', '温州银行上海分行营业部', '1', '温州收款'),
(15, '100527227860010004', '北京通融通信息技术有限公司', '中国邮政储蓄银行广州荔湾支行', '1', '目前没用'),
(16, '774459222622', '北京通融通信息技术有限公司', '中国银行深圳建安路支行', '1', '中行、上海银联收款');
-- zark end
