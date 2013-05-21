package ZAPP::BIP::Inst;
use strict;
use warnings;
use ZAPP::BIP::Constant;
use constant {
    DEBUG       =>  $ENV{ZAPP_BIP_INST_DEBUG} || 0,
    CACHE_SIZE  =>  3, 
};

BEGIN {
   require Data::Dump if DEBUG;
}

##########################################################################
# 参数:
# (
#     acct    => $acct,
#     proto   => $proto,
#     bi      => $bi,
#     matcher => $matcher,
# )
#
# 对象结构
# {
#    cfg     => $cfg,
#
#    acct    => $acct,
#    bi      => 
#    proto   => 
#    matcher =>
#
#    lru => [ '2013-04-24', '2013-0425' ],
#    cache  => {
#        '2013-04-24' => $proto[$i],
#        '2013-04-25' => $proto[$i],
#    },
# }
##########################################################################
sub new {
    my $class = shift;
    my $self = bless { @_ }, $class;

    # 协议匹配缓存
    $self->{cache} = {};
    $self->{lru}   = [];

    return $self;
}

#############################################
#  req = {
#      date      => '银行清算日期',
#      amt       => '金额',
#      matcher   => 'mcc',
#      tx_date   => '交易金额',
#  }
#
#  res =   [
#     $bi,
#     [
#        
#     ],
#     [
#       [  ...    ],  # 规则1处理结果 
#       [  ...    ],  # 规则2处理结果 
#     ]
#  ]
#############################################
sub calc {

    my ($self, $req) = @_;
    $req->{matcher} ||= '-1';

    # 查找协议
    return unless my $proto = $self->_find_proto($req);
    warn "INFO>: 找到协议:\n" . Data::Dump->dump($proto) if DEBUG;

    # 查找规则组
    return unless my $group = $self->_find_group($req, $proto);   
    warn "INFO>: 找到规则组:\n" . Data::Dump->dump($group)  if DEBUG;

    # 返回值
    my @res; 

    # 第一部分: 输出接口
    $res[RES_BI] = $self->{bi};

    # 第二部分: 输出本金信息(5项)
    $res[RES_BJ][RES_BJ_ACCT] = $proto->{bjhf}->{acct};
    if ($group->{dir} == BJ_DIR_IN ) {  
        $res[RES_BJ][RES_BJ_I]  = $req->{amt};
        $res[RES_BJ][RES_BJ_IN] = $self->_inout_date($proto->{bjhf}, $req->{date}, $req->{tx_date});
    }
    elsif ($group->{dir} == BJ_DIR_OUT) {
        $res[RES_BJ][RES_BJ_O]   = $req->{amt};
        $res[RES_BJ][RES_BJ_OUT] = $self->_inout_date($proto->{bjhf}, $req->{date}, $req->{tx_date});
    }
    else {
        warn "internal error";
        return;
    }

    # 第三部分: 输出手续费信息数组(12项)
    for my $rule (@{$group->{rules}}) {
        my $bfee = $self->_bfee($req, $proto, $rule);
        warn "不能计算手续费" and return unless defined $bfee;

        my $bfee_rec;
        if ($rule->{dir} == BFEE_DIR_IN) {
            $bfee_rec = $self->_bfee_in($req, $proto, $rule, $bfee);
            warn "不能设置_bfee_in" and return  unless defined $bfee_rec;
        }
        elsif ($rule->{dir} == BFEE_DIR_OUT)  {
            $bfee_rec = $self->_bfee_out($req, $proto, $rule, $bfee);
            warn "不能设置_bfee_out" and return  unless defined $bfee_rec;
        }
        else {
            warn "internal error";
            return;
        }
        push @{$res[RES_BFEE]}, $bfee_rec;
    } 

    return \@res;
}


####################################################
# 计算本金、手续费出入账日期
# 输入:
#   {
#      period  => '划付周期',
#      delay   => '划付延迟',
#      nwd     => '非工作日是否划付',
#   },
#   $date,
#   $tx_date,
# 输出:
####################################################
sub _inout_date {

    my ($self, $hf, $date, $tx_date) = @_;

    my $dt;

    # 日,月,季度,半年,年
    if    ($hf->{period} == HF_PERIOD_DAY)       { $dt = $date; }
    elsif ($hf->{period} == HF_PERIOD_WEEK)      { $dt = $self->{cfg}{dt}->week_last($date)      } # $dt所在周的最后一天 
    elsif ($hf->{period} == HF_PERIOD_MONTH)     { $dt = $self->{cfg}{dt}->month_last($date)     } # $dt所在月的最后一天 
    elsif ($hf->{period} == HF_PERIOD_QUARTER)   { $dt = $self->{cfg}{dt}->quarter_last($date)   } # $dt所在季度的最后一天 
    elsif ($hf->{period} == HF_PERIOD_SEMI_YEAR) { $dt = $self->{cfg}{dt}->semi_year_last($date) } # $dt所在半年的最后一天 
    elsif ($hf->{period} == HF_PERIOD_YEAR)      { $dt = $self->{cfg}{dt}->year_last($date)      } # $dt所在年的最后一天 
    elsif ($hf->{period} == HF_PERIOD_RTIME)     { $dt = $tx_date; }                               # 实时划付
    else { warn "ERROR: internal error"; return; }

    #  加上划付延迟
    $dt = $self->{cfg}{dt}->next_n_day($dt, $hf->{delay});

    #  不是工作日
    unless( $self->{cfg}{dt}->is_wday($dt) ) {  # 
        # 非工作日是否划付
        unless ( $hf->{nwd} )  {    # 非工作日 不划付, 取下一工作日
            $dt = $self->{cfg}{dt}->next_n_wday($dt, 1);  
        }
    }

    return $dt; 
}

#
# 查找规则组-根据matcher
# req提供了matcher, 就返回match后的规则组
# 没有matcher就返回第一个规则组
#
sub _find_group {
    my ($self, $req, $proto) = @_;
    # warn "查找规则组:\n" . Data::Dump->dump($self->{matcher}) if DEBUG;
    return $self->{matcher}{$req->{matcher}}{$proto->{id}};
}

#
# 查找协议-根据银行清算日期
# $self->_find_proto($req);
#
sub _find_proto {

    my ($self, $req) = @_;
    my $proto = $self->{cache}->{$req->{date}};
    unless ( $proto ) {

        # 查找协议
        for (@{$self->{proto}}) {
            my $flag1 = $req->{date} cmp $_->{begin};
            my $flag2 = $req->{date} cmp $_->{end};
            warn "try 协议[$_->{begin}, $_->{end})] [$flag1, $flag2]..." if DEBUG;
            if ($flag1 >= 0  && $flag2 <= 0) {
                $proto = $_;
                last;
            }
        }
        unless($proto) {
            warn "ERROR: 没有合适协议, 清算日期[$req->{date}]";
            return;
        }        
 
        # 找到协议, 放入cache  LRU清理cache
        delete $self->{cache}->{shift @{$self->{lru}}} if @{$self->{lru}} > CACHE_SIZE;
        push @{$self->{lru}}, $req->{date};
        $self->{cache}->{$req->{date}} = $proto; 
    }
}

#
# 计算银行手续费
# $self->_bfee($req, $proto, $rule);
#
sub _bfee {

    my ($self, $req, $proto, $rule) = @_;

    # 目前只有阶梯, 找出金额所在阶梯
    my $sect;
    for (@{$rule->{sect}}) {
        $sect = $_ and last  if $req->{amt} >= $_->{begin} && $req->{amt} < $_->{end};
    }
    unless($sect) {
        warn "ERROR: can not find algo sect for amt[$req->{amt}]";
        return
    }
    warn "金额[$req->{amt}] 找到阶梯[$sect->{begin}, $sect->{end})" if DEBUG;

    # 开始计算
    my $bfee;
    if ($sect->{mode} == MODE_QUOTA) {
       $bfee =  $sect->{quota};
    }
    elsif ($sect->{mode} == MODE_RATIO) {

        # 执行取整规则
        $bfee = $sect->{ratio} * $req->{amt} / 1000000;
        if ( $proto->{round} == ROUND_NORM) {
            $bfee = int($bfee + 0.5);
        }
        elsif( $proto->{round} == ROUND_UP) {
            if ($bfee =~ /\./) {
                $bfee = int($bfee + 1);
            } 
        }
        elsif( $proto->{round} == ROUND_DOWN ) {
            $bfee =~ s/\..*$//;
        }
        else {
            warn "ERROR: internal error, invalid proto field[round]";
            return;
        }

        # 封顶保底判断
        $bfee = $bfee > $sect->{ceiling} ? $sect->{ceiling} : $bfee  if defined $sect->{ceiling};
        $bfee = $bfee < $sect->{floor}   ? $sect->{floor}   : $bfee  if defined $sect->{floor};
    }
    else {
        warn "ERROR: internal error, invalid sect field[mode]";
        return;
    }
    return $bfee; 
}

#
# 手续费-入 记录
#
sub _bfee_in {
    my ($self, $req, $proto, $rule, $bfee) = @_;

    # 本金相关
    my @rec;

    # 银行手续费划付信息
    my $hf = $rule->{hf};
    if ( $hf->{type} == HF_TYPE_F) {     # 财务付款
        $rec[RES_BFEE_CWWF_I] = $bfee;
    }
    elsif ($hf->{type} == HF_TYPE_NF) {  # 非财务付款
        # 判断手续费划付账户类型: 自有资金 or 备付金
        if ( $self->{acct}->{$hf->{acct}}->{sub_type} == ACCT_TYPE_BFJ ) {  # 手续费划付账号为备付金账号

            # 备付金划付银行账号 == 手续费划付账号 
            # 为备付金内扣
            if ( $proto->{bjhf}->{acct} == $hf->{acct} ) {
                $rec[RES_BFEE_NK_ACCT] = $hf->{acct};
                $rec[RES_BFEE_NK_I]  = $bfee;
                $rec[RES_BFEE_NK_IN] = $self->_inout_date($hf, $req->{date}, $req->{tx_date});
            }
            # 备付金外扣
            else {
                $rec[RES_BFEE_WK_ACCT] = $hf->{acct};
                $rec[RES_BFEE_WK_I]  = $bfee;
                $rec[RES_BFEE_WK_IN] = $self->_inout_date($hf, $req->{date}, $req->{tx_date});
            }
        }  
        else { # 自有资金 
            warn "ERROR: 暂不支持自有资金划付银行手续费";
            return;
        }
    }
    else {
        warn "ERROR: invalid 划付方式";
        return;
    }

    return \@rec;
}

#
# 手续费-出 记录
#
sub _bfee_out {
    my ($self, $req, $proto, $rule, $bfee) = @_;

    # 本金相关
    my @rec;

    # 银行手续费划付信息
    my $hf = $rule->{hf};
    if ( $hf->{type} == HF_TYPE_F) {     # 财务付款
        $rec[RES_BFEE_CWWF_O] = $bfee;
    }
    elsif ($hf->{type} == HF_TYPE_NF) {  # 非财务付款
        # 判断手续费划付账户类型: 自有资金 or 备付金
        if ( $self->{acct}->{$hf->{acct}}->{sub_type} == ACCT_TYPE_BFJ ) {  # 手续费划付账号为备付金账号

            # 备付金划付银行账号 == 手续费划付账号 
            # 为备付金内扣
            if ( $proto->{bjhf}->{acct} == $hf->{acct} ) {
                $rec[RES_BFEE_NK_ACCT] = $hf->{acct};
                $rec[RES_BFEE_NK_O]  = $bfee;
                $rec[RES_BFEE_NK_OUT] = $self->_inout_date($hf, $req->{date}, $req->{tx_date});
            }
            # 备付金外扣
            else {
                $rec[RES_BFEE_WK_ACCT] = $hf->{acct};
                $rec[RES_BFEE_WK_O]    = $bfee;
                $rec[RES_BFEE_WK_OUT]  = $self->_inout_date($hf, $req->{date}, $req->{tx_date});
            }
        }  
        else { # 自有资金 
            warn "ERROR: 暂不支持自有资金划付银行手续费";
            return;
        }
    }
    else {
        warn "ERROR: invalid 划付方式";
        return;
    }

    return \@rec;
}


1;

__END__

##########################################################################
#  银行协议接口
#  1> 获取银行接口编号
#     
#     输入:  1. 外部部门编号
#            2. 外部部门银行接口编号 
#
#     输出:  1. 内部银行接口编号
#
#  2> 获取手续费12项输出数组 +  本金信息(5相) + 接口编号
#
#     输入:  
#            1. 外部部门编号
#            2. 外部部门银行接口编号
#            3. 清算日期
#            4. 交易金额
#
#     输出:  
#            # 银行接口
#            1: 银行接口编号           bi
#
#            # 本金部分5相
#            2: [
#                1. 本金备付金银行账号       -- bj_acct
#                2. 本金-入                  -- bj_i 
#                3. 本金-出                  -- bj_o 
#                4. 本金入账日期             -- bj_in 
#                5. 本金出账日期             -- bj_out
#            ],
#
#            # 手续费12相输出数组(最多5个条目)
#            3: [
#                [], 
#                [], 
#                [], 
#                [], 
#                [ 
#                    手续费部分-内扣(5项)
#                    1.  备付金内扣银行账号      -- bfee_nk_acct
#                    2.  备付金内扣银行手续费-入 -- bfee_nk_i
#                    3.  备付金内扣银行手续费-出 -- bfee_nk_o
#                    4.  备付金内扣银行入账日期  -- bfee_nk_in
#                    5.  备付金内扣银行出账日期  -- bfee_nk_out
#
#                    手续费部分-外口(5项)
#                    6.  备付金内扣银行账号      -- bfee_wk_acct
#                    7.  备付金内扣银行手续费-入 -- bfee_wk_i
#                    8.  备付金内扣银行手续费-出 -- bfee_wk_o
#                    9.  备付金内扣银行入账日期  -- bfee_wk_in
#                    10. 备付金内扣银行出账日期  -- bfee_wk_out
#
#                    手续费部分-财务外付(2项)
#                    11. 财务外付银行手续费-入   -- bfee_cwwf_i
#                    12. 财务外付银行手续费-出   -- bfee_cwwf_o
#                ]
#            ],
#

