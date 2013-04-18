package ZAPP::BIP::Constant;
use strict;
use warnings;

# 账户类别
sub    ACCT_TYPE_BFJ       ()  { 1 }   # 备付金账号
sub    ACCT_TYPE_ZYZJ      ()  { 2 }   # 自有资金账号

# 手续费计算模式
sub    MODE_RATIO          ()  { 1 } # 按比列
sub    MODE_QUOTA          ()  { 2 } # 单笔定额

# 取整规则
sub    ROUND_NORM          ()  { 1 } # 四舍五入
sub    ROUND_UP            ()  { 2 } # 向上取整 
sub    ROUND_DOWN          ()  { 3 } # 向下取整

# 划付类型
sub    HF_TYPE_F           ()  { 1 } # 财务支付
sub    HF_TYPE_NF          ()  { 2 } # 非财务

# 划付周期
sub    HF_PERIOD_DAY       ()  { 1 }
sub    HF_PERIOD_WEEK      ()  { 2 }
sub    HF_PERIOD_MONTH     ()  { 3 }
sub    HF_PERIOD_QUARTER   ()  { 4 }
sub    HF_PERIOD_SEMI_YEAR ()  { 5 }
sub    HF_PERIOD_YEAR      ()  { 6 }

# calc函数的10项输出
sub    RES_BJ_ACCT         ()  { 0 }
sub    RES_BJ_IN           ()  { 1 }

sub    RES_BFEE_NK         ()  { 2 }
sub    RES_BFEE_NK_ACCT    ()  { 3 }
sub    RES_BFEE_NK_OUT     ()  { 4 }

sub    RES_BFEE_WK         ()  { 5 }
sub    RES_BFEE_WK_ACCT    ()  { 6 }
sub    RES_BFEE_WK_OUT     ()  { 7 }

sub    RES_BFEE_CWWF       ()  { 8 }

sub    RES_BI              ()  { 9 }


#
# 输出
#
sub import {

    my $pkg = caller();
    no strict 'refs';

# 账户类别
    *{ $pkg . '::ACCT_TYPE_BFJ'       } = \&ACCT_TYPE_BFJ;
    *{ $pkg . '::ACCT_TYPE_ZYZJ'      } = \&ACCT_TYPE_ZYZJ;

# 手续费计算模式
    *{ $pkg . '::MODE_RATIO'          } = \&MODE_RATIO;
    *{ $pkg . '::MODE_QUOTA'          } = \&MODE_QUOTA;

# 取整规则
    *{ $pkg . '::ROUND_NORM'          } = \&ROUND_NORM ;
    *{ $pkg . '::ROUND_UP'            } = \&ROUND_UP;
    *{ $pkg . '::ROUND_DOWN'          } = \&ROUND_DOWN;

# 划付类型
    *{ $pkg . '::HF_TYPE_F'           } = \&HF_TYPE_F;
    *{ $pkg . '::HF_TYPE_NF'          } = \&HF_TYPE_NF;

# 划付周期
    *{ $pkg . '::HF_PERIOD_DAY'       } = \&HF_PERIOD_DAY;
    *{ $pkg . '::HF_PERIOD_WEEK'      } = \&HF_PERIOD_WEEK;
    *{ $pkg . '::HF_PERIOD_MONTH'     } = \&HF_PERIOD_MONTH;
    *{ $pkg . '::HF_PERIOD_QUARTER'   } = \&HF_PERIOD_QUARTER;
    *{ $pkg . '::HF_PERIOD_SEMI_YEAR' } = \&HF_PERIOD_SEMI_YEAR;
    *{ $pkg . '::HF_PERIOD_YEAR'      } = \&HF_PERIOD_YEAR;

# calc函数的10项输出
    *{ $pkg . '::RES_BJ_ACCT'         } = \&RES_BJ_ACCT;
    *{ $pkg . '::RES_BJ_IN'           } = \&RES_BJ_IN;

    *{ $pkg . '::RES_BFEE_NK'         } = \&RES_BFEE_NK;
    *{ $pkg . '::RES_BFEE_NK_ACCT'    } = \&RES_BFEE_NK_ACCT;
    *{ $pkg . '::RES_BFEE_NK_OUT'     } = \&RES_BFEE_NK_OUT;

    *{ $pkg . '::RES_BFEE_WK'         } = \&RES_BFEE_WK;
    *{ $pkg . '::RES_BFEE_WK_ACCT'    } = \&RES_BFEE_WK_ACCT;
    *{ $pkg . '::RES_BFEE_WK_OUT'     } = \&RES_BFEE_WK_OUT;

    *{ $pkg . '::RES_BFEE_CWWF'       } = \&RES_BFEE_CWWF;

    *{ $pkg . '::RES_BI'              } = \&RES_BI;

};

1;

__END__

