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

    # 通过确认id、扫描日期查询周期确认工作
    $self->{sel_m1} = $self->{cfg}{dbh}->prepare(<<EOF);
select * from pack_mission where ack_id = ? and sm_date = ?
EOF

    # 更新周期确认工作
    $self->{upd_m} = $self->{cfg}{dbh}->prepare(<<EOF);
update pack_mission set status = ? where id = ?
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
select null as bi, null as c, fp, null as p, null as period, null as tx_date, 0 as zg_bfee, sum(bfee) - ? as bfee 
from pack_yspz group by fp
EOF

    # 折扣比例<=0时，实际算出来的手续费直接进入ark0
    $self->{pack_yspz1} = $self->{cfg}{dbh}->prepare(<<EOF);
select null as bi, null as c, fp, null as p, null as period, null as tx_date, sum(zg_bfee) as zg_bfee, ? - 0 as bfee 
from (
    select  bi,
            c,
            fp,
            p,
            period,
            tx_date,
            d - j                           as zg_bfee
    from sum_bfee_zqqr_zg
    where fp = ? and tx_date >= ? and tx_date <= ?
) as t1
group by fp
EOF

    return $self;
}

#
# $args = {
#   sm_date     => $sm_date,        # 扫描日期(不能 >= 当前日期)
#   ack_id      => $ack_id,         # 确认规则ID
# }
sub ack {
    my ($self, $args) = @_;

    # 扫描日期不能 >= 当前日期
    my $dt = DateTime->now('time_zone' => 'local');
    my $date = $dt->ymd('-');
    if ($args->{sm_date} ge $date) {
        warn "sm_date >= now date" if DEBUG;
        return;
    }
   
    # 根据确认规则id, 扫描日期 获取周期确认规则控制信息
    $self->{sel_m1}->execute($args->{ack_id}, $args->{sm_date});
    my $mission = $self->{sel_m1}->fetchrow_hashref();
    $self->{sel_m1}->finish();
    unless($mission) {
        warn "can not get pack mission by ack_id[$args->{ack_id}] and sm_date[$args->{sm_date}]" if DEBUG;
        return;    
    }

    # 如果 状态为 可开始 或 导出失败，那么导出周期确认流水文件
    if ($mission->{status} == PMISSION_STARTABLE || $mission->{status} == PMISSION_FAIL_EXPORT)  {
        # 暂估周期确认银行手续费 科目指定确认规则按交易日期分类汇总
        my %zg_bfee;
        $self->{sum_zg}->execute($args->{ack_id});
        while (my $row = $self->{sum_zg}->fetchrow_hashref())  {
            $zg_bfee{$row->{tx_date}} = $row->{d} - $row->{j};
        }
        # 调用计费系统返回 实际总额，打折比例，确认周期
        my $config  = $self->{cfg}{bip};
        my $inst    = $config->inst();
        my $res = $inst->verify( 
            {
                ack_id  => $args->{ack_id},
                zg_bfee => \%zg_bfee,
                sm_date => $args->{sm_date},
            }
        );
        unless($res) {
            warn "inst verify can not get result" if DEBUG;
            return;
        }
        # 如果没有返回确认周期，那么控制表修改为(-1 未达确认周期状态),停止整个处理
        unless ($res->[RES_PBFEE][RES_PBFEE_PERIOD]) {
            #### 将控制表修改为(-1 未达确认周期状态)
            $self->{upd_m}->execute(PMISSION_NO_PERIOD, $mission->{id});
            $self->{cfg}{dbh}->commit();
            return;         
        }
        # 导出一个sql语句查询出来的内容(指定确认规则id按各核算项分类汇总暂估手续费, 进行分摊，并且算出ark0)
        unless($self->_export_file($args, $res)) {
            #### 为(-2 导出文件失败), 停止整个处理
            $self->{upd_m}->execute(PMISSION_FAIL_EXPORT, $mission->{id});
            $self->{cfg}{dbh}->commit();
            return
        }
        #### 将控制表状态改为(2 导出文件成功), 继续执行以下流程
        $self->{upd_m}->execute(PMISSION_SUCCESS_EXPORT, $mission->{id});
        $self->{cfg}{dbh}->commit();
    }
    #return 1;
    # 生成mission, 将控制表状态更新为(3 确认中)
    my $m_id;
    eval {
        $m_id = $self->{cfg}{batch}->insert_mission(PACK_YSPZ, $args->{sm_date}, 0, 0, 0, MISSION_ASSIGNABLE);
        $self->{cfg}{dbh}->commit();
    };
    if ($@) {
        # 唯一键重复....
        my $err    = $self->{cfg}{dbh}->err;
        # 已经存在指定 load_mission， 继续
        if ( $err =~ /803/ ) {
            warn "insert load mission: unique index error" if DEBUG;
        }
        # 不能插入load_mission, 将控制表状态更新为(-3 确认失败), 停止继续以下流程 
        else {
            warn "can not insert load mission" if DEBUG;
            #### 将控制表状态更新为(-3 确认失败)
            $self->{upd_m}->execute(PMISSION_FAIL, $mission->{id});
            $self->{cfg}{dbh}->commit();
            return;
        }
    }
    #### 将控制表状态更新为(3 确认中)
    $self->{upd_m}->execute(PMISSION_RUNNING, $mission->{id});
    $self->{cfg}{dbh}->commit();
    
    # 向系统发凭证导入命令(分配，导入)
    require Mojo::UserAgent;
    my $cfg = $self->{cfg};
    my $url = 'http://127.0.0.1:' . $cfg->{main}->{port} . '/';
    my $ua = Mojo::UserAgent->new;
    my $req;
    # 0 表示未开始调用; 1 表示调用了assign_job; 2 表示调用了run_mission
    my $status    = 0;
    my $timeout   = 3600;      # 超时时间为1个小时
    my $timecount = 0;        # 已运行时间
    while (1) {
        my $m = $self->{cfg}{batch}->mission_type(PACK_YSPZ, $args->{sm_date});
        # 如果mission状态为失败， 那么更新为(-3 确认失败)
        if ($m->{status} == MISSION_FAIL_RUN) {
            #### 将控制表修改为(-3 确认失败)
            $self->{upd_m}->execute(PMISSION_FAIL, $mission->{id});
            $self->{cfg}{dbh}->commit(); 
            last;
        }
        # 如果mission状态为成功，那么更新为(4 确认成功)
        elsif ($m->{status} == MISSION_SUCCESS) {
            #### 将控制表修改为(4 确认成功)
            $self->{upd_m}->execute(PMISSION_SUCCESS, $mission->{id});
            $self->{cfg}{dbh}->commit();
            last;
        }

        # mission 为可分配 -> 开始分配
        if ($m->{status} == MISSION_ASSIGNABLE) {
            # 已经调用过分配文件了
            if ($status == 1) {
                goto NEXT;
            }
            $req = {
                action => "assign_job",
                param  => {
                    mission_id => $m->{id},
                    date       => $m->{date},
                    type       => $m->{type},
                },
            }; 
        }
        # mission 分配失败 -> 重新分配
        elsif ($m->{status} == MISSION_FAIL_ASSIGN) {
            # 已经调用过分配文件了
            if ($status == 1) {
                goto NEXT;
            }
            $req = {
                action => "assign_job",
                param  => {
                    mission_id => $m->{id},
                    date       => $m->{date},
                    type       => $m->{type},
                },
            }; 
        }
        # mission 为可运行 -> 开始运行...
        elsif ($m->{status} == MISSION_RUNNABLE) {
            # 已经调用了运行
            if ($status == 2) {
                goto NEXT;
            }
            $req = {
                action => 'run_mission',
                param  => {
                    mission_id => $m->{id},
                    date       => $m->{date},
                    type       => $m->{type},
                },
            };
        }
        else {
            goto NEXT;
        }

        my $reqstr = encode_json($req);
        #my $res = $ua->post($url => json => $req)->res->json;
        my $res = $ua->post($url => $reqstr)->res->json;
        # 发送请求成功
        if ($res->{status} eq  0) {
            # 如果action为'assign_job', 那么$status=1 表示调用了assign_job
            if ($req->{action} eq 'assign_job') {
                $status = 1;
            }
            # 如果action为'run_mission', 那么$status=2 表示调用了run_mission
            elsif ($req->{action} eq 'run_mission') {
                $status = 2;
            }
        }
        # 请求失败
        else {
            #### 将控制表修改为(-3 确认失败)
            $self->{upd_m}->execute(PMISSION_FAIL, $mission->{id});
            $self->{cfg}{dbh}->commit();
            last;
        }
NEXT:
        # 如果运行时间 >= 超时时间，那么设置为确认失败
        if ($timecount >= $timeout) {
            #### 将控制表修改为(-3 确认失败)
            $self->{upd_m}->execute(PMISSION_FAIL, $mission->{id});
            $self->{cfg}{dbh}->commit();
            last;
        }
        # 休眠5秒
        sleep(5);
        $timecount += 5;
    }

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
    my ($self, $args, $res) = @_;
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
        $self->{pack_yspz1}->execute($bfee, $args->{ack_id}, $begin, $end);
        $sth_pack = $self->{pack_yspz1};
    }
    unless ($args->{sm_date} =~ /(\d{4})-(\d{2})-(\d{2})/) {
        warn "args->{sm_date}[$args->{sm_date}] format is error" if DEBUG;
        return;
    }
    my $sm_date = $1 . $2 . $3;
    # 生成文件
    my $dir_pack  = "$ENV{ZIXAPP_HOME}/data/$sm_date";
    my $file_pack = "$dir_pack" . "/0031.src";
    mkpath($dir_pack);
    my $fd_pack = IO::File->new("> $file_pack");
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
    $fd_pack->close();
    
    # 文件生成完后，创建ok文件，并且上传
    my $ok;
    open $ok, ">$dir_pack/ok.pack-0031-$sm_date"
        or die "Cannot touch ok file";
    $ok->close();

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

