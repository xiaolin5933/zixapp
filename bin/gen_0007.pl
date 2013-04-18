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

    # 出款客户ID（基 金公司或销售公司）,支付记录编号,取数值为1的数据表示（结算）,出款金额,确认外收客户手续费金额总和,银行接口编号 无数据,银行成功日期时间,确认内扣银行 手续费金额总和 无数据,确认外扣银行手续费金额总和 无数据,记录生成日期
    # 20121114018|20130325001|1|823633.29||10000000|2013-03-25 00:00:00.000000|||2013-03-26 00:00:00.000000
    #  文件记录
    #-------------------------------------------------
    #  0 C_MERCHANT_NO |       20121114018
    #  1 C_OUT_SERIALNO|       20130325001
    #  2 C_OUT_TYPE|           1
    #  3 F_OUT_BALANCE|        823633.29
    #  4 F_INCOME_BALANCE|     
    #  5 C_BANK_NO|            10000000
    #  6 D_BANK_CONFIRM_DATE|  2013-03-25 00:00:00.0000000
    #  7 F_INNER_BANK_BALANCE| 
    #  8 F_OUTER_BANK_BALANCE| 
    #  9 D_CREATE_DATE |       2013-03-26 00:00:00.000000

    chomp;
    my $row = [ split '\|', $_ ];
    $row->[6] =~ /(\d{4}-\d{2}-\d{2})/;
    my $date = $1;
    $row->[3] =~ s/\.//;
    $row->[3] ||= 0;

    warn "date is $date";
    warn "process row:\n" .  Data::Dump->dump($row) if DEBUG;

    my $dept_id = '51';
    my $dept_bi = $row->[5];
    my $inst = ( $inst{$dept_id . '.' . $dept_bi} ||= $config->inst($dept_id, $dept_bi) );

    # 获取10项输出数组第一个数组
    my $res = $inst->calc( { amt  => $row->[3], date => $date, })->[0];
    warn "got bip result:\n" . Data::Dump->dump($res);

    #
    #  插入0007原始凭证
    #  $load->ypsz_ins_0007(@fld);
    #-------------------------------------------------
    #  流水号                 :  f0: ssn
    #  本金备付金账号         :  f1: bfj_acct_bj
    #  银行接口编号           :  f2: bi
    #  产品编号               :  f3: p
    #  客户编号               :  f4: c
    #  期间日期               :  f5: period
    #  交易日期               :  f6: tx_date
    #  资金变动日期-出账日期  :  f7: zjbd_date_out
    #  交易金额               :  f8: tx_amt
    #  财务外付手续费         :  f9: cwwf_bfee

    
    my @yspz_row = (

        '0',                   # 处理状态:  status

        $row->[1],             # f0 :流水号
        $res->[RES_BJ_ACCT],   # f1 : bfj_acct_bj
        $res->[RES_BI],        # f2 : bi
        2,                     # f3 : p    ??????????????????
        '51.' . $row->[0],     # f4 : c
        $date,                 # f5 : period
        $date,                 # f6 : tx_date
        $res->[RES_BJ_IN],     # f7 : zjbd_date_out
        $row->[3],             # f8 : tx_amt
        $res->[RES_BFEE_CWWF], # f9 : 财务外付银行手续费

        undef,                 # 备注:      memo
    );

    warn "yspz_ins_007 with:\n" . Data::Dump->dump(\@yspz_row);
    $zark->yspz_ins_0007(@yspz_row);
    $dbh->commit();
}

$zark->dtor();
$dbh->rollback();
$dbh->disconnect();

exit 0;

__END__


