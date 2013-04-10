package ZAPP::BIP::Inst;
use strict;
use warnings;
use constant {

    # 测试
    DEBUG  =>  $ENV{ZAPP_BIP_INST_DEBUG} || 0,

    # 账户类别
    ACCT_TYPE_BFJ   => 1,   # 备付金账号
    ACCT_TYPE_ZYZJ  => 2,   # 自有资金账号

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

BEGIN {
   require Data::Dump if DEBUG;
}

##########################################################################
# 参数:
# (
#     dbh     => $dbh,
#     dt      => $dt,
#
#     acct    => $acct,
#
#     proto   => $proto,
#     bi      => $bi,
#     matcher => $matcher,
# )
#
# 对象结构
# {
#    dbh   => $dbh,
#    dt    =>
#
#    acct    => $acct,
#
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
#      date   => '银行清算日期',
#      amt    => '金额',
#      matcher  => 'mcc',
#  }
#
#  res =   [
#     {  ...    },  # 规则1处理结果 
#     {  ...    },  # 规则2处理结果 
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
    my @output;

    # 对于组中的没一个规则
    for my $rule (@$group) {
        my $bfee = $self->_bfee($req, $proto, $rule);
        warn "不能计算手续费" and return unless defined $bfee;

        my $res = $self->_result($req, $proto, $rule, $bfee);
        warn "不能设置result" and return  unless defined $res;
        push @output, $res;
    } 

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
sub _inout_date {

    my ($self, $hf, $date) = @_;

    my $dt;

    # 日
    if ($hf->{period} == FH_PERIOD_DAY) {
        $dt = $date;
    }
    # 周
    elsif ($hf->{period} == FH_PERIOD_WEEK) {
        $dt = $self->{dt}->week_last($dt)   # $dt所在周的最后一天
    }
    # 月
    elsif ($hf->{period} == FH_PERIOD_MONTH) {
        $dt = $self->{dt}->month_last($dt)  # $dt所在月的最后一天
    }
    elsif ($hf->{period} == FH_PERIOD_QUARTER) {
        $dt = $self->{dt}->quarter_last($dt)  # $dt所在季度的最后一天
    }
    # 半年
    elsif ($hf->{period} == FH_PERIOD_SEMI_YEAR) {
        $dt = $self->{dt}->semi_year_last($dt)  # $dt所在半年的最后一天
    }
    # 年
    elsif ($hf->{period} == FH_PERIOD_YEAR) {
        $dt = $self->{dt}->year_last($dt)  # $dt所在年的最后一天
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
#
#
sub _result {
    my ($self, $req, $proto, $rule, $bfee) = @_;

    # 本金相关
    my $res = {
        bj_acct  => $proto->{bjhf}->{acct},
        bj_in    => $self->_inout_date($proto->{bjhf}, $req->{date}),
        bi       => $self->{bi},
    }; 

    # 银行手续费划付信息
    my $hf = $rule->{hf};
    if ( $hf->{type} == FH_TYPE_F) {     # 财务付款
         $res->{bfee_cwwf} = $bfee;
    }
    elsif ($hf->{type} == FH_TYPE_NF) {  # 非财务付款
        # 判断手续费划付账户类型: 自有资金 or 备付金
        if ( $self->{acct}->{$hf->{acct}}->{sub_type} == ACCT_TYPE_BFJ  ) {  # 手续费划付账号为备付金账号

            # 备付金划付银行账号 == 手续费划付账号 
            # 为备付金内扣
            if ( $proto->{bjhf}->{acct} == $hf->{acct} ) {
                $res->{bfee_nk}      = $bfee;
                $res->{bfee_nk_acct} = $hf->{acct};
                $res->{bfee_nk_out}  = $self->_inout_date($hf, $req->{date});
            }
            # 备付金外扣
            else {
                $res->{bfee_wk}      = $bfee;
                $res->{bfee_wk_acct} = $hf->{acct};
                $res->{bfee_wk_out}  = $self->_inout_date($hf, $req->{date});
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

    return $res;
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
#  2> 获取10项输出:
#            本金部分:
#            1. 本金备付金银行账号     bj_acct
#            2. 本金入账日期           bj_in 
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
##########################################################################

