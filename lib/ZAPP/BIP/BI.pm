package ZAPP::BIP::BI;
use strict;
use warnings;
use constant {

    # 测试
    DEBUG  =>  $ENV{ZAPP_ALGO_BI_DEBUG} || 0,

    # 手续费计算模式
    MODE_RATIO  =>  1, # 按比列
    MODE_QUOTA  =>  2, # 单笔定额

    # 取整规则
    ROUND_NORM  =>  1, # 四舍五入
    ROUND_UP    =>  2, # 向上取整 
    ROUND_DOWN  =>  3, # 向下取整

    # 划付类型
    FH_TYPE_F   =>  1, # 财务支付
    FH_TYPE_NF  =>  2, # 非财务

    # 划付周期
    FH_PERIOD_DAY       => 1,
    FH_PERIOD_WEEK      => 2,
    FH_PERIOD_MONTH     => 3,
    FH_PERIOD_QUARTER   => 4,
    FH_PERIOD_SEMI_YEAR => 5,
    FH_PERIOD_YEAR      => 6,
 
    # 缓存大小 
    CACHE_SIZE  =>  3, # cache大小
};


#
#  银行协议接口
#  1> 获取银行接口编号
#     
#     输入:  1. 外部部门编号
#            2. 外部部门银行接口编号 
#
#  2> 获取10项输出:
#            本金部分:
#            1. 本金备付金银行账号     bfj_acct_bj
#            2. 本金入账日期           bj_date_in 
#
#            手续费部分-内扣
#            3. 备付金内扣银行手续费    bfee_nk
#            4. 备付金内扣银行账号      bfee_nk_acct
#            5. 备付金内扣银行出账日期  bfee_nk_out
# 
#            手续费部分-外口
#            6. 备付金外扣银行手续费    bfee_wk
#            7. 备付金外扣银行账号      bfee_wk_acct
#            8. 备付金外扣银行出账日期  bfee_wk_out
#          
#            手续费部分-财务外付
#            9. 财务外付银行手续费      bfee_cwwf
#
#            # 银行接口
#            10. 银行接口编号           bi
#  
#     输入:  1. 外部部门编号
#            2. 外部部门银行接口编号
#            3. 清算日期
#            4. 交易金额
#
##########################################################################
# 参数:
# (
#     dbh   => $dbh,
#     bi    => $bi,
#     proto => $proto,
#     dt    => $dt,
# )
#
# 对象结构
# {
#    dbh   => $dbh,
#    bi    => 
#    dt    =>
#    proto => [
#        # 第一份协议
#        {
#           begin       => '2012-13-14',
#           end         => '1013-12-11',
#          
#           # 本金划付规则
#           bjhf => {
#               acct   => '$bfj_acct_id',
#               period => $period,
#               delay  => $delay,
#               nwd    => $flag,
#           },
#
#           # 取整规则
#           round       => '1|2',
#
#           # 手续费规则组
#           frule       => [
#               # rule 1
#               {
#                   # ack =>  'direct|period',
#                   #   
#                   
#                   #
#                   # 手续费计算区间
#                   algo => [
#                       # sect 1
#                       {
#                          # 模式, 区间, 比列，封顶， 保底， 定额
#                          mode    => 'ratio/quota',
#                          begin   => 
#                          end     =>
#                          ratio   =>
#                          ceiling =>
#                          floor   =>
#                          quota   =>
#                       },
#                       # sect 2
#                       {
#                       }
#                    ],
#                    # 银行手续费 划付方式
#                    hf   => {
#                         type   => '划付方式: 财务支付|非财务支付',
#                         acct   => '$bfj_acct_id',
#                         period => $period,
#                         delay  => $delay,
#                         nwd    => $flag,
#                    },
#               },
#
#               # rule 2
#               {}
#           ],
#        },
#
#        # 第二份协议
#        {
#        },
#    ],
#    lru => [ '2013-04-24', '2013-0425' ],
#    cache  => {
#        '2013-04-24' => $proto[$i],
#        '2013-04-25' => $proto[$i],
#    },
# }
#
sub new {
    my $class = shift;
    my $self = bless { @_ }, $class;
}

#############################################
#  req = {
#      bi   => '银行接口编号',
#      date => '银行清算日期',
#      amt  => '金额',
#      mcc  => 'mcc',
#  }
#
#  返回值:
#  [
#     # 规则1处理结果
#     {
#     },
#     # 规则2处理结果
#     {
#     },
#  ]
#############################################
sub calc {

    my ($self, $req) = @_;

    # 查找协议
    my $proto = $self->{cache}->{$req->{date}};
    unless($proto) {
        # cache中协议不存在, LRU清理cache
        delete $self->{cache}->{shift @{$self->{lru}}} if @{$self->{lru}} > CACHE_SIZE;

        # 查找协议
        $proto = $self->_find_proto($req->{date});
        unless($proto) {
            warn "ERROR: 没有合适协议处理接口[$req->{bi}], 清算日期[$req->{date}]";
            return;
        }        
 
        # 找到协议, 放入cache
        push @{$self->{lru}}, $req->{date};
        $self->{cache}->{$req->{date}} = $proto; 
    }

    # 返回值
    my @output;

    # 查找规则组
    # frule是个数组，数组每个元素为一个规则, 每个规则包含algo, hf    
    # 每个algo包含多个sect
    my $frule = $self->_find_frule($req);   

    # 对于一个规则
    for my $rule (@$frule) {

        # 组织本规则处理结果:
        my $res = {
             bfj_acct_bj  => $proto->{bjhf_acct},
             bj_in        => $self->inout_date($proto->{bjhf_date}),
             bi           => $self->{bi},
        }; 

        # 目前只有阶梯, 找出金额所在阶梯
        my $sect;
        for (@{$rule->{algo}}) {
            $sect = $_ and last  if $req->{amt} >= $_->{begin} && $req->{amt} < $_->{end};
        }
        unless($sect) {
            warn "ERROR: can not find algo sect for amt[$req->{amt}]";
            return
        }

        # 计算银行手续费
        my $bfee;
        if ($sect->{mode} == MODE_QUOTA) {
           $bfee =  $sect->{quota};
        }
        elsif ($sect->{mode} == MODE_RATIO) {
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
            $bfee = $bfee > $sect->{ceiling} ? $sect->{ceiling} : $bfee  if defined $sect->{ceiling};
            $bfee = $bfee < $sect->{floor}   ? $sect->{floor}   : $bfee  if defined $sect->{floor};
        }
        else {
            warn "ERROR: internal error, invalid sect field[mode]";
        }

        # 银行手续费划付信息
        my $hf = $rule->{hf};
        if ( $hf->{type} == FH_TYPE_F) {     # 财务付款
             $res->{bfee_cwwf} = $bfee;
        }
        elsif ($hf->{type} == FH_TYPE_NF) {  # 非财务付款
            # 判断手续费划付账户类型: 自有资金 or 备付金
            if ( $hf->{acct}  ) {  # 手续费划付账号为备付金账号

                # 备付金划付银行账号 == 手续费划付账号 
                # 为备付金内扣
                if ( $proto->{bjhf_acct} == $hf->{acct} ) {
                    $res->{bfee_nk}      = $bfee;
                    $res->{bfee_nk_acct} = $hf->{acct};
                    $res->{bfee_nk_out}  = $self->inout_date();
                }
                # 备付金外扣
                else {
                    $res->{bfee_wk}      = $bfee;
                    $res->{bfee_wk_acct} = $hf->{acct};
                    $res->{bfee_wk_out}  = $self->inout_date();
                }
            }  
            else { # 自有资金 
                # 暂不支持 
            }
        }
        else {
            warn "ERROR: invalid 划付方式";
            return;
        }

        push @output, $res;
        
    }  # rule

    return \@output;
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
# 输出:
####################################################
sub inout_date {
    my ($self, $hf, $date) = @_;

    my $dt;

    # 日
    if ($hf->{period} == FH_PERIOD_DAY) {
        $dt = $date;
    }
    # 周
    elsif ($hf->{period} == FH_PERIOD_WEEK) {
        $dt = $self->{dt}->week_last($dt)   # $stlmnt_dt所在周的最后一天
    }
    # 月
    elsif ($hf->{period} == FH_PERIOD_MONTH) {
        $dt = $self->{dt}->month_last($dt)  # $stlmnt_dt所在月的最后一天
    }
    elsif ($hf->{period} == FH_PERIOD_QUARTER) {
        $dt = $self->{dt}->quarter_last($dt)  # $stlmnt_dt所在月的最后一天
    }
    # 半年
    elsif ($hf->{period} == FH_PERIOD_SEMI_YEAR) {
        $dt = $self->{dt}->semi_year_last($dt)  # $stlmnt_dt所在月的最后一天
    }
    # 年
    elsif ($hf->{period} == FH_PERIOD_YEAR) {
        $dt = $self->{dt}->year_last($dt)  # $stlmnt_dt所在月的最后一天
    }
    else {
        warn "ERROR: internal error";
        return;
    }

    #  加上划付延迟
    $dt = $self->{dt}->next_n_day($dt, $hf->{delay});

    #  不是工作日
    unless( $self->{dt}->is_wday($dt) ) {  # 
        # 非工作日是否划付
        unless ( $hf->{nwd} )  {    # 非工作日 不划付, 取下一工作日
            $dt = $self->{dt}->next_n_wday($dt, 1);  
        }
    }

    return $dt; 
}

#
# 查找规则组-根据mcc
#
sub _find_frule {
    my ($self, $proto, $req) = @_;
    return $proto->{frule}->[0];  # 目前就用一个规则组
}

#
# 查找协议-根据银行清算日期
#
sub _find_proto {
    my ($self, $req) = @_;
    for (@{$self->{proto}}) {
        if ($req->{date} cmp $_->{begin} && $_->{end} cmp $req->{date} ) {
            return $_;
        }
    }
    return;
}

1;

__END__

