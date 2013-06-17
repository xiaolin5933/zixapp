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
    my $g_e     = $self->_load_frule_entry();     # gid              => { id(条目) => xxx }
    my $ed_sect = $self->_load_frule_d_sect();    # 直接确认条目ID   => \@直接确认条目-计算区间
    my $ep_sect = $self->_load_frule_p_sect();    # 周期确认条目ID   => \@周期确认条目-计算区间
    for my $bip_id ( keys %$group) {
        my $grps = delete $group->{$bip_id};
        for my $grp (@$grps) {
            my $g_id  = $grp->{id};
            my $g_dir = $grp->{dir};
            my $g_entries = $g_e->{$g_id};        # 规则组

            $group->{$bip_id}{group}{$g_id}{dir} = $g_dir;
            for my $entry (@$g_entries) {
                # 直接确认
                if ($entry->{ack} == 1) {
                    $entry->{sect} = $ed_sect->{delete $entry->{id}};
                    push @{$group->{$bip_id}{group}{$g_id}{rules}}, $entry;
                }
                # 周期确认
                elsif ($entry->{ack} == 2) {
                    $entry->{sect} = $ep_sect->{delete $entry->{id}};
                    push @{$group->{$bip_id}{group}{$g_id}{rules}}, $entry;
                }
            }
        }
    }
    Data::Dump->dump($group) if DEBUG;

    # 银行接口协议
    my $bip = $self->_load_bip();
    warn "bip:\n" . Data::Dump->dump($bip)     if DEBUG;

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

    #
    # 目标:
    # {
    #       $fp1 => {
    #            ack_period => [
    #               { 
    #                   begin   => xxx, 
    #                   end     => xxx, 
    #                   ceiling => xxx,
    #                   floor   => xxx,
    #               },  # 日期区间1
    #               { begin => xxx, end => xxx, },  # 日期区间2
    #            ],
    #
    #            ack_type => 0,   # 1 包周期(月，年); 2 阶梯; 3 分段
    #            ack_sect => [
    #               { 
    #                   begin => xxx, 
    #                   end   => xxx,... 
    #                   ratio => xxx,
    #               } # 确认区间1
    #               { 
    #                   begin => xxx, 
    #                   end   => xxx,... 
    #                   ratio => xxx,
    #               } # 确认区间2
    #            ],
    #            # 划付信息
    #            hf => {},
    #            round => xxx, 取整规则
    #       },
    #       $fp2 => {},   # 周期确认ID
    # }
    my $packs = $self->_load_frule_pack();
     

    # 账号
    # 账号ID => { sub_type => xxx, sub_id => xxx }    
    my $acct = $self->_load_acct();            
    warn "acct:\n" . Data::Dump->dump($acct) if DEBUG;

    # 最终config
    $self->{config} = {
        acct => $acct,
        dept => $dept_bi,
        bip  => $bip,
        pack => $packs,
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
        pack     => $config->{pack},                                # 确认规则;
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
# 返回值:
#
# {
#       $fp1 => {
#            ack_period => [
#               { 
#                   begin   => xxx, 
#                   end     => xxx, 
#                   ceiling => xxx,
#                   floor   => xxx,
#               },  # 日期区间1
#               { begin => xxx, end => xxx, },  # 日期区间2
#            ],
#
#            ack_type => 0,   # 1 包周期(月，年); 2 阶梯; 3 分段
#            ack_sect => [
#               { 
#                   begin => xxx, 
#                   end   => xxx,... 
#                   ratio => xxx,
#               } # 确认区间1
#               { 
#                   begin => xxx, 
#                   end   => xxx,... 
#                   ratio => xxx,
#               } # 确认区间2
#            ],
#            # 划付信息
#            hf => {},
#       },
#       $fp2 => {},   # 周期确认ID
#       round => xx,  # 取整规则
# }
#
sub _load_frule_pack {
    my $self = shift;
    my $dbh  = $self->{cfg}{dbh};
    my $all;            # 所有的确认规则以及其
    
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select id,
       ack_type,
       type,
       acct,
       period,
       delay,
       nwd,
       round
from frule_pack

EOF
    };
    if ($@) {
        confess "can not select from frule_pack[$@]";
    }

    my $sects   = $self->_load_frule_pack_sect();
    my $periods = $self->_load_frule_pack_period();

    my %data;
    for my $row ( @$all ) {
        my $fp = {
            ack_period  => $periods->{$row->{id}},
            ack_type    => $row->{ack_type},
            ack_sect    => $sects->{$row->{id}},
            hf          => {
                type    => $row->{type},
                acct    => $row->{acct},
                period  => $row->{period},
                delay   => $row->{delay},
                nwd     => $row->{nwd},
            },
            round       => $row->{round},
        };
        $data{$row->{id}} = $fp;
    }

    return \%data;
}

#
# 返回值: 
#
# {
#    $fp1 => [  # 指定确认规则的计算区间
#        {
#            begin  => xxx,
#            end    => xxx,
#            ratio  => xxx,
#        },
#        {},
#        ...
#    ]
#    $fp2 => []
#    ...
# }
#
sub _load_frule_pack_sect {
    my $dbh = shift->{cfg}{dbh};
    my $all;            #

    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select fp_id, 
       begin, 
       end, 
       ratio
from frule_pack_sect order by fp_id, begin

EOF
    };
    if ($@) {
        confess "can not select from frule_pack_sect[$@]";
    }



    my %data;
    for ( @$all ) {
        push @{$data{delete $_->{fp_id}}}, $_;
    }

    return \%data;
}

#
# 返回值: 
#
# {
#    $fp1 => [
#        {
#            begin      => xxx,
#            end        => xxx,
#            ceiling    => xxx,
#            floor      => xxx,
#        },
#        {},
#        ...
#    ],
#    $fp2 => [],
#    ...
# }
sub _load_frule_pack_period {
    my $dbh = shift->{cfg}{dbh};
    my $all;            # 所有的确认规则以及其

    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select fp_id, 
       begin, 
       end, 
       ceiling, 
       floor
from frule_pack_period order by fp_id, begin

EOF
    };
    if ($@) {
        confess "can not select from frule_pack_period[$@]";
    }



    my %data;
    for ( @$all ) {
        push @{ $data{delete $_->{fp_id}} }, $_;
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
# 规则条目
# {
#     $gid_1 => [
#         { id  => $xxx, dir => $dir, ack => $ack, hf => {} },
#         { id  => $xxx, dir => $dir, ack => $ack, hf => {} },
#         { id  => $xxx, dir => $dir, ack => $ack, hf => {} },
#         { id  => $xxx, ack => $ack, dir => $dir, fp_id => $fp_id },
#         { id  => $xxx, ack => $ack, dir => $dir, fp_id => $fp_id },
#     ],
#     $gid_2 => [
#     ],
# }
#
sub _load_frule_entry {
    my $self = shift;

    my $eds  = $self->_load_frule_entry_d(); 
    my $eps  = $self->_load_frule_entry_p();

    for my $gid (keys %$eds)   {
        push @{$eps->{$gid}}, @{$eds->{$gid}};
    }

    return $eps; 
}

#
# 直接确认规则条目
# {
#     $gid_1 => [
#         { id  => $xxx, dir => $dir, ack => $ack, hf => {} },
#         { id  => $xxx, dir => $dir, ack => $ack, hf => {} },
#         { id  => $xxx, dir => $dir, ack => $ack, hf => {} },
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
    ack,
    dir,
    type,
    acct,
    period,
    delay,
    nwd
from 
    frule_entry, frule_entry_d 
where 
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
        my $ack = delete $_->{ack};
        push @{$g_ed{$gid}}, { id => $id, dir => $dir, ack => $ack, hf => $_ };
    }
    return \%g_ed;
}

#
# 直接确认规则条目
# {
#     $gid_1 => [
#         { id  => $xxx, ack => $ack, dir => $dir, ack_id => $fp_id },
#         { id  => $xxx, ack => $ack, dir => $dir, ack_id => $fp_id },
#         { id  => $xxx, ack => $ack, dir => $dir, ack_id => $fp_id },
#     ],
#     $gid_2 => [
#     ],
# }
#
sub _load_frule_entry_p {
    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select 
    frule_entry.id,
    gid,
    ack,
    dir,
    fp_id
from 
    frule_entry, frule_entry_p 
where 
    frule_entry.id = frule_entry_p.id
EOF
    };
    if ($@) {
        confess "can not select from frule_entry[$@]";
    }
    my %g_ed;
    for (@$all) {
        my $id    = delete $_->{id};
        my $gid   = delete $_->{gid};
        my $dir   = delete $_->{dir};
        my $ack   = delete $_->{ack};
        my $fp_id = delete $_->{fp_id};
        push @{$g_ed{$gid}}, { id => $id, ack => $ack, dir => $dir, ack_id => $fp_id };
    }
    return \%g_ed;
}

#
#  entry_d的ID
# {
#    $e_id => {
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
    e_id,
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
    e_id,
    begin asc
EOF
   };
    if ($@) {
        confess "can not select from frule_d_sect[$@]";
    }

    my %d_sect;
    for (@$all) {
        push @{$d_sect{delete $_->{e_id}}}, $_;
    }

    return \%d_sect;
}

#
#  entry_p的ID
# {
#    $ep_id => {
#        begin => xxx
#        end   => xxx
#        ...  
#    }         
# }
#
sub _load_frule_p_sect {
    my $dbh = shift->{cfg}{dbh};
    my $all;
    eval {
        $all = $dbh->selectall_arrayref(<<EOF, { Slice => {} });
select
    id,
    e_id,
    begin,
    end,
    mode,
    ratio,
    ceiling,
    floor,
    quota 
from 
    frule_p_sect
order by
    e_id,
    begin asc
EOF
    };
    if ($@) {
        confess "can not select from frule_p_sect[$@]";
    }

    my %d_sect;
    for (@$all) {
        push @{$d_sect{delete $_->{e_id}}}, $_;
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
#                 }
#                 { ... },   # 协议N
#             ],
#             $bi_N => [ ... ],
#         },
#
#         # 周期确认 - 确认规则
#         pack => {
#             1 => {
#                 ack_period => [
#                     { 
#                         begin   => xxx, 
#                         end     => xxx, 
#                         ceiling => xxx,
#                         floor   => xxx,
#                     },  # 日期区间1
#                     { begin => xxx, end => xxx, },  # 日期区间2
#                 ],
#
#                 ack_type => 1,   # 1 包周期(月，年); 2 阶梯; 3 分段
#                 ack_sect => [
#                     { 
#                         begin => xxx, 
#                         end   => xxx,... 
#                         ratio => xxx,
#                     } # 确认区间1
#                     { 
#                         begin => xxx, 
#                         end   => xxx,... 
#                         ratio => xxx,
#                     } # 确认区间2
#                 ],
#                 # 划付信息
#                 hf => {},
#                 # 取整规则
#                 round => xxx,
#             },
#             2 => {},   # 周期确认ID
#         },
#
#         # dept_bi
#         dept => {
#             $dept_id => {
#                 $dept_bi" => {
#                     bi      => $bi,   # 银行接口
#                     matcher   => {
#                         $matcher1 => {        # 规则组
#                             $bip => {
#                                   dir   => $dir,     # 入 / 出 
#                                   rules => [         # 规则数组
#                                       规则1-直接确认
#                                       { 
#                                           ack  => 1
#                                           dir  => $dir # 入 / 出
#                                           hf   => { ... },  # 划付信息
#                                           sect => [         # 计算区间
#                                               { begin => xxx, end => xxx, ... }, # 区间1
#                                               { begin => xxx, end => xxx, ... }, # 区间2
#                                           ]
#                                       },
#                                       规则N-周期确认
#                                       { 
#                                           ack  => 2,
#                                           dir  => $dir,
#                                           sect => [  # 暂估阶段用
#                                               { begin => xxx, end => xxx, ... }, # 区间1
#                                               { begin => xxx, end => xxx, ... }, # 区间2
#                                           ],
#                                           ack_id => 1,  # 确认规则ID
#                                       },
#                                   ],
#                             },
#                         },
#                     },
#                 },
#             },
#         },
#
#
#     }
# }
#



