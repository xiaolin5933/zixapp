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
sub    HF_PERIOD_RTIME     ()  { 7 }

# 交易方向
sub    BJ_DIR_IN           ()  { 1 }
sub    BJ_DIR_OUT          ()  { 2 }

# 手续费方向
sub    BFEE_DIR_IN         ()  { 1 }
sub    BFEE_DIR_OUT        ()  { 2 }
#
# calc函数的输出数据
# 银行接口  + 本金(5项) + 手续费(数组[12相])
#
#
sub    RES_BI              ()  { 0 }
sub    RES_BJ              ()  { 1 }
sub    RES_BFEE            ()  { 2 }

sub    RES_BJ_ACCT         ()  { 0 }
sub    RES_BJ_I            ()  { 1 }
sub    RES_BJ_O            ()  { 2 }
sub    RES_BJ_IN           ()  { 3 }
sub    RES_BJ_OUT          ()  { 4 }

sub    RES_BFEE_NK_ACCT    ()  { 0 }
sub    RES_BFEE_NK_I       ()  { 1 }
sub    RES_BFEE_NK_O       ()  { 2 }
sub    RES_BFEE_NK_OUT     ()  { 3 }
sub    RES_BFEE_NK_IN      ()  { 4 }

sub    RES_BFEE_WK_ACCT    ()  { 5 }
sub    RES_BFEE_WK_I       ()  { 6 }
sub    RES_BFEE_WK_O       ()  { 7 }
sub    RES_BFEE_WK_OUT     ()  { 8 }
sub    RES_BFEE_WK_IN      ()  { 9 }

sub    RES_BFEE_CWWF_I     ()  { 10 }
sub    RES_BFEE_CWWF_O     ()  { 11 }

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
    *{ $pkg . '::HF_PERIOD_RTIME'     } = \&HF_PERIOD_RTIME;

# 交易方向
    *{ $pkg . '::BJ_DIR_IN'           } = \&BJ_DIR_IN;
    *{ $pkg . '::BJ_DIR_OUT'          } = \&BJ_DIR_OUT;

# 手续费方向
    *{ $pkg . '::BFEE_DIR_IN'         } = \&BFEE_DIR_IN;
    *{ $pkg . '::BFEE_DIR_OUT'        } = \&BFEE_DIR_OUT;

# calc函数的10项输出
    *{ $pkg . '::RES_BI'              } = \&RES_BI;
    *{ $pkg . '::RES_BJ'              } = \&RES_BJ;
    *{ $pkg . '::RES_BFEE'            } = \&RES_BFEE;

    *{ $pkg . '::RES_BJ_ACCT'         } = \&RES_BJ_ACCT;
    *{ $pkg . '::RES_BJ_I'            } = \&RES_BJ_I;
    *{ $pkg . '::RES_BJ_O'            } = \&RES_BJ_O;
    *{ $pkg . '::RES_BJ_IN'           } = \&RES_BJ_IN;
    *{ $pkg . '::RES_BJ_OUT'          } = \&RES_BJ_OUT;

    *{ $pkg . '::RES_BFEE_NK_ACCT'    } = \&RES_BFEE_NK_ACCT;
    *{ $pkg . '::RES_BFEE_NK_I'       } = \&RES_BFEE_NK_I;
    *{ $pkg . '::RES_BFEE_NK_O'       } = \&RES_BFEE_NK_O;
    *{ $pkg . '::RES_BFEE_NK_IN'      } = \&RES_BFEE_NK_IN;
    *{ $pkg . '::RES_BFEE_NK_OUT'     } = \&RES_BFEE_NK_OUT;

    *{ $pkg . '::RES_BFEE_WK_ACCT'    } = \&RES_BFEE_WK_ACCT;
    *{ $pkg . '::RES_BFEE_WK_I'       } = \&RES_BFEE_WK_I;
    *{ $pkg . '::RES_BFEE_WK_O'       } = \&RES_BFEE_WK_O;
    *{ $pkg . '::RES_BFEE_WK_IN'      } = \&RES_BFEE_WK_IN;
    *{ $pkg . '::RES_BFEE_WK_OUT'     } = \&RES_BFEE_WK_OUT;

    *{ $pkg . '::RES_BFEE_CWWF_I'     } = \&RES_BFEE_CWWF_I;
    *{ $pkg . '::RES_BFEE_CWWF_O'     } = \&RES_BFEE_CWWF_O;


};

1;

__END__

