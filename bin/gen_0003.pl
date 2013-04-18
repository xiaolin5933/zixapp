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

    # 收款客户ID,支付记录编号,我方支付成功日期时间,支付金额,确认外收客户手续费金额总和,银行接口编号,取数值为2（表示我有银无）的数据,记录生成日期
    # 20121114018|20130325_131129|2013-03-25 21:44:10.000000|2000.00|11.92|104|1|2013-03-26 10:42:28.000000
    #  文件记录
    #-------------------------------------------------
    #  0  c_merchant_no         | 20121114018
    #  1  c_pay_serialno        | 20130325_131129
    #  2  d_pay_date            | 2013-03-25 21:44:10.000000
    #  3  f_pay_balance         | 2000.00
    #  4  f_income_balance      | 11.92
    #  5  c_channel_no          | 104
    #  6  c_reconcile_type      | 1
    #  7  d_create_date         | 2013-03-26 10:42:28.000000


    chomp;
    my $row     = [ split '\|', $_ ];
    $row->[2]   =~ /(\d{4}-\d{2}-\d{2})/;
    my $date    = $1;
    $row->[3]   =~ s/\.//;
    $row->[3]   ||= 0;
    $row->[4]   =~ s/\.//;
    $row->[4]   ||= 0;

    warn "date is $date";
    warn "process row:\n" .  Data::Dump->dump($row) if DEBUG;

    my $dept_id = '51';
    my $dept_bi = $row->[5];
    my $inst = ( $inst{$dept_id . '.' . $dept_bi} ||= $config->inst($dept_id, $dept_bi) );

    # 获取10项输出数组第一个数组
    my $res = $inst->calc( { amt  => $row->[3], date => $date, })->[0];
    warn "got bip result:\n" . Data::Dump->dump($res);

    #
    #  插入0003原始凭证
    #  $load->ypsz_ins_0003(@fld);
    #-------------------------------------------------
    #  交易流水编号         :  f0: ssn
    #  银行接口编号         :  f1: bi
    #  产品类型 - 基金收款  :  f2: p
    #  客户协议编号         :  f3: cust_proto
    #  客户编号             :  f4: c
    #  会计期间             :  f5: period
    #  交易日期             :  f6: tx_date
    #  支付金额             :  f7: tx_amt
    #  外扣客户手续费       :  f8: wk_cfee

    
    my @yspz_row = (

        '0',                    # 处理状态:  status

        $row->[1],              # f0: ssn
        $res->[RES_BI],         # f1: bi
        1,                      # f2: p
        '1_' . $row->[0],       # f3: cust_proto
        '51.' . $row->[0],      # f4: c
        $date,                  # f5: period
        $date,                  # f6: tx_date
        $row->[3],              # f7: tx_amt
        $row->[4],              # f8: wk_cfee
                                
        undef,                  # 备注:      memo
    );

    warn "yspz_ins_0003 with:\n" . Data::Dump->dump(\@yspz_row);
    $zark->yspz_ins_0003(@yspz_row);
    $dbh->commit();
}

$zark->dtor();
$dbh->rollback();
$dbh->disconnect();

exit 0;

__END__


