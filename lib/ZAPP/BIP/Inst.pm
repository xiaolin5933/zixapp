package ZAPP::BIP::Inst;
use strict;
use warnings;
use Carp;
use DateTime;
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
#
#  des: 
#    直接确认手续费 或 周期确认 - 逐笔暂估手续费 接口
#
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
#     [     # 直接确认手续费
#       [  ...    ],  # 规则1处理结果 
#       [  ...    ],  # 规则2处理结果 
#     ],
#     [     # 周期确认手续费
#       [  ...    ],  # 规则1处理结果
#       [  ...    ],  # 规则2处理结果 
#     ],
#  ]
#############################################
sub calc {

    my ($self, $req) = @_;
    unless (defined $req) {
        $req = {};
    }
    $req->{matcher} ||= '-1';

    # 返回值
    my @res; 

    #### 第一部分: 输出接口
    $res[RES_BI] = $self->{bi};

    # 如果没有找到协议或者是协议组，那么直接返回银行接口
    # 查找协议
    return \@res unless my $proto = $self->_find_proto($req);
    warn "INFO>: 找到协议:\n" . Data::Dump->dump($proto) if DEBUG;

    # 查找规则组
    return \@res unless my $group = $self->_find_group($req, $proto);   
    warn "INFO>: 找到规则组:\n" . Data::Dump->dump($group)  if DEBUG;


    #### 第二部分: 输出本金信息(5项)
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

    #### 第三部分: 输出手续费信息数组
    for my $rule (@{$group->{rules}}) {
        my $bfee = $self->_bfee($req, $proto, $rule);
        warn "不能计算手续费" and return unless defined $bfee;

        # 直接确认规则
        if ($rule->{ack} == ACK_DIRECT) {
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
        # 周期确认规则逐笔
        elsif ($rule->{ack} == ACK_PERIOD) {
            my @bfee_rec;
            $bfee_rec[RES_PBFEE_FP_ID] = $rule->{ack_id};
            if ($rule->{dir} == BFEE_DIR_IN) {
                $bfee_rec[RES_PBFEE_ZG_I] = $bfee;
            }
            elsif ($rule->{dir} == BFEE_DIR_OUT)  {
                $bfee_rec[RES_PBFEE_ZG_O] = $bfee;
            }
            else {
                warn "internal error";
                return;
            }
            push @{$res[RES_PBFEE]}, \@bfee_rec;
        }
    } 

    return \@res;
}


#
#  des: 
#    周期确认 - 确认阶段
#
#  req = {
#      ack_id    => '确认规则编号',
#      zg_bfee   => {
#           交易日期1  => 暂估手续费1,
#           交易日期2  => 暂估手续费2,
#           交易日期3  => 暂估手续费3,
#           ...
#      },
#      sm_date   => '扫描日期(不能 >= 当前日期)',
#  }
#
#  res =   [
#     $bi,
#     [
#        
#     ],
#     [     # 直接确认手续费
#       [  ...    ],  # 规则1处理结果 
#       [  ...    ],  # 规则2处理结果 
#     ],
#     [     # 周期确认手续费
#       [  ...    ],  # 规则1处理结果
#       [  ...    ],  # 规则2处理结果 
#     ],
#  ]
sub verify {
    my ($self, $req) = @_; 

    # 扫描日期不能 >= 当前日期
    my $dt = DateTime->now('time_zone' => 'local');
    my $date = $dt->ymd('-');
    if ($req->{sm_date} ge $date) {
        warn "sm_date >= now date" if DEBUG;
        return;
    }    

    # 找周期确认规则
    my $fp = $self->_find_frule_pack($req);
    unless ($fp) {
        warn "can not find a frule_pack" if DEBUG;
        return;
    }
    # 通过扫描日期找到最近已达到确认日期的周期区间
    my $period = $self->_find_frule_pack_period($req, $fp);
    unless ($period) {
        warn "can not find a frule_pack_period" if DEBUG;
        return;
    }
    # 暂估手续费汇总
    my $zg_bfee = $self->_zg_bfee($req, $period);
    # 确认手续费汇总
    my $bfee    = $self->_ack_bfee($fp, $period, $zg_bfee); 
    
    unless (defined $bfee) {
        warn "can not calc ack bfee" if DEBUG;
        return;
    }

    # 返回值
    my @res;

    # 第一部分: 输出接口
    $res[RES_BI] = $self->{bi};

    # 第二部分: 输出确认手续费
    my $bfee_rec;
    # 查找指定确认规则的最后一个周期，那么可以根据最后一个周期的结束日期推出划付日期
    my $period_final = $self->_find_final_period($fp);
    unless (defined $period_final) {
        warn "can not get last period for ack_id [$req->{ack_id}]" if DEBUG;
        return;
    }
    # 根据总额大小
    $bfee_rec = $self->_ack_bfee_ret($req, $fp, $period_final, $bfee);           # 手续费划付信息

    unless (defined $bfee_rec) {
        warn "can not get res ack bfee" if DEBUG;
        return;
    }

    if ($zg_bfee != 0 ) {
        $bfee_rec->[RES_PBFEE_RATIO]   = $bfee / $zg_bfee * 1000000;       # 总的打折比例
    }
    $bfee_rec->[RES_PBFEE_FP_ID]   = $req->{ack_id};                       # 确认规则id
    $bfee_rec->[RES_PBFEE_PERIOD]  = [$period->{begin}, $period->{end}];   # 确认规则下指定周期
    $bfee_rec->[RES_PBFEE_SM_DATE] = $req->{sm_date};                      # 确认规则下指定周期

    $res[RES_PBFEE] = $bfee_rec;

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

#########
# 周期确认
#########

#
# 查找周期确认规则的确认周期
# req提供了sm_date, 通过其查找最近的到达确认日期的周期
#
sub _find_frule_pack_period {
    my ($self, $req, $fp) = @_;

    my $period; 
    my $index = -1;
    my $sm_date = $req->{sm_date};
    for my $ap (@{$fp->{ack_period}}) {
        ++$index;
        # 如果扫描日期是周期最后一天， 那么就是此周期
        if ($sm_date eq $ap->{end}) {
            $period = $ap;
            last;
        }
        # 如果扫描日期大于周期最后一天，那么看下一个周期
        elsif ($sm_date gt $ap->{end}) {
            next;
        }
        # 如果扫描日期小于周期最后一天，说明落于当前周期间
        elsif ($sm_date lt $ap->{end}) {
            # 那么如果当前至少是第2个周期内，那么用前一周期作为已查到周期
            if ($index > 0) {
                $period = $fp->{ack_period}[$index - 1];
                last;
            }
            # 否则是落于第一区间内，那么表示没有一个周期已经到期
            else {
                $index = -1;
                last;
            }
        }
    }
    unless ($period) {
        # 如果没有找到period, 并且$index为-1，表示确实找不到一个已经到期的周期
        if ($index == -1) {
            return;
        }
        # 否则是最后一个周期
        $period = $fp->{ack_period}[$index];
    }

    return $period;
}

#
# 查找确认规则-根据周期确认规则id
# req提供了ack_id, 就返回后面的确认规则
#
sub _find_frule_pack {
    my ($self, $req) = @_;
    return $self->{pack}{$req->{ack_id}};
}


#
# 查找指定的确认规则的最后一个周期
# 
#
sub _find_final_period {
    my ($self, $fp) = @_;

    my $period;
    for ( @{$fp->{ack_period}} ) {
        $period = $_;
    }

    return $period;
}

#
# 计算满足于指定周期的暂估手续费汇总
#
sub _zg_bfee {
    my ($self, $req, $period) = @_;
    # 满足指定周期的暂估手续费
    my $bfee = 0;
    for my $tx_date (keys %{$req->{zg_bfee}}) {
        $bfee += $req->{zg_bfee}{$tx_date} if $tx_date ge $period->{begin} && $tx_date le $period->{end};
    }
    return $bfee;
}

#
# 计算周期确认总手续费
#
sub _ack_bfee {
    my ($self, $fp, $period, $zg_bfee) = @_;
    # 总的确认手续费
    my $bfee = 0;
    # 判断确认类型
    # 包周期(月，年)
    if ($fp->{ack_type} == ACK_TYPE_PACK) {
        # 包周期，在确认周期中封顶保底必须一样(定额)，那么手续费是封顶或保底都可
        if ($period->{ceiling} != $period->{floor}) {
            warn "ERROR: ack_type[pack] ceiling must be same with floor in the period" if DEBUG;
            return;
        }
        $bfee = $period->{floor};
    } else {

        # 2 阶梯
        if ($fp->{ack_type} == ACK_TYPE_LADDER) {
         
            my $sect;
            for (@{$fp->{ack_sect}}) {
                $sect = $_ and last  if $zg_bfee >= $_->{begin} && $zg_bfee < $_->{end};
            }
            unless($sect) {
                warn "ERROR: can not find algo sect for zg_bfee[$zg_bfee]";
                return
            }
            warn "暂估手续费金额[$zg_bfee] 找到阶梯[$sect->{begin}, $sect->{end})" if DEBUG;
            # 通过找到的阶梯比例算实际手续费(百万分之)
            $bfee = $zg_bfee * $sect->{ratio} / 1000000;
        }
        # 3 分段
        elsif ($fp->{ack_type} == ACK_TYPE_SECTION) {
            for my $sect (@{$fp->{ack_sect}}) {
                # 如果暂估手续费 大于等于 分段区间的结尾, 总暂估手续费落于下个分段, 那么先计算此分段区间的实际手续费
                if ($zg_bfee >= $sect->{end}) {
                    $bfee += ($sect->{end} - $sect->{begin}) * $sect->{ratio} / 1000000;
                    next;
                }
                # 如果落于当前区间，那么当前分段手续费 = (暂估手续费 - 区间开始) * 比例
                elsif ($zg_bfee >= $sect->{begin} && $zg_bfee < $sect->{end}) {
                    $bfee += ($zg_bfee - $sect->{begin}) * $sect->{ratio} / 1000000;
                    next;
                }
                # 区间已经超过暂估手续费，那么结束
                else {
                    last;
                }
            }
        }


        
        # 执行取整规则
        if ( $fp->{round} == ROUND_NORM) {
            $bfee = int($bfee + 0.5);
        }
        elsif( $fp->{round} == ROUND_UP) {
            if ($bfee =~ /\./) {
                $bfee = int($bfee + 1);
            }
        }
        elsif( $fp->{round} == ROUND_DOWN ) {
            $bfee =~ s/\..*$//;
        }
        else {
            warn "ERROR: internal error, invalid frule_pack field[round]";
            return;
        }

        # 封顶保底判断
        $bfee = $bfee > $period->{ceiling} ? $period->{ceiling} : $bfee  if defined $period->{ceiling};
        $bfee = $bfee < $period->{floor}   ? $period->{floor}   : $bfee  if defined $period->{floor};
    }

    return $bfee;
}


#
# 周期确认手续费-记录
#
sub _ack_bfee_ret {
    my ($self, $req, $fp, $period, $bfee) = @_;

    # 手续费相关
    my @rec;

    # 银行手续费划付信息
    my $hf = $fp->{hf};
    if ( $hf->{type} == HF_TYPE_F) {     # 财务付款
        $rec[RES_PBFEE_CWWF_FEE] = $bfee;
    }
    elsif ($hf->{type} == HF_TYPE_NF) {  # 非财务付款
        # 判断手续费划付账户类型: 自有资金 or 备付金
        if ( $self->{acct}->{$hf->{acct}}->{sub_type} == ACCT_TYPE_BFJ ) {  # 手续费划付账号为备付金账号

            $rec[RES_PBFEE_BFJ_ACCT]   = $hf->{acct};
            $rec[RES_PBFEE_BFJ_FEE]    = $bfee;
            $rec[RES_PBFEE_BFJ_DATE]   = $self->_inout_date($hf, $period->{end}, undef);
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

######### 
# 直接确认
#########
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
    unless (defined $req->{date}) {
        warn "req->{date} is undefined" if DEBUG;
        return;
    }
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
            warn "ERROR: 没有合适协议, 清算日期[$req->{date}]" if DEBUG;
            return;
        }        
 
        # 找到协议, 放入cache  LRU清理cache
        delete $self->{cache}->{shift @{$self->{lru}}} if @{$self->{lru}} > CACHE_SIZE;
        push @{$self->{lru}}, $req->{date};
        $self->{cache}->{$req->{date}} = $proto; 
    }
}


#
# 计算逐笔分区间银行手续费
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

            $rec[RES_BFEE_BFJ_ACCT] = $hf->{acct};
            $rec[RES_BFEE_BFJ_I]    = $bfee;
            $rec[RES_BFEE_BFJ_IN]   = $self->_inout_date($hf, $req->{date}, $req->{tx_date});
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

            $rec[RES_BFEE_BFJ_ACCT] = $hf->{acct};
            $rec[RES_BFEE_BFJ_O]    = $bfee;
            $rec[RES_BFEE_BFJ_OUT]  = $self->_inout_date($hf, $req->{date}, $req->{tx_date});
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

