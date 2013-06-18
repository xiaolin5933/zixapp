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
('class', '3', '往来类', '往来类'),
('class', '4', '共同类', '共同类'),
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
( 'yspz_0010',  'yhyf_bfee', '已核应付银行手续费贷方汇总' ),
( 'yspz_0016',  'bfj_acct_1', '银行成本1备付金银行账号' ),
( 'yspz_0016',  'bfj_acct_2', '银行成本2备付金银行账号' ),
( 'yspz_0016',  'bfj_acct_3', '银行成本3备付金银行账号' ),
( 'yspz_0016',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0016',  'bi', '银行接口编号' ),
( 'yspz_0016',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0016',  'p', '产品类型' ),
( 'yspz_0016',  'period', '会计期间' ),
( 'yspz_0016',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0016',  'zjbd_date_out_1', '银行成本1备付金银行出账日期' ),
( 'yspz_0016',  'zjbd_date_out_2', '银行成本2备付金银行出账日期' ),
( 'yspz_0016',  'zjbd_date_out_3', '银行成本3备付金银行出账日期' ),
( 'yspz_0016',  'tx_date', '交易日期' ),
( 'yspz_0016',  'ssn', '交易流水编号' ),
( 'yspz_0016',  'c', '客户编号' ),
( 'yspz_0016',  'psp_c', '分润客户编号' ),
( 'yspz_0016',  'cust_proto', '分润客户协议编号' ),
( 'yspz_0016',  'bfee', '银联银行成本数额' ),
( 'yspz_0016',  'bfee_1', '银行成本1备付金扣金额' ),
( 'yspz_0016',  'bfee_2', '银行成本2备付金扣金额' ),
( 'yspz_0016',  'bfee_3', '银行成本3备付金扣金额' ),
( 'yspz_0016',  'lfee', '银联品牌费数额' ),
( 'yspz_0016',  'psp_lfee', '分润方承担的品牌费' ),
( 'yspz_0016',  'cfee', '备付金扣客户手续费收入' ),
( 'yspz_0016',  'psp_amt', '备付金扣实时分润金额' ),
( 'yspz_0017',  'bfj_acct_1', '银行成本1备付金银行账号' ),
( 'yspz_0017',  'bfj_acct_2', '银行成本2备付金银行账号' ),
( 'yspz_0017',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0017',  'bi', '银行接口编号' ),
( 'yspz_0017',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0017',  'p', '产品类型' ),
( 'yspz_0017',  'period', '会计期间' ),
( 'yspz_0017',  'zjbd_date_out', '本金备付金银行出账日期' ),
( 'yspz_0017',  'zjbd_date_in_1', '银行成本1备付金银行入账日期' ),
( 'yspz_0017',  'zjbd_date_in_2', '银行成本2备付金银行入账日期' ),
( 'yspz_0017',  'tx_date', '交易日期' ),
( 'yspz_0017',  'ssn', '交易流水编号' ),
( 'yspz_0017',  'c', '客户编号' ),
( 'yspz_0017',  'psp_c', '分润客户编号' ),
( 'yspz_0017',  'cust_proto', '分润客户协议编号' ),
( 'yspz_0017',  'bfee', '退回银联银行成本数额' ),
( 'yspz_0017',  'bfee_1', '退回银行成本1备付金扣金额' ),
( 'yspz_0017',  'bfee_2', '退回银行成本2备付金扣金额' ),
( 'yspz_0017',  'cfee', '退回备付金扣客户手续费金额' ),
( 'yspz_0017',  'psp_amt', '退回备付金扣实时分润金额' ),
( 'yspz_0019',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0019',  'bfj_acct', '备付金内扣银行账号' ),
( 'yspz_0019',  'bi', '银行接口编号' ),
( 'yspz_0019',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0019',  'p', '产品类型' ),
( 'yspz_0019',  'period', '会计期间' ),
( 'yspz_0019',  'zjbd_date_out_bj', '本金备付金银行出账日期' ),
( 'yspz_0019',  'zjbd_date_out', '备付金内扣银行出账日期' ),
( 'yspz_0019',  'tx_date', '交易日期' ),
( 'yspz_0019',  'ssn', '交易流水编号' ),
( 'yspz_0019',  'c', '客户编号' ),
( 'yspz_0019',  'cust_proto', '客户协议编号' ),
( 'yspz_0019',  'tx_amt', '出款金额' ),
( 'yspz_0019',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0019',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0019',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0019',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0019',  'bfee', '备付金内扣银行手续费金额' ),
( 'yspz_0019',  'cwwf_bfee', '财务外付银行手续费金额' ),
( 'yspz_0020',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0020',  'bi', '银行接口编号' ),
( 'yspz_0020',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0020',  'p', '产品类型' ),
( 'yspz_0020',  'period', '会计期间' ),
( 'yspz_0020',  'zjbd_date_out_bj', '本金备付金银行出账日期' ),
( 'yspz_0020',  'tx_date', '交易日期' ),
( 'yspz_0020',  'ssn', '交易流水编号' ),
( 'yspz_0020',  'c', '客户编号' ),
( 'yspz_0020',  'cust_proto', '客户协议编号' ),
( 'yspz_0020',  'tx_amt', '出款金额' ),
( 'yspz_0020',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0020',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0020',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0020',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0021',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0021',  'bfj_acct', '备付金内扣银行账号' ),
( 'yspz_0021',  'bi', '银行接口编号' ),
( 'yspz_0021',  'p', '产品类型' ),
( 'yspz_0021',  'period', '会计期间' ),
( 'yspz_0021',  'zjbd_date_out_bj', '本金备付金银行出账日期' ),
( 'yspz_0021',  'zjbd_date_out', '备付金内扣银行出账日期' ),
( 'yspz_0021',  'tx_date', '交易日期' ),
( 'yspz_0021',  'ssn', '交易流水编号' ),
( 'yspz_0021',  'wqr_c', '未确认客户编号' ),
( 'yspz_0021',  'bfee', '备付金内扣银行手续费金额' ),
( 'yspz_0021',  'cwwf_bfee', '财务外付银行手续费金额' ),
( 'yspz_0021',  'tx_amt', '出款金额' ),
( 'yspz_0024',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0024',  'bfj_acct', '备付金内扣银行账号' ),
( 'yspz_0024',  'bi', '银行接口编号' ),
( 'yspz_0024',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0024',  'p', '产品类型' ),
( 'yspz_0024',  'period', '会计期间' ),
( 'yspz_0024',  'zjbd_date_out_bj', '本金备付金银行出账日期' ),
( 'yspz_0024',  'zjbd_date_out', '备付金内扣银行出账日期' ),
( 'yspz_0024',  'tx_date', '交易日期' ),
( 'yspz_0024',  'ssn', '交易流水编号' ),
( 'yspz_0024',  'c', '客户编号' ),
( 'yspz_0024',  'wqr_c', '未确认客户编号' ),
( 'yspz_0024',  'cust_proto', '客户协议编号' ),
( 'yspz_0024',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0024',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0024',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0024',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0024',  'bfee', '确认的银行成本金额' ),
( 'yspz_0024',  'tx_amt', '出款金额' ),
( 'yspz_0028',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0028',  'p', '产品类型 - 结算' ),
( 'yspz_0028',  'period', '会计期间' ),
( 'yspz_0028',  'tx_date', '交易日期' ),
( 'yspz_0028',  'ssn', '交易流水编号' ),
( 'yspz_0028',  'c', '客户编号' ),
( 'yspz_0028',  'cust_proto', '客户协议编号' ),
( 'yspz_0028',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0028',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0028',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0028',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0030',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0030',  'bi', '银行接口编号' ),
( 'yspz_0030',  'period', '会计期间' ),
( 'yspz_0030',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0030',  'ssn', '交易流水编号' ),
( 'yspz_0030',  'c', '客户编号' ),
( 'yspz_0030',  'tx_amt', '出款退回金额' ),
( 'yspz_0029',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0029',  'bfj_acct', '备付金内扣银行账号' ),
( 'yspz_0029',  'bi', '银行接口编号' ),
( 'yspz_0029',  'p', '产品类型 - 结算' ),
( 'yspz_0029',  'fp', '确认规则' ),
( 'yspz_0029',  'period', '会计期间' ),
( 'yspz_0029',  'zjbd_date_out_bj', '本金备付金银行出账日期' ),
( 'yspz_0029',  'zjbd_date_out', '备付金内扣银行出账日期' ),
( 'yspz_0029',  'tx_date', '交易日期' ),
( 'yspz_0029',  'ssn', '交易流水编号' ),
( 'yspz_0029',  'c', '客户编号' ),
( 'yspz_0029',  'bfee', '备付金内扣银行手续费金额' ),
( 'yspz_0029',  'cwwf_bfee', '财务外付银行手续费金额' ),
( 'yspz_0029',  'zg_bfee', '暂估银行手续费金额' ),
( 'yspz_0029',  'tx_amt', '出款金额' ),
( 'yspz_0018',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0018',  'zjbd_type', '资金变动类型 - 银行转账充值' ),
( 'yspz_0018',  'period', '会计期间' ),
( 'yspz_0018',  'zjbd_date_in', '本金备付金银行入账日期' ),
( 'yspz_0018',  'c', '客户编号' ),
( 'yspz_0018',  'tx_amt', '客户备付金汇入金额' ),
( 'yspz_0022',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0022',  'bfj_acct', '备付金内扣银行账号' ),
( 'yspz_0022',  'bi', '银行接口编号' ),
( 'yspz_0022',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0022',  'p', '产品类型' ),
( 'yspz_0022',  'period', '会计期间' ),
( 'yspz_0022',  'zjbd_date_out_bj', '本金备付金银行出账日期' ),
( 'yspz_0022',  'zjbd_date_out', '备付金内扣银行出账日期' ),
( 'yspz_0022',  'tx_date', '交易日期' ),
( 'yspz_0022',  'ssn', '交易流水编号' ),
( 'yspz_0022',  'c', '客户编号' ),
( 'yspz_0022',  'cust_proto', '客户协议编号' ),
( 'yspz_0022',  'tx_amt', '出款金额' ),
( 'yspz_0022',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0022',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0022',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0022',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0022',  'bfee', '备付金内扣银行手续费金额' ),
( 'yspz_0022',  'cwwf_bfee', '财务外付银行手续费金额' ),
( 'yspz_0023',  'bi', '银行接口编号' ),
( 'yspz_0023',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0023',  'p', '产品类型' ),
( 'yspz_0023',  'period', '会计期间' ),
( 'yspz_0023',  'tx_date', '交易日期' ),
( 'yspz_0023',  'ssn', '交易流水编号' ),
( 'yspz_0023',  'c', '客户编号' ),
( 'yspz_0023',  'cust_proto', '客户协议编号' ),
( 'yspz_0023',  'tx_amt', '出款金额' ),
( 'yspz_0023',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0023',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0023',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0023',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0025',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0025',  'bi', '银行接口编号' ),
( 'yspz_0025',  'period', '会计期间' ),
( 'yspz_0025',  'zjbd_date_in_bj', '本金备付金银行入账日期' ),
( 'yspz_0025',  'tx_date', '交易日期' ),
( 'yspz_0025',  'ssn', '交易流水编号' ),
( 'yspz_0025',  'tx_amt', '追回出款金额' ),
( 'yspz_0026',  'bi', '银行接口编号' ),
( 'yspz_0026',  'p', '产品类型' ),
( 'yspz_0026',  'period', '会计期间' ),
( 'yspz_0026',  'tx_date', '交易日期' ),
( 'yspz_0026',  'ssn', '交易流水编号' ),
( 'yspz_0026',  'c', '客户编号' ),
( 'yspz_0026',  'tx_amt', '出款损失金额' ),
( 'yspz_0027',  'bfj_acct_bj', '本金备付金银行账号' ),
( 'yspz_0027',  'bi', '银行接口编号' ),
( 'yspz_0027',  'wlzj_type', '往来类型 - 客户手续费' ),
( 'yspz_0027',  'p', '产品类型' ),
( 'yspz_0027',  'period', '会计期间' ),
( 'yspz_0027',  'zjbd_date_in_bj', '本金备付金银行入账日期' ),
( 'yspz_0027',  'tx_date', '交易日期' ),
( 'yspz_0027',  'ssn', '交易流水编号' ),
( 'yspz_0027',  'c', '客户编号' ),
( 'yspz_0027',  'cust_proto', '客户协议编号' ),
( 'yspz_0027',  'cfee', '备付金内扣客户手续费金额' ),
( 'yspz_0027',  'cfee_back', '退回备付金内扣客户手续费金额' ),
( 'yspz_0027',  'cwws_cfee', '财务外收客户手续费金额' ),
( 'yspz_0027',  'cwws_cfee_back', '退回财务外收客户手续费金额' ),
( 'yspz_0027',  'tx_amt', '出款金额' );
