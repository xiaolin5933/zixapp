package ZAPP::BIP::Config;
use strict;
use warnings;
use Carp;
use ZAPP::BIP::Inst;
use ZAPP::DT;
use constant {
    DEBUG => $ENV{ZAPP_BIP_CONFIG_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
# 参数: $cfg
#
sub new {
    my ($class, $cfg) = @_;
    my $self = bless { cfg => $cfg }, $class;
    $self->_init();
}

#
# 构建config对象
#
sub _init {
    my $self = shift;

    # group,  g_ed, ed_sect汇总调整
    my $group   = $self->_load_frule_group();     # 协议ID           => \@规则组: [ { id => xxx, dir => xxx } ]
    my $g_ed    = $self->_load_frule_entry_d();   # gid              => { id(条目) => xxx, hf => {} }
    my $ed_sect = $self->_load_frule_d_sect();    # 直接确认条目ID   => \@直接确认条目-计算区间
    for my $bip_id ( keys %$group) {
        my $grps = delete $group->{$bip_id};
        for my $grp (@$grps) {
            my $g_id  = $grp->{id};
            my $g_dir = $grp->{dir};
            my $g_entries = $g_ed->{$g_id};        # 规则组

            $group->{$bip_id}{group}{$g_id}{dir} = $g_dir;
            for my $entry (@$g_entries) {
                $entry->{sect} = $ed_sect->{delete $entry->{id}};
                push @{$group->{$bip_id}{group}{$g_id}{rules}}, $entry;
            }
        }
    }
    Data::Dump->dump($group) if DEBUG;

    # 银行接口协议调整
    my $bip = $self->_load_bip();
    warn "bip:\n" . Data::Dump->dump($bip)     if DEBUG;
    for my $bi_id ( keys %$bip ) {
        for ( @{$bip->{$bi_id}} ) {
            $_->{group} = $group->{$_->{id}}->{group};
            Data::Dump->dump($_) if DEBUG;
        }
    }
    Data::Dump->dump($bip) if DEBUG;

    # 组dept_bi部分:  dept_bi + dfg
    my $dept_bi = $self->_load_dept_bi(); 
    my $dfg     = $self->_load_dept_fgrp();
    warn "dept_bi:\n" .  Data::Dump->dump($dept_bi) if DEBUG;
    warn "dfg:\n" . Data::Dump->dump($dfg) if DEBUG;
    #
    # 目标:
    # {
    #     $dept_id => {
    #         $dept_bi => {
    #             bi      => $bi,   # 银行接口
    #             matcher => {
    #                 $matcher1 => {
    #                 $bip => $gid,
    #             },
    #         },
    #     },
    # }
    #
    # 来源:  $dept_bi
    #        $dfg 
    #
    for my $db_id (keys %$dfg) {
        for my $matcher (keys %{$dfg->{$db_id}}) {
            for my $bip_id (keys %{$dfg->{$db_id}->{$matcher}}) {
                my $gid = $dfg->{$db_id}->{$matcher}->{$bip_id};
                $dfg->{$db_id}->{$matcher}->{$bip_id} = $group->{$bip_id}{group}{$gid};
            }
        }
    }
    for my $dept_id (keys %$dept_bi) {
        for my $dept_bi_id (keys %{$dept_bi->{$dept_id}}) {
            my $db_id = delete $dept_bi->{$dept_id}{$dept_bi_id}{id};
            $dept_bi->{$dept_id}{$dept_bi_id}{matcher} = $dfg->{$db_id};
        }
    }
    Data::Dump->dump($dept_bi) if DEBUG;

    # 账号
    # 账号ID => { sub_type => xxx, sub_id => xxx }    
    my $acct = $self->_load_acct();            
    warn "acct:\n" . Data::Dump->dump($acct) if DEBUG;

    # 最终config
    $self->{config} = {
        acct => $acct,
        dept => $dept_bi,
        bip  => $bip,
    };

    return $self;
}

#
# my $inst = $self->( $部门id, $部门接口);
#
sub inst {
    my ($self, $dept_id, $dept_bi) = @_;

    my $config = $self->{config};

    my $bi = $config->{dept}{$dept_id}{$dept_bi}->{bi};      # 银行接口编号; 
    return ZAPP::BIP::Inst->new(
        cfg      => $self->{cfg},
        bi       => $bi,
        proto    => $config->{bip}{$bi},                            # 银行接口协议;
        acct     => $config->{acct},                                # 账号;
        matcher  => $config->{dept}{$dept_id}{$dept_bi}->{matcher}, # 协议匹配;
    );
}


#
# 加载dept_bi
# {
#     $dept_id => {
#        $dept_bi  => {
#            id => $id
#            bi => $bi 
#        }
#     }
# }
#
sub _load_dept_bi {
    my $dbh = shift->{cfg}{dbh};
    my $all;

    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select id, dept_id, dept_bi, bi from dept_bi
EOF
    };
    if ($@) {
        confess "can not select from dept_bi[$@]";
    }

    my %data;
    for ( @$all ) {
        my $dept_id = delete $_->{dept_id};
        my $dept_bi = delete $_->{dept_bi};
        $data{$dept_id}{$dept_bi} = {
            id => $_->{id},
            bi => $_->{bi},
        };
    }

    return \%data;

}

#
#
#  返回值:
#  {
#     银行接口编号  => [
#         {
#            id    => '协议ID',
#            begin =>  $beg,
#            end   =>  $end,
#            round =>  ...
#            bjhf  => { ...本金划付信息 },
#         }
#     ]
#  }
#
#
sub _load_bip {
    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select 
    id, 
    bi,
    begin, 
    end, 
    bjhf_acct, 
    bjhf_period, 
    bjhf_delay, 
    bjhf_nwd, 
    round 
from 
    bip
where 
    disable = '0'
order by 
    bi,
    begin asc
EOF
    };
    if ( $@ ) {
        confess "canot select from bip[$@]";
    }
    my %bip;
    for (@$all) {
        my ($bi, $acct, $period, $delay, $nwd) = delete @{$_}{qw/bi bjhf_acct bjhf_period bjhf_delay bjhf_nwd/};
        my %bjhf = (
            acct   => $acct,
            period => $period,
            delay  => $delay,
            nwd    => $nwd,
        );
        $_->{bjhf} = \%bjhf;
        push @{$bip{$bi}}, $_;
    }
    return \%bip;
}

#
#  规则组
#  {
#     协议1ID  => [ 规则组1-ID,  规则组2-ID],
#     协议2ID  => [ 规则组1-ID,  规则组2-ID],
#     协议3ID  => [ 规则组1-ID,  规则组2-ID],
#  }
#
sub _load_frule_group {

    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF,  { Slice => {}}); 
select id, bip, dir from frule_group
EOF
    };
    if ($@) {
        confess "can not select from frule_group[$@]";
    }
    my %bip_grp;
    for (@$all) {
        push @{$bip_grp{delete$_->{bip}}}, $_;
    }
    return \%bip_grp;
}

#
# 直接确认规则条目
# {
#     $gid_1 => [
#         { id  => $xxx, hf => {} },
#         { id  => $xxx, hf => {} },
#         { id  => $xxx, hf => {} },
#     ],
#     $gid_2 => [
#     ],
# }
#
sub _load_frule_entry_d {
    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select 
    frule_entry.id,
    gid,
    dir,
    type,
    acct,
    period,
    delay,
    nwd
from 
    frule_entry 
left join 
    frule_entry_d 
on 
    frule_entry.id = frule_entry_d.id
EOF
    };
    if ($@) {
        confess "can not select from frule_entry[$@]";
    }
    my %g_ed;
    for (@$all) {
        my $id  = delete $_->{id}; 
        my $gid = delete $_->{gid}; 
        my $dir = delete $_->{dir};
        push @{$g_ed{$gid}}, { id => $id, dir => $dir, hf => $_ };
    }
    return \%g_ed;
}

#
#  entry_d的ID
# {
#    $ed_id => {
#        begin => xxx
#        end   => xxx
#        ...  
#    }         
# }
#
sub _load_frule_d_sect {
    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select
    id,
    ed_id,
    begin,
    end,
    mode,
    ratio,
    ceiling,
    floor,
    quota 
from 
    frule_d_sect
order by
    ed_id,
    begin asc
EOF
   };
   if ($@) {
       confess "can not select from frule_d_sect[$@]";
   }

    my %d_sect;
    for (@$all) {
        push @{$d_sect{delete $_->{ed_id}}}, $_;
    }

    return \%d_sect;
}

#
# {
#     $db_id1 => {
#         $matcher => {
#             $bip1  => $gid2,
#             $bip2  => $gid2,
#         }
#     }
#     $db_id2 => {}
# }
#
sub _load_dept_fgrp {

    my $dbh = shift->{cfg}{dbh};

    # dept_fgrp
    my $fgrp;
    eval {
        $fgrp = $dbh->selectall_arrayref(<<EOF, { Slice => {} } );
select 
    db_id,
    matcher,
    bip,
    gid
from 
    dept_fgrp, dept_matcher
where 
    dept_fgrp.dbm_id = dept_matcher.id
EOF
    };
    if ($@) {
        confess "can not select dept_fgrp[$@]";
    }

    my %dfg;
    for (@$fgrp) {
       my $db_id   = delete $_->{db_id};
       my $bip     = delete $_->{bip};
       my $gid     = delete $_->{gid};
       my $matcher = delete $_->{matcher};
       for (split ',', $matcher) {
           $dfg{$db_id}{$_}{$bip} = $gid;
       }
    }
    return \%dfg;
}


#
# 账号信息加载:  
#     dim_bfj_acct, 
#     dim_zyzj_acct, 
#     dim_acct
# {
#    $acct_id  => {
#        sub_type  =>  
#        sub_id    =>
#    },
#    $acct_id_2 => {},
#    $acct_id_3 => {},
#    $acct_id_4 => {},
# }
#
sub _load_acct {
    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, {Slice => {}});
select
    id,
    sub_type,
    sub_id
from
    dim_acct
EOF
    };
    if ($@) {
        confess "can not select dim_acct[$@]";
    }
    return { map { delete $_->{id} => $_ } @$all };
}


1;


__END__
# 对象结构:
# {
#     dbh    => $dbh,
#     dt     => $dt,
#     config => {
#         # 账号字典
#         acct => {
#             $id => { sub_type => 1, sub_id   => 1 }
#         },
#         
#         # 银行接口协议 
#         bip => {
#             $bi  => [
#                 { 
#                     begin =>
#                     end   => 
#                     bjhf  =>
#                     round =>
#
#                     # 规则组
#                     group => {
#                         gid-1 => {
#                              dir   => $dir,     # 入 / 出 
#                              rules => [         # 规则数组
#                                 规则1
#                                 { 
#                                     dir  => $dir # 入 / 出
#                                     hf   => { ... },  # 划付信息
#                                     sect => [         # 计算区间
#                                         { begin => xxx, end => xxx, ... }, # 区间1
#                                         { begin => xxx, end => xxx, ... }, # 区间2
#                                     ]
#                                 },
#                                 规则N
#                                 { ... },  
#                             ],
#                         },
#                         gid-2 => {},
#                     },
#                 }
#                 { ... },   # 协议N
#             ],
#             $bi_N => [ ... ],
#         },
#
#         # dept_bi
#         dept_bi => {
#             $dept_id => {
#                 $dept_bi" => {
#                     bi      => $bi,   # 银行接口
#                     matcher   => {
#                         $matcher1 => {
#                             $bip => {},  # 规则组
#                         },
#                     },
#                 },
#             }
#         }
#     }
# }
#



