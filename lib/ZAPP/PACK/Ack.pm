package ZAPP::PACK::Ack;
use strict;
use warnings;
use Carp;
use DateTime;
use JSON::XS;
use File::Path qw/mkpath/;
use ZAPP::PACK::Constant;
use ZAPP::YSPZ::Constant;
use ZAPP::BIP::Config;
use ZAPP::BIP::Inst;
use ZAPP::BIP::Constant;


use constant {
    DEBUG           => $ENV{ZAPP_PACK_ACK_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}


#######################################################################
# 参数:
#   $cfg    : zapp主配置
#   $setup  : 是否设置数据库
# 对象结构:
#   {
#       cfg    => $cfg,  # 配置
#   }
#######################################################################
sub new {
    my ($class, $cfg, $setup) = @_;
    my $self = bless { }, $class;
    $self->{cfg} = $cfg;
    if ($setup) {
        $self->setup(); 
    }

    return $self;
}

#
# 子进程重置
#
sub setup {
    my $self = shift; 
    # 通过id查询周期确认工作 
    $self->{sel_m} = $self->{cfg}{dbh}->prepare(<<EOF);
select * from pack_mission where id = ?
EOF

    # 通过扫描日期查询周期确认工作
    $self->{sel_m1} = $self->{cfg}{dbh}->prepare(<<EOF);
select * from pack_mission where sm_date = ?
EOF

    # 更新周期确认工作
    $self->{upd_m} = $self->{cfg}{dbh}->prepare(<<EOF);
update pack_mission set status = ? where id = ?
EOF

    # 更新周期确认状态 与 packs
    $self->{upd_m1} = $self->{cfg}{dbh}->prepare(<<EOF);
update pack_mission set status = ?, packs = ? where id = ?
EOF
    
    # 插入周期确认工作
    $self->{ins_m} = $self->{cfg}{dbh}->prepare(<<EOF);
insert into pack_mission values(?, ?, ?, ?, ?, default, default)
EOF

    $self->{seq_m} = $self->{cfg}{dbh}->prepare(<<EOF);
values nextval for seq_pack_mission
EOF

    # 指定确认规则id, 按交易日期分类汇总， 获取 暂估周期确认银行手续费
    $self->{sum_zg} = $self->{cfg}{dbh}->prepare(<<EOF);
select tx_date,sum(j) as j, sum(d) as d from sum_bfee_zqqr_zg where fp = ? group by tx_date
EOF

    # 折扣比例>0时，(指定确认规则id按各核算项分类汇总暂估手续费, 进行分摊，并且(逐笔折扣后的汇总 - 实际算出来的手续费)进ark0)
    $self->{pack_yspz} = $self->{cfg}{dbh}->prepare(<<EOF);
with pack_yspz(bi, c, fp, p, period, tx_date, zg_bfee, bfee) as 
(
    select  bi,
            c,
            fp,
            p,
            period,
            tx_date,
            d - j                           as zg_bfee,
            round((d - j) * ? / 1000000, 0) as bfee
    from sum_bfee_zqqr_zg
    where fp = ? and tx_date >= ? and tx_date <= ?
)
select * from pack_yspz 
union
select null as bi, null as c, fp, null as p, null as period, null as tx_date, 0 as zg_bfee, ? - sum(bfee) as bfee 
from pack_yspz group by fp
EOF

    # 折扣比例<=0时，实际算出来的手续费直接进入ark0
    $self->{pack_yspz1} = $self->{cfg}{dbh}->prepare(<<EOF);
with pack_yspz(bi, c, fp, p, period, tx_date, zg_bfee, bfee) as 
(
    select  bi,
            c,
            fp,
            p,
            period,
            tx_date,
            d - j                           as zg_bfee,
            0                               as bfee
    from sum_bfee_zqqr_zg
    where fp = ? and tx_date >= ? and tx_date <= ?
)
select * from pack_yspz 
union
select null as bi, null as c, fp, null as p, null as period, null as tx_date, 0 as zg_bfee, ? - 0 as bfee 
from pack_yspz group by fp
EOF

    return $self;
}


#
# des
#    周期确认生成pack_mission
#
# $args = {
#    sm_date => $sm_date,  
# }
#
#
sub pack_mission {
    my ($self, $args) = @_;
    # 接收到前台发送的扫描日期(扫描日期[个人认为是确认日期更好]不能>=当前日期) 
    my $dt = DateTime->now('time_zone' => 'local');
    my $date = $dt->ymd('-');
    if ($args->{sm_date} ge $date) {
        warn "sm_date >= now date" if DEBUG;
        return;
    }
    # 根据扫描日期 获取周期确认规则控制信息
    $self->{sel_m1}->execute($args->{sm_date});
    my $mission = $self->{sel_m1}->fetchrow_hashref();
    $self->{sel_m1}->finish();
    # 如果没有获取到pack_mission, 插入pack_mission
    my $id;
    unless($mission) {
        # 调用计费系统(packs接口)(在确认规则表中查找所有确认周期的终止日期正好等于扫描日期的确认规则集合)
        my $config  = $self->{cfg}{bip};
        my $inst    = $config->inst(); 
        my $packs = $inst->packs(
                        {
                            sm_date => $args->{sm_date},
                        }
                    );
        # 生成mission
        # 如果确认规则集合是空的 -1 无; 如果确认规则集合不为空 1 可生成
        eval {
            $id = $self->_mission_id();
            # 如果数组不为空, 1 可生成
            if (@$packs) {
                my $packstr = join ',', @$packs;
                $self->{ins_m}->execute($id, $args->{sm_date}, PMISSION_STARTABLE, $packstr, undef);
            } 
            # 如果确认规则集合是空的 -1 无
            else {
                $self->{ins_m}->execute($id, $args->{sm_date}, PMISSION_NONE, undef, undef);
            }
            $self->{cfg}{dbh}->commit();
        };
        if ($@) {
            warn "insert pack mission error[$@]" if DEBUG;
            $self->{cfg}{dbh}->rollback();
            return;
        }
    } 
    # 如果获取到pack_mission, 更新pack_mission
    else {
        # 如果获取到记录且状态为2生成中 或 3生成成功 或 -1无，那么停止整个过程;
        if ($mission->{status} == PMISSION_RUNNING_EXPORT || # 生成中
            $mission->{status} == PMISSION_SUCCESS_EXPORT || # 生成成功
            $mission->{status} == PMISSION_NONE              # 无
            ) {
            return;
        }
        else {
            # 调用计费系统(packs接口)(在确认规则表中查找所有确认周期的终止日期正好等于扫描日期的确认规则集合)
            my $config  = $self->{cfg}{bip};
            my $inst    = $config->inst();
            my $packs = $inst->packs(
                            {
                                sm_date => $args->{sm_date},
                            }
                        );
            # 生成mission    
            # 如果确认规则集合是空的 -1 无; 如果确认规则集合不为空 1 可生成
            eval {
                $id = $mission->{id};
                # 如果确认规则集合不为空 1 可生成
                if (@$packs) {
                    my $packstr = join ',', @$packs;
                    $self->{upd_m1}->execute(PMISSION_STARTABLE, $packstr, $id);
                }
                # 如果确认规则集合是空的 -1 无
                else {
                    $self->{upd_m1}->execute(PMISSION_NONE, undef, $id);
                }
                $self->{cfg}{dbh}->commit();
            };
            if ($@) {
                warn "update pack mission error[$@]" if DEBUG;    
                return;
            }
        }
    }
    return $id;
}

#
# args = {
#   sm_date      => $sm_date,        # 扫描日期(不能 >= 当前日期)
#   pmission_id  => $pmission_id,    # pack mission id
# }
sub ack {
    my ($self, $args) = @_;

    unless ($args->{sm_date} =~ /(\d{4})-(\d{2})-(\d{2})/) {
        warn "date[$args->{sm_date}] format is error" if DEBUG; 
        return;
    }

    my $sm_date = $1 . $2. $3;

    # 扫描日期不能 >= 当前日期
    my $dt = DateTime->now('time_zone' => 'local');
    my $date = $dt->ymd('-');
    if ($args->{sm_date} ge $date) {
        warn "sm_date >= now date" if DEBUG;
        return;
    }

    $self->{sel_m}->execute($args->{pmission_id});
    my $pack_mission = $self->{sel_m}->fetchrow_hashref();
    $self->{sel_m}->finish();

    # 如果控制表为 1可生成
    if ($pack_mission->{status} == PMISSION_STARTABLE) {
        #### 将控制表修改为(2 生成中)
        $self->{upd_m}->execute(PMISSION_RUNNING_EXPORT, $pack_mission->{id}); 
        $self->{cfg}{dbh}->commit();
    }
    # 如果控制表状态为其他
    else {
        # 停止整个流程
        warn "pack_mission status is not PMISSION_STARTABLE" if DEBUG;
        return;
    }

    # 如果没有packs，那么停止处理流程
    unless ($pack_mission->{packs}) {
        warn "packstr no data" if DEBUG;
        return;
    }
    my @packs = split ',', $pack_mission->{packs};
    my $load_cfg = $self->{cfg}{batch}->load_cfg(PACK_YSPZ);
    my $dir_pack = "$load_cfg->{rdir}/$sm_date";
    mkpath($dir_pack);
    my $fd_pack = IO::File->new("> " . "$dir_pack/" . $self->{cfg}{batch}->fname(PACK_YSPZ, $sm_date, 1));
    eval {
        for my $pack_id (@packs) {
            # 暂估周期确认银行手续费 科目指定确认规则按交易日期分类汇总
            my %zg_bfee;
            $self->{sum_zg}->execute($pack_id);
            while (my $row = $self->{sum_zg}->fetchrow_hashref())  {
                $zg_bfee{$row->{tx_date}} = $row->{d} - $row->{j};
            }
            # 调用计费系统返回 实际总额，打折比例，确认周期
            my $config  = $self->{cfg}{bip};
            my $inst    = $config->inst();
            my $res = $inst->verify(
                {
                    ack_id  => $pack_id,
                    zg_bfee => \%zg_bfee,
                    sm_date => $args->{sm_date},
                }
            );
            # 导出一个sql语句查询出来的内容(指定确认规则id按各核算项分类汇总暂估手续费, 进行分摊，并且算出ark0)
            my $ags = {
                sm_date => $args->{sm_date},
                ack_id  => $pack_id, 
            };
            unless($self->_export_file($ags, $res, $fd_pack)) {
                #### 将控制表状态改为(-2 生成失败), 继续执行以下流程
                $self->{upd_m}->execute(PMISSION_FAIL_EXPORT, $pack_mission->{id});
                $self->{cfg}{dbh}->commit();
                return;
            }
        }
        # 文件生成完后，创建ok文件，并且上传
        my $ok;
        open $ok, ">$dir_pack/ok." . $self->{cfg}{batch}->fname(PACK_YSPZ, $sm_date)
            or die "Cannot touch ok file";
        $ok->close();
        #### 将控制表状态改为(2 导出文件成功), 继续执行以下流程
        $self->{upd_m}->execute(PMISSION_SUCCESS_EXPORT, $pack_mission->{id});
        # 生成load_mission, 且commit
        unless( 
            $self->{cfg}{batch}->prep_mission(
                {
                    date => $args->{sm_date},
                    type => PACK_YSPZ
                }
            )
        ) {
            die "can not prep_mission 0031 load mission";
        }

    };
    if ($@) {
        warn "export pack mission file error[$@]" if DEBUG;
        $self->{cfg}{dbh}->rollback();
        return;
    }
    $fd_pack->flush();
    $fd_pack->close();
    

    return $self; 
}


#################
# 私有函数
#################

#
# des:
#   导出确认凭证(0031)流水文件
#
# para:
#   $args = {
#       sm_date     => $sm_date,        # 扫描日期
#       ack_id      => $ack_id,         # 确认规则ID
#   }
#   res     =   [
#       $bi,
#       [
#        
#       ],
#       [     # 直接确认手续费
#           [  ...    ],  # 规则1处理结果 
#           [  ...    ],  # 规则2处理结果 
#       ],
#       [     # 周期确认手续费
#           [  ...    ],  # 规则1处理结果
#           [  ...    ],  # 规则2处理结果 
#       ],
#   ]
#
# res:
#   ret = 是否导出文件成功
#
sub _export_file {
    my ($self, $args, $res, $fd_pack) = @_;

    unless($res) {
        warn "inst verify can not get result" if DEBUG;
        return;
    }
    # 打折比例
    my $ratio = $res->[RES_PBFEE][RES_PBFEE_RATIO];
    unless (defined $ratio) {
        # 打折比例没有定义
        warn "frule pack ratio is undefined" if DEBUG;
        return;
    }
    # 实际汇总手续费
    my $bfee;
    # 实际总银行手续费划付类型，0 备付金付， 1 财务外付
    my $bfee_type;
    # 备付金手续费
    if (defined $res->[RES_PBFEE][RES_PBFEE_BFJ_FEE]) {
        $bfee = $res->[RES_PBFEE][RES_PBFEE_BFJ_FEE];
        $bfee_type = 0;
    }
    # 自有资金手续费
    elsif (defined $res->[RES_PBFEE][RES_PBFEE_ZYZJ_FEE]) {
        $bfee = $res->[RES_PBFEE][RES_PBFEE_ZYZJ_FEE];
    }
    # 财务外付手续费
    elsif (defined $res->[RES_PBFEE][RES_PBFEE_CWWF_FEE]) {
        $bfee = $res->[RES_PBFEE][RES_PBFEE_CWWF_FEE];
        $bfee_type = 1;
    }
    unless (defined $bfee) {
        # 实际汇总手续费没有定义
        warn "real bfee is undefined" if DEBUG;
        return;
    }
    # 确认规则下的指定周期
    my $period = $res->[RES_PBFEE][RES_PBFEE_PERIOD];
    unless (defined $period) {
        warn "period is undefined" if DEBUG;
        return;
    }
    # 周期的开始日期
    my $begin = $period->[0];
    unless ($begin) {
        warn "period's begin undefined" if DEBUG;
        return;
    }
    # 周期的结束日期
    my $end   = $period->[1];
    unless ($end) {
        warn "period's end undefined" if DEBUG;
        return;
    }
    my $sth_pack;
    # 单笔暂估折扣出来的值是进行四舍五入
    # 折扣比例 > 0 就分摊成本
    if ($ratio > 0) {
        $self->{pack_yspz}->execute($ratio, $args->{ack_id}, $begin, $end, $bfee);
        $sth_pack = $self->{pack_yspz};
    }
    # 折扣比例 <= 0 就把实际算出总额放入ark0
    elsif ($ratio <= 0) {
        $self->{pack_yspz1}->execute($args->{ack_id}, $begin, $end, $bfee);
        $sth_pack = $self->{pack_yspz1};
    }
    # 生成文件
    my $count   = 0;
    my $dt      = DateTime->now('time_zone' => 'local');
    my $now     = $dt->ymd('') . $dt->hms('');
    while ( my $row = $sth_pack->fetchrow_hashref() ) {
        if (my $str = $self->_pack_yspz($row, $bfee_type, $res, $now)) {
            $fd_pack->print($str . "\n");
            ++$count;
        }
        # 达到500条，从内存刷新到文件中
        if ($count >= 500) {
            $fd_pack->flush();
            $count = 0;
        }
    }
    $fd_pack->flush();
    

    return 1;
}

#
# 根据确认折扣算出来的一条记录生成 周期确认流水文件(0031)
#
sub _pack_yspz {
    my ($self, $row, $bfee_type, $res, $now) = @_;
    
    my $str;
    # 备付金付
    if ($bfee_type == 0) {
        $str = sprintf(
            "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",
            defined($row->{bi})      ? $row->{bi}      : '0',
            defined($row->{c})       ? $row->{c}       : '-1',
            $row->{fp},
            defined($row->{p})       ? $row->{p}       : '0',
            defined($row->{period})  ? $row->{period}  : $res->[RES_PBFEE][RES_PBFEE_PERIOD][1],
            defined($row->{tx_date}) ? $row->{tx_date} : $res->[RES_PBFEE][RES_PBFEE_PERIOD][1],
            $res->[RES_PBFEE][RES_PBFEE_SM_DATE],
            $now,
            defined($row->{zg_bfee}) ? $row->{zg_bfee} : '0',
            $res->[RES_PBFEE][RES_PBFEE_BFJ_ACCT],
            $res->[RES_PBFEE][RES_PBFEE_BFJ_DATE],
            defined($row->{bfee})    ? $row->{bfee}    : '0',
            '0'
        );
    }
    # 财务外付
    elsif ($bfee_type == 1) {
        # bi|c|fp|p|period|tx_date|sm_date|now|zg_bfee|bfj_acct|zjbd_date|bfj_bfee|cwwf_bfee
        $str = sprintf(
            "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",
            defined($row->{bi})      ? $row->{bi}      : '0',    # bi
            defined($row->{c})       ? $row->{c}       : '-1',   # c
            $row->{fp},                                          # fp
            defined($row->{p})       ? $row->{p}       : '0',    # p
            defined($row->{period})  ? $row->{period}  : $res->[RES_PBFEE][RES_PBFEE_PERIOD][1],    # period
            defined($row->{tx_date}) ? $row->{tx_date} : $res->[RES_PBFEE][RES_PBFEE_PERIOD][1],    # tx_date
            $res->[RES_PBFEE][RES_PBFEE_SM_DATE],                # sm_date
            $now,                                                # now
            defined($row->{zg_bfee}) ? $row->{zg_bfee} : '0',    # zg_bfee
            '',                                                  # bfj_acct
            '',                                                  # zjbd_date
            '0'                                            ,     # bfj_bfee
            defined($row->{bfee})    ? $row->{bfee}    : '0'     # cwwf_bfee
        );
    }

    return $str;
}

#
# 获取工作ID
#
sub _mission_id {
    my $self = shift;
    $self->{seq_m}->execute();
    my ($id) = $self->{seq_m}->fetchrow_array();
    return $id;
}


1;

__END__

#
# 使用到其他对象 
#   batch
#   bip(no setup)
#   pack
#   dt(no setup)
#

# 对象结构
#

