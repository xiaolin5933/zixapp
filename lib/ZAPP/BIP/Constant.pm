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

# 直接确认 或 周期确认
sub    ACK_DIRECT          ()  { 1 } # 直接确认
sub    ACK_PERIOD          ()  { 2 } # 周期确认

# 确认方式
sub    ACK_TYPE_PACK       ()  { 1 } # 1 包周期(月，年)
sub    ACK_TYPE_LADDER     ()  { 2 } # 2 阶梯
sub    ACK_TYPE_SECTION    ()  { 3 } # 3 分段

#
# 统一输出数据格式
# 银行接口  + 本金(5项) + 直接确认方式手续费(数组[12项]) + 周期确认方式手续费(数组[21项])
#
#
sub    RES_BI              ()  { 0 }    # 银行接口
sub    RES_BJ              ()  { 1 }    # 本金相关
sub    RES_BFEE            ()  { 2 }    # 直接确认手续费
sub    RES_PBFEE           ()  { 3 }    # 周期确认手续费

sub    RES_BJ_ACCT         ()  { 0 }
sub    RES_BJ_I            ()  { 1 }
sub    RES_BJ_O            ()  { 2 }
sub    RES_BJ_IN           ()  { 3 }
sub    RES_BJ_OUT          ()  { 4 }

sub    RES_BFEE_BFJ_ACCT    ()  { 0 }
sub    RES_BFEE_BFJ_I       ()  { 1 }
sub    RES_BFEE_BFJ_O       ()  { 2 }
sub    RES_BFEE_BFJ_OUT     ()  { 3 }
sub    RES_BFEE_BFJ_IN      ()  { 4 }

sub    RES_BFEE_ZYZJ_ACCT   ()  { 5 }
sub    RES_BFEE_ZYZJ_I      ()  { 6 }
sub    RES_BFEE_ZYZJ_O      ()  { 7 }
sub    RES_BFEE_ZYZJ_OUT    ()  { 8 }
sub    RES_BFEE_ZYZJ_IN     ()  { 9 }

sub    RES_BFEE_CWWF_I     ()  { 10 }
sub    RES_BFEE_CWWF_O     ()  { 11 }

sub    RES_PBFEE_ZG_I      ()   { 0 }       # 收暂估手续费
sub    RES_PBFEE_ZG_O      ()   { 1 }       # 付暂估手续费
sub    RES_PBFEE_FP_ID     ()   { 2 }       # 确认规则id

sub    RES_PBFEE_PERIOD    ()   { 3 }       # 确认规则下指定周期
sub    RES_PBFEE_RATIO     ()   { 4 }       # 总的打折比例

sub    RES_PBFEE_BFJ_ACCT  ()   { 5 }       # 备付金手续费帐号
sub    RES_PBFEE_BFJ_DATE  ()   { 6 }       # 备付金手续费日期
sub    RES_PBFEE_BFJ_FEE   ()   { 7 }       # 备付金手续费

sub    RES_PBFEE_ZYZJ_ACCT ()   { 8 }       # 自有资金手续费帐号
sub    RES_PBFEE_ZYZJ_DATE ()   { 9 }       # 自有资金手续费日期
sub    RES_PBFEE_ZYZJ_FEE  ()  { 10 }       # 收自有资金手续费

sub    RES_PBFEE_CWWF_FEE  ()  { 11 }       # 付财务外付手续费

sub    RES_PBFEE_SM_DATE   ()  { 12 }       # 扫描日期


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

# 直接确认 或 周期确认
    *{ $pkg . '::ACK_DIRECT'          } = \&ACK_DIRECT;
    *{ $pkg . '::ACK_PERIOD'          } = \&ACK_PERIOD;      

# 确认方式
    *{ $pkg . '::ACK_TYPE_PACK'       } = \&ACK_TYPE_PACK;
    *{ $pkg . '::ACK_TYPE_LADDER'     } = \&ACK_TYPE_LADDER;
    *{ $pkg . '::ACK_TYPE_SECTION'    } = \&ACK_TYPE_SECTION;

# 统一输出
    *{ $pkg . '::RES_BI'              } = \&RES_BI;
    *{ $pkg . '::RES_BJ'              } = \&RES_BJ;
    *{ $pkg . '::RES_BFEE'            } = \&RES_BFEE;
    *{ $pkg . '::RES_PBFEE'           } = \&RES_PBFEE;

    *{ $pkg . '::RES_BJ_ACCT'         } = \&RES_BJ_ACCT;
    *{ $pkg . '::RES_BJ_I'            } = \&RES_BJ_I;
    *{ $pkg . '::RES_BJ_O'            } = \&RES_BJ_O;
    *{ $pkg . '::RES_BJ_IN'           } = \&RES_BJ_IN;
    *{ $pkg . '::RES_BJ_OUT'          } = \&RES_BJ_OUT;

    *{ $pkg . '::RES_BFEE_BFJ_ACCT'   } = \&RES_BFEE_BFJ_ACCT;
    *{ $pkg . '::RES_BFEE_BFJ_I'      } = \&RES_BFEE_BFJ_I;
    *{ $pkg . '::RES_BFEE_BFJ_O'      } = \&RES_BFEE_BFJ_O;
    *{ $pkg . '::RES_BFEE_BFJ_IN'     } = \&RES_BFEE_BFJ_IN;
    *{ $pkg . '::RES_BFEE_BFJ_OUT'    } = \&RES_BFEE_BFJ_OUT;

    *{ $pkg . '::RES_BFEE_ZYZJ_ACCT'  } = \&RES_BFEE_ZYZJ_ACCT;
    *{ $pkg . '::RES_BFEE_ZYZJ_I'     } = \&RES_BFEE_ZYZJ_I;
    *{ $pkg . '::RES_BFEE_ZYZJ_O'     } = \&RES_BFEE_ZYZJ_O;
    *{ $pkg . '::RES_BFEE_ZYZJ_IN'    } = \&RES_BFEE_ZYZJ_IN;
    *{ $pkg . '::RES_BFEE_ZYZJ_OUT'   } = \&RES_BFEE_ZYZJ_OUT;

    *{ $pkg . '::RES_BFEE_CWWF_I'     } = \&RES_BFEE_CWWF_I;
    *{ $pkg . '::RES_BFEE_CWWF_O'     } = \&RES_BFEE_CWWF_O;

    *{ $pkg . '::RES_PBFEE_ZG_I'      } = \&RES_PBFEE_ZG_I;
    *{ $pkg . '::RES_PBFEE_ZG_O'      } = \&RES_PBFEE_ZG_O;
    *{ $pkg . '::RES_PBFEE_FP_ID'     } = \&RES_PBFEE_FP_ID;
    *{ $pkg . '::RES_PBFEE_PERIOD'    } = \&RES_PBFEE_PERIOD;
    *{ $pkg . '::RES_PBFEE_RATIO'     } = \&RES_PBFEE_RATIO;

    *{ $pkg . '::RES_PBFEE_BFJ_ACCT'  } = \&RES_PBFEE_BFJ_ACCT;
    *{ $pkg . '::RES_PBFEE_BFJ_DATE'  } = \&RES_PBFEE_BFJ_DATE;
    *{ $pkg . '::RES_PBFEE_BFJ_FEE'   } = \&RES_PBFEE_BFJ_FEE;

    *{ $pkg . '::RES_PBFEE_ZYZJ_ACCT' } = \&RES_PBFEE_ZYZJ_ACCT;
    *{ $pkg . '::RES_PBFEE_ZYZJ_DATE' } = \&RES_PBFEE_ZYZJ_DATE;
    *{ $pkg . '::RES_PBFEE_ZYZJ_FEE'  } = \&RES_PBFEE_ZYZJ_FEE;

    *{ $pkg . '::RES_PBFEE_CWWF_FEE'  } = \&RES_PBFEE_CWWF_FEE;

    *{ $pkg . '::RES_PBFEE_SM_DATE'   } = \&RES_PBFEE_SM_DATE;


};

1;

__END__

