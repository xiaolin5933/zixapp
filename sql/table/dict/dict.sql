--
-- 通用字典表
--
drop table dict;
create table dict (
    class     char(16)    not null,
    key       varchar(64) not null,
    val       varchar(512),
    memo      varchar(128) default null,
    ts_c      timestamp  default current timestamp
) in tbs_dat index in tbs_idx;

--
-- 表格字段取值范围字典
--
comment on table  dict          is '其他表格字段范围字典';
comment on column dict.class    is '分类';
comment on column dict.key      is '取值键';
comment on column dict.val      is '取值';
comment on column dict.memo     is '取值描述';

-- book
insert into dict( class, key, val, memo) values
('class', '1', '资产类', '资产类'),
('class', '2', '负债类', '负债类'),
('class', '3', '共同类', '共同类'),
('class', '4', '往来类', '往来类'),
('class', '5', '损益类', '损益类'),
('set',   '0', '财务',   '财务'),
('set',   '1', '备付',   '备付'),
('jd',    '1', '借方',   '借方'),
('jd',    '2', '贷方',   '贷方'),
('jd',    '3', '双向',   '双向');

insert into dict(class, key, val) values
( 'yspz_0008',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0008',  'zjbd_type', '资金变动类型 - 银行转账充值' ),
( 'yspz_0008',  'c', '委托付款客户编号' ),
( 'yspz_0008',  'period', '会计期间' ),
( 'yspz_0008',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0008',  'tx_amt', '赎回款金额' ),
( 'yspz_0009',  'ssn', '交易流水编号' ),
( 'yspz_0009',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0009',  'bi', '银行接口编号' ),
( 'yspz_0009',  'p', '产品类型 - 基金委托出款' ),
( 'yspz_0009',  'cust_proto', '客户协议编号' ),
( 'yspz_0009',  'c', '委托付款客户编号' ),
( 'yspz_0009',  'period', '会计期间' ),
( 'yspz_0009',  'tx_date', '交易日期' ),
( 'yspz_0009',  'zjbd_date_out', '本金备付金银行出账日期' ),
( 'yspz_0009',  'tx_amt', '出款金额' ),
( 'yspz_0009',  'cwwf_bfee', '财务外付银行手续费' ),
( 'yspz_0009',  'wk_cfee', '外扣客户手续费' ),
( 'yspz_0011',  'bfj_acct', '备付金银行账号' ),
( 'yspz_0011',  'zyzj_acct', '自有资金银行账号' ),
( 'yspz_0011',  'bfj_zjbd_type', '备付金资金变动类型' ),
( 'yspz_0011',  'zyzj_zjbd_type', '自有资金资金变动类型' ),
( 'yspz_0011',  'period', '会计期间' ),
( 'yspz_0011',  'zjbd_date_out_bfj', '备付金银行出账日期' ),
( 'yspz_0011',  'zjbd_date_in_bfj', '备付金银行入账日期' ),
( 'yspz_0011',  'e_date_bfj', '备付金银行差错日期' ),
( 'yspz_0011',  'zjbd_date_out_zyzj', '自有资金银行出账日期' ),
( 'yspz_0011',  'zjbd_date_in_zyzj', '自有资金银行入账日期' ),
( 'yspz_0011',  'e_date_zyzj', '自有资金银行差错日期' ),
( 'yspz_0011',  'yhys_txamt', '已核应收交易款借方汇总' ),
( 'yspz_0011',  'yhys_bamt', '已核应收银行款借方汇总' ),
( 'yspz_0011',  'yhys_bfee', '已核应收银行手续费借方汇总' ),
( 'yspz_0011',  'yhyf_txamt', '已核应付交易款贷方汇总' ),
( 'yspz_0011',  'yhyf_bamt', '已核应付银行款贷方汇总' ),
( 'yspz_0011',  'yhyf_bfee', '已核应付银行手续费贷方汇总' ),
( 'yspz_0011',  'bfj_blc', '备付金银行长款金额' ),
( 'yspz_0011',  'zyzj_blc', '自有资金银行长款金额' ),
( 'yspz_0005',  'ssn', '交易流水编号' ),
( 'yspz_0005',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0005',  'bfj_acct_bfee', '备付金银行账号' ),
( 'yspz_0005',  'bi', '银行接口编号' ),
( 'yspz_0005',  'p', '产品类型 - 基金收款' ),
( 'yspz_0005',  'c', '客户编号' ),
( 'yspz_0005',  'period', '会计期间' ),
( 'yspz_0005',  'tx_date', '交易日期' ),
( 'yspz_0005',  'zjbd_date_out', '备付金银行出账日期' ),
( 'yspz_0005',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0005',  'tx_amt', '支付金额' ),
( 'yspz_0005',  'bfj_bfee', '备付金银行手续费' ),
( 'yspz_0005',  'cwwf_bfee', '财务外付银行手续费' ),
( 'yspz_0004',  'ssn', '交易流水编号' ),
( 'yspz_0004',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0004',  'bfj_acct_bfee', '备付金银行账号' ),
( 'yspz_0004',  'bi', '银行接口编号' ),
( 'yspz_0004',  'p', '产品类型 - 基金收款' ),
( 'yspz_0004',  'wqr_c', '无法确认的委托收款客户编号' ),
( 'yspz_0004',  'period', '会计期间' ),
( 'yspz_0004',  'tx_date', '交易日期' ),
( 'yspz_0004',  'zjbd_date_out', '备付金银行出账日期' ),
( 'yspz_0004',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0004',  'tx_amt', '支付金额' ),
( 'yspz_0004',  'bfj_bfee', '备付金银行手续费' ),
( 'yspz_0004',  'cwwf_bfee', '财务外付银行手续费' ),
( 'yspz_0007',  'ssn', '交易流水编号' ),
( 'yspz_0007',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0007',  'bi', '银行接口编号' ),
( 'yspz_0007',  'p', '产品类型 - 基金结算' ),
( 'yspz_0007',  'c', '客户编号' ),
( 'yspz_0007',  'period', '会计期间' ),
( 'yspz_0007',  'tx_date', '交易日期' ),
( 'yspz_0007',  'zjbd_date_out', '本金备付金银行出账日期' ),
( 'yspz_0007',  'tx_amt', '出款金额' ),
( 'yspz_0007',  'cwwf_bfee', '财务外付银行手续费' ),
( 'yspz_0012',  'bfj_acct', '备付金银行账号' ),
( 'yspz_0012',  'zyzj_acct', '自有资金银行账号' ),
( 'yspz_0012',  'bfj_zjbd_type', '备付金资金变动类型' ),
( 'yspz_0012',  'zyzj_zjbd_type', '自有资金资金变动类型' ),
( 'yspz_0012',  'period', '会计期间' ),
( 'yspz_0012',  'zjbd_date_out_bfj', '备付金银行出账日期' ),
( 'yspz_0012',  'zjbd_date_in_bfj', '备付金银行入账日期' ),
( 'yspz_0012',  'e_date_bfj', '备付金银行差错日期' ),
( 'yspz_0012',  'zjbd_date_out_zyzj', '自有资金银行出账日期' ),
( 'yspz_0012',  'zjbd_date_in_zyzj', '自有资金银行入账日期' ),
( 'yspz_0012',  'e_date_zyzj', '自有资金银行差错日期' ),
( 'yspz_0012',  'yhys_txamt', '已核应收交易款借方汇总' ),
( 'yspz_0012',  'yhys_bamt', '已核应收银行款借方汇总' ),
( 'yspz_0012',  'yhys_bfee', '已核应收银行手续费借方汇总' ),
( 'yspz_0012',  'yhyf_txamt', '已核应付交易款贷方汇总' ),
( 'yspz_0012',  'yhyf_bamt', '已核应付银行款贷方汇总' ),
( 'yspz_0012',  'yhyf_bfee', '已核应付银行手续费贷方汇总' ),
( 'yspz_0012',  'bfj_bsc', '备付金银行短款金额' ),
( 'yspz_0012',  'zyzj_bsc', '自有资金银行短款金额' ),
( 'yspz_0001',  'bfj_acct', '备付金银行账号' ),
( 'yspz_0001',  'zjbd_type', '资金变动类型 - 资金调拨' ),
( 'yspz_0001',  'zyzj_acct', '自有资金银行账号' ),
( 'yspz_0001',  'period', '会计期间' ),
( 'yspz_0001',  'zjbd_date_in', '备付金银行入账日期' ),
( 'yspz_0001',  'zjbd_date_out', '自有资金银行出账日期' ),
( 'yspz_0001',  'zjhb_amt', '资金划拨金额' ),
( 'yspz_0001',  'zyzj_bfee', '自有资金银行手续手续费' ),
( 'yspz_0002',  'ssn', '交易流水编号' ),
( 'yspz_0002',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0002',  'bfj_acct_bfee', '备付金银行账号' ),
( 'yspz_0002',  'bi', '银行接口编号' ),
( 'yspz_0002',  'p', '产品类型 - 基金收款' ),
( 'yspz_0002',  'cust_proto', '客户协议编号' ),
( 'yspz_0002',  'c', '客户编号' ),
( 'yspz_0002',  'period', '会计期间' ),
( 'yspz_0002',  'tx_date', '交易日期' ),
( 'yspz_0002',  'zjbd_date_out', '备付金银行出账日期' ),
( 'yspz_0002',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0002',  'tx_amt', '支付金额' ),
( 'yspz_0002',  'bfj_bfee', '备付金银行手续费' ),
( 'yspz_0002',  'cwwf_bfee', '财务外付银行手续费' ),
( 'yspz_0002',  'wk_cfee', '外扣客户手续费' ),
( 'yspz_0015',  'bfj_acct_in', '入款备付金银行账号' ),
( 'yspz_0015',  'bfj_acct_out', '出款备付金银行账号' ),
( 'yspz_0015',  'zjbd_type', '资金变动类型 - 资金调拨' ),
( 'yspz_0015',  'period', '会计期间' ),
( 'yspz_0015',  'zjbd_date_out', '出款备付金银行出账日期' ),
( 'yspz_0015',  'zjbd_date_in', '入款备付金银行入账日期' ),
( 'yspz_0015',  'zjhb_amt', '资金划拨金额' ),
( 'yspz_0015',  'bfj_bfee', '备付金银行手续费金额' ),
( 'yspz_0006',  'ssn', '交易流水编号' ),
( 'yspz_0006',  'bi', '银行接口编号' ),
( 'yspz_0006',  'p', '产品类型 - 基金收款' ),
( 'yspz_0006',  'yqr_c', '已确认的委托收款客户编号' ),
( 'yspz_0006',  'wqr_c', '无法确认的委托收款客户编号' ),
( 'yspz_0006',  'period', '会计期间' ),
( 'yspz_0006',  'tx_date', '交易日期' ),
( 'yspz_0006',  'tx_amt', '支付金额' ),
( 'yspz_0006',  'bfee', '确认的银行手续费' ),
( 'yspz_0013',  'bfj_acct', '备付金银行账号' ),
( 'yspz_0013',  'zjbd_type', '资金变动类型 - 账户管理费' ),
( 'yspz_0013',  'period', '会计期间' ),
( 'yspz_0013',  'zjbd_date_out', '备付金银行出账日期' ),
( 'yspz_0013',  'zhgl_fee', '账户管理费金额' ),
( 'yspz_0000',  'cause', '调账原因' ),
( 'yspz_0000',  'period', '会计期间' ),
( 'yspz_0014',  'bfj_acct', '备付金银行账号' ),
( 'yspz_0014',  'zjbd_type', '资金变动类型 - 账户利息' ),
( 'yspz_0014',  'wlzj_type', '往来资金类型 - 利息收入' ),
( 'yspz_0014',  'period', '会计期间' ),
( 'yspz_0014',  'zjbd_date_in', '备付金银行入账日期' ),
( 'yspz_0014',  'zhlx_amt', '账户利息收入金额' ),
( 'yspz_0003',  'ssn', '交易流水编号' ),
( 'yspz_0003',  'bi', '银行接口编号' ),
( 'yspz_0003',  'p', '产品类型 - 基金收款' ),
( 'yspz_0003',  'cust_proto', '客户协议编号' ),
( 'yspz_0003',  'c', '客户编号' ),
( 'yspz_0003',  'period', '会计期间' ),
( 'yspz_0003',  'tx_date', '交易日期' ),
( 'yspz_0003',  'tx_amt', '支付金额' ),
( 'yspz_0003',  'wk_cfee', '外扣客户手续费' ),
( 'yspz_0010',  'bfj_acct', '备付金银行账号' ),
( 'yspz_0010',  'zyzj_acct', '自有资金银行账号' ),
( 'yspz_0010',  'bfj_zjbd_type', '备付金资金变动类型' ),
( 'yspz_0010',  'zyzj_zjbd_type', '自有资金资金变动类型' ),
( 'yspz_0010',  'period', '会计期间' ),
( 'yspz_0010',  'zjbd_date_out_bfj', '备付金银行出账日期' ),
( 'yspz_0010',  'zjbd_date_in_bfj', '备付金银行入账日期' ),
( 'yspz_0010',  'zjbd_date_out_zyzj', '自有资金银行出账日期' ),
( 'yspz_0010',  'zjbd_date_in_zyzj', '自有资金银行入账日期' ),
( 'yspz_0010',  'yhys_txamt', '已核应收交易款借方汇总' ),
( 'yspz_0010',  'yhys_bamt', '已核应收银行款借方汇总' ),
( 'yspz_0010',  'yhys_bfee', '已核应收银行手续费借方汇总' ),
( 'yspz_0010',  'yhyf_txamt', '已核应付交易款贷方汇总' ),
( 'yspz_0010',  'yhyf_bamt', '已核应付银行款贷方汇总' ),
( 'yspz_0010',  'yhyf_bfee', '已核应付银行手续费贷方汇总' );
