package ZAPP::BIP::Config;
use strict;
use warnings;
# use ZAPP::BIP::BI;
use constant {
    DEBUG => $ENV{ZAPP_ALGO_CONFIG_DEBUG} || 0,
};

#
# 这是重量级对象
#
#
#  参数:
#  dbh => $dbh
#
#  对象结构:
#  {
#     dbh  =>  $dbh
#  }
#
sub new {
    my $self = bless {}, shift;
    $self->_init({@_});
    return $self;
}

#
# 参数:
#       $bi  -  银行接口id
# 功能:
#       通过银行接口ID找到所有银行接口协议
# 返回值:  
#       ZAPP::BIP::BI
# example:
#       $self->bip($bi);
#
sub bip { 
    my ($self, $bi) = @_;
    my $bip  = $self->{bip}->{$bi};
#    return ZAPP::BIP::BI->new( 
#        dbh   => $self->{dbh},
#        proto => $bip,
#    );
}

#
# 外部部门id, 外部部门的银行接口ID,
# 获取内部银行接口ID
# $self->{$dept_id, $dept_bi);
#
sub dept_bi { shift->{dept_bi}->{+shift . '.' . +shift} }

#
# 构建$config对象
# { 
#    $bi_id_1 => [
#       # 协议1
#       {
#           id          => '协议ID',
#           begin       => ’协议开始日期'
#           end         => '协议结束日期'
#           bjhf => {
#               acct   => '本金划付账号ID',
#               period => '本金划付周期',
#               delay  => '本金划付延迟',
#               nwd    => '非工作日是否划付',
#           },
#
#           round       => '取整规则',
#           
#           # 规则组
#           frule => [
#               # 规则组1
#               {
#                   algo => [
#                       # 区间1
#                       {
#                           begin   =>  '区间开始'
#                           end     =>  '区间结束'
#                           mode    =>  '按比列|定额',     
#                           ratio   =>  '比列值',
#                           ceiling =>  '封顶',
#                           floor   =>  '保底',
#                           quota   =>  '定额',
#                       }
#                       # 区间2
#                       {
#                       }
#                   ],
#                   hf  => {
#                       type =>
#                       acct =>
#                       period =>
#                       delay  =>
#                       nwd    => 
#                   }
#               },
#               # 规则组2
#               {
#               },
#               ... #最多五个规则组
#           ],
#       },
#
#       # 协议2
#       {
#       }
#    ],
#    $bi_id_2  => [],
#    $bi_id_3  => [],
# }
#
sub _init {
    my ($self, $args)  = @_;

    $self->{dbh} = $args->{dbh};
    my $bip   = $self->_load_bip();
    my $proc  = $self->_load_proc();
    my $algo  = $self->_load_algo();
    my $hf    = $self->_load_hf();
    my $dept_bi = $self->_load_dept_bi();

    my %data;
    for my $bi_id (keys %$bip) {
        my $proto = $bip->{$bi_id};
        for my $p (@$proto) {
            my $fp_id = $proc->{$p->{id}};
            for (@$fp_id) {
                push @{$p->{frule}}, {
                    algo => $algo->{$_},
                    hf   => $hf->{$_},
                },
            }
        }
        $data{$bi_id} = $proto;
    }

    $self->{bip}     = \%data;
    $self->{dept_bi} = $dept_bi;

    return $self;
}



###################################################
# {
#    $bi_1 => [
#        { },    # 协议1
#        { },    # 协议2
#    ]，
#
#    $bi_2 => [
#        { },    # 协议1
#        { },    # 协议2
#    ]
# }
###################################################
sub _load_bip {
    my ($self) = @_;
    my $all = $self->{dbh}->selectall_arrayref(<<EOF, {Slice => {}});
select
    id,
    bi_id,

    begin,
    end,

    bjhf_acct,
    bjhf_period,
    bjhf_delay,
    bjhf_nwd,

    round
from
    bi_proto
order by 
    bi_id, 
    begin asc
EOF

    warn "bi_proto info" and Data::Dump->dump($all) if DEBUG;

    my %proto;
    for (@$all) {
        $_->{bjhf} = {
            acct   => delete $_->{bjhf_acct},
            period => delete $_->{bjhf_period},
            delay  => delete $_->{bjhf_delay},
            nwd    => delete $_->{bjhf_nwd},
        };
        push @{$proto{delete $_->{bi_id}}}, $_;
    }
    return \%proto;

}

#
#  {
#     $fp_id => [
#     ],
#  }
#
sub _load_algo {
    my ($self, $fp_id) = @_;
    my $all = $self->{dbh}->selectall_arrayref(<<EOF, {Slice => {}});
select 
    fp_id,
    sect_id,
    begin,
    end ,
    mode,
    ratio,
    ceiling,
    floor,
    quota
from
    frule_algo_sect
order by 
    fp_id, 
    begin asc
EOF
    warn "frule_algo_sect info:" and  Data::Dump->dump($all) if DEBUG;
    my %algo;
    for my $row (@$all) {
       push @{$algo{delete $row->{fp_id}}}, $row;
    }
    return \%algo;
}

#
#  返回值:
#  {
#     $fp_id  => {
#     },
#
#     $fp_id  => {
#     },
#  }
#
sub _load_hf {
    my ($self) = @_;
    my $all = $self->{dbh}->selectall_arrayref(<<EOF, {Slice => {}});
select
    fp_id,
    type,
    acct,
    period,
    delay,
    nwd
from
    frule_hf
EOF

    warn "frule_hf info:" and  Data::Dump->dump($all) if DEBUG;
    return {  map { delete $_->{fp_id} => $_ } @$all };
}

#
# 返回值:
# {
#    $bip_id  =>  [ fp_id_1,  fp_id_2 ],
# }
#
sub _load_proc {

    my ($self) = @_;
    my $all = $self->{dbh}->selectall_arrayref(<<EOF, {Slice => {}});
select
    id,
    bip_id
from
    frule_proc
EOF
    warn "frule_proc info:" and  Data::Dump->dump($all) if DEBUG;

    my %proc;
    for my $row (@$all) {
        push @{$proc{delete $row->{bip_id}}}, $row->{id};
    }
    return \%proc;
}

#
# 返回:
# {
#    '部门1_id.接口id'  =>  $bi,
#    '部门2_id.接口id'  =>  $bi,
#    '部门3_id.接口id'  =>  $bi,
# }
#
sub _load_dept_bi {
    my ($self) = @_;
    my $all = $self->{dbh}->selectall_arrayref(<<EOF, {Slice => {}});
select
    dept_id,
    dept_bi,
    bi
from
    dict_dept_bi
EOF
    warn "dict_dept_bi info:" and  Data::Dump->dump($all) if DEBUG;

    my %dept_bi;
    for my $row (@$all) {
        $dept_bi{$row->{dept_id} . '.' . $row->{dept_bi}} = $row->{bi};
    }
    return \%dept_bi;
}


1;

__END__


