#!/usr/bin/perl
use strict;
use warnings;
use Zeta::Run;
use Zark;
use Data::Dump;
use ZAPP::BIP::Config;
use ZAPP::BIP::Constant;
use Zark;

use constant DEBUG => 1;

BEGIN {
    require Data::Dump;
}

#
# 连接数据库
#
do "$ENV{ZIXAPP_HOME}/libexec/plugin.pl";
my $dbh = zkernel->zapp_dbh();

#
#
#
my $zark   = Zark->new(dbh => $dbh);
my $config = ZAPP::BIP::Config->new( dbh => $dbh );
my %inst;

# {
#     no strict 'refs';
#     my $hash = \*{"Zark::"};
#     Data::Dump->dump($hash);
#     exit 0;
# }
while ( <> ) {

    # 收款客户ID,支付记录编号,我方支付成功日期时间,支付金额,确认外收客户手续费金额总和,银行接口编号,银行支付记录编号 无数据,银行成功日期时间,银行清算日期,确认内扣银行手续费金额总和 无数据,确认外扣银行手续费金额总和 无数据,取数值为1（表示正常）的数据,记录生成日期
    # 20121114018|20130325_131129|2013-03-25 21:44:10.000000|2000.00|11.92|104||2013-03-25 21:44:10.000000|2013-03-25 00:00:00.000000||1.00|1|2013-03-26 10:42:28.000000
    #  文件记录
    #-------------------------------------------------
    #  0  c_merchant_no         | 20121114018
    #  1  c_pay_serialno        | 20130325_131129
    #  2  d_pay_date            | 2013-03-25 21:44:10.000000
    #  3  f_pay_balance         | 2000.00
    #  4  f_income_balance      | 11.92
    #  5  c_channel_no          | 104
    #  6  c_bank_serialno       | 
    #  7  d_bank_confirm_date   | 2013-03-25 21:44:10.000000
    #  8  d_bank_clear_date     | 2013-03-25 00:00:00.000000
    #  9  f_inner_bank_balance  | 
    #  10 f_outer_bank_balance  | 1.00
    #  11 c_reconcile_type      | 1
    #  12 d_create_date         | 2013-03-26 10:42:28.000000
    

    chomp;
    my $row = [ split '\|', $_ ];
    $row->[2]  =~ /(\d{4}-\d{2}-\d{2})/;
    my $date = $1;
    $row->[3]  =~ s/\.//;
    $row->[3] ||= 0;
    $row->[4]  =~ s/\.//;
    $row->[4] ||= 0;

    warn "date is $date";
    warn "process row:\n" .  Data::Dump->dump($row) if DEBUG;

    my $key = '51.' . $row->[5];
    my $inst = ($inst{$key} ||= $config->inst(51, $row->[5]));

    # 获取10项输出数组第一个数组
    my $res = $inst->calc( { amt  => $row->[3], date => $date, })->[0];
    # bfj_bfee, bfj_acct_bfee, zjbd_date_out
    my $bfj_bfee        = 0;
    my $bfj_acct_bfee;
    my $zjbd_date_out;
    # 内扣有值时
    if ($res->[RES_BFEE_NK]) {
        $bfj_bfee       = $res->[RES_BFEE_NK];
    }
    if ($res->[RES_BFEE_NK_ACCT]) {
        $bfj_acct_bfee  = $res->[RES_BFEE_NK_ACCT]; 
    }
    if ($res->[RES_BFEE_NK_OUT]) {
        $zjbd_date_out  = $res->[RES_BFEE_NK_OUT]; 
    }
    # 外扣有值时
    if ($res->[RES_BFEE_WK]) {
        $bfj_bfee       = $res->[RES_BFEE_WK]; 
    }
    if ($res->[RES_BFEE_WK_ACCT]) {
        $bfj_acct_bfee  = $res->[RES_BFEE_WK_ACCT];
    }
    if ($res->[RES_BFEE_WK_OUT]) {
        $zjbd_date_out  = $res->[RES_BFEE_WK_OUT];
    }
    
    # warn "got bip result:[@$res]";

    #
    #  插入0002原始凭证
    #  $load->yspz_ins_0002(@fld);
    #-------------------------------------------------
    #  交易流水编号             :  f0:  ssn
    #  本金备付金银行账号       :  f1:  bfj_acct_bj
    #  备付金银行账号           :  f2:  bfj_acct_bfee
    #  银行接口编号             :  f3:  bi
    #  产品类型 - 基金收款      :  f4:  p
    #  客户协议编号             :  f5:  cust_proto
    #  客户编号                 :  f6:  c
    #  会计期间                 :  f7:  period
    #  交易日期                 :  f8:  tx_date
    #  备付金银行出账日期       :  f9:  zjbd_date_out
    #  本金备付金银行入账日期   :  f10: zjbd_date_in
    #  支付金额                 :  f11: tx_amt
    #  备付金银行手续费         :  f12: bfj_bfee
    #  财务外付银行手续费       :  f13: cwwf_bfee
    #  外扣客户手续费           :  f14: wk_cfee


    $zark->yspz_ins_0002(
        '0',                        # 处理状态:  status
        
        $row->[1],                  # f0:  ssn
        $res->[RES_BJ_ACCT],        # f1:  bfj_acct_bj 
        $bfj_acct_bfee,             # f2:  bfj_acct_bfee
        $res->[RES_BI],             # f3:  bi
        1,                          # f4:  p
        "1_" . $row->[0],           # f5:  cust_proto
        '51.' . $row->[0],          # f6:  c
        $date,                      # f7:  period
        $date,                      # f8:  tx_date
        $zjbd_date_out,             # f9:  zjbd_date_out
        $res->[RES_BJ_IN],          # f10: zjbd_date_in
        $row->[3],                  # f11: tx_amt
        $bfj_bfee,                  # f12: bfj_bfee
        $res->[RES_BFEE_CWWF] || 0,      # f13: cwwf_bfee
        $row->[4],                  # f14: wk_cfee

        undef,                      # 备注:      memo
    );
}
$dbh->commit();
$zark->dtor();
$dbh->rollback();
$dbh->disconnect();

exit 0;

__END__


