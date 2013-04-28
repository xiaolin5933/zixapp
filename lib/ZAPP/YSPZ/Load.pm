package ZAPP::YSPZ::Load;
use strict;
use warnings;
use Zark::Constant;
use Zark;
use ZAPP::BIP::Config;
use ZAPP::YSPZ::Constant;
use Zeta::Log;
use Time::HiRes qw/gettimeofday tv_interval/;

use constant {
    DEBUG              => $ENV{ZAPP_YSPZ_LOAD_DEBUG} || 0, # 测试: 
    COMMIT_BATCH_SIZE  => 100,  # 数据库提交批次大小
};

BEGIN {
    require Data::Dump if DEBUG;
}

########################################################
# 参数: 
#   $cfg    : zapp主配置
#   $load   : 批导配置
#   $setup  : 是否设置数据库
#
# 对象结构:
# {
#    cfg   => $cfg,  # 配置
#    load  => $load, # 批导处理配置
#    batch => 100,   # 提交批次大小
#    ujob  => $sth,
# }
#---
########################################################
sub new {
    my ($class, $cfg, $load, $setup) = @_;
    my $self = bless {}, $class;
    $self->{cfg}   = $cfg;
    $self->{load}  = $load;
    $self->{batch} = $self->{cfg}{commit_size} || COMMIT_BATCH_SIZE;
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
    # 更新job
    $self->{ujob} = $self->{cfg}{dbh}->prepare(<<EOF);
update load_job set fail = ?, succ = ?, status = ?  where id = ?
EOF

    # 更新mission
    $self->{umission} = $self->{cfg}{dbh}->prepare(<<EOF);
update load_mission set status = ?, succ = ?, fail = ? 
               where id = ?
EOF

    # 更新mission状态为成功或失败
    $self->{upd_m} = $self->{cfg}{dbh}->prepare(<<EOF);
update load_mission set status = 
(
    case total 
        when succ then 7
        when fail then -3
        else 6
    end
)
where id = ? and total > 0
EOF

    # 更新成功数 +n
    # 更新失败数 +n
    $self->{upd_stat} = $self->{cfg}{dbh}->prepare(<<EOF);
update load_mission set succ=succ+?, fail=fail+? where id = ?
EOF

    # 统计指定mission的各状态所对应的job数量
    $self->{stat_j} = $self->{cfg}{dbh}->prepare(<<EOF);
select count(*) as count, sum(succ) as succ, sum(fail) as fail, status from load_job where mission_id = ? group by status
EOF

    return $self;
}

#
# $args = {
#      job_id       => $job_id,     # 任务ID
#      mission_id   => $mission_id, # 对应的工作ID
#      index        => $index,      # 任务序号
#      type         => $type,       # 任务类型
#      date         => $date,       # 任务的工作日期
#      total        => $total,      # 任务的记录条数
# }
#
sub handle {
    my ($self, $args) = @_;

    my $date = $args->{date};
    $date =~ s/-//g;

    # 打开文件
    my $file = "$ENV{ZIXAPP_HOME}/data/$date/$args->{type}/x$args->{index}";
    my $fh = IO::File->new("<$file");
    unless ($fh) {
        warn "can not open file[$file]" if DEBUG;
        return;
    }

    # 失败文件
    my $flog = IO::File->new("$file.fail");

    # 日志
    my $logger = Zeta::Log->new(
        logurl   => "file://$file.log",
        loglevel => 'DEBUG',
    );

    my $type = $args->{type}; 
    my $zark = $self->{cfg}{zark};
    my $load = $self->{cfg}{load}{$type};

    my $rotation = 0;   # 当前批次  
    my $size = 0;       # 当前批次第几条
    my $line = 0;      # 当前行

    my $fail = 0;  # 失败记录数
    my $succ = 0;  # 成功记录数
    my $status = JOB_RUNNING;

    my $ts_beg = [gettimeofday];

    # 更新任务为 运行中
    $self->{ujob}->execute($fail, $succ, $status, $args->{job_id});
    $self->{cfg}{dbh}->commit();
   
    while(<$fh>) {
        ++$line;

        s/^\s+|\s+$//;

        # 生成原始凭证
        my $yspz = $self->{load}{$type}->($self, $_);  
        unless($yspz) {
            $logger->error(
                 sprintf("非法数据行: L[%06d] B[%06d] I[%03d]", 
                     $line, $rotation, $size)
            );
            ++$fail;
            $flog->print($_, "\n");
            next;
        }

        # db
        eval { 
            # 插入原始凭证(`处理成功)
            # 处理原始凭证, 登记账簿
            # 更新原始凭证处理状态
            $yspz->{id} = $self->{cfg}{zark}->yspz_ins( 
                $yspz->{_type}, 
                @{$yspz}{@{$self->{cfg}{zark}->yspz_flist($yspz->{_type})}},
            );
            $self->{cfg}{zark}->handle($yspz);
            $self->{cfg}{zark}->yspz_upd($yspz->{_type}, '1', $yspz->{period}, $yspz->{id});

        };
        if ($@) {
            # 主键重复....
            # todo
            if (0) {
                next;
            }

            $flog->print($_, "\n");
            $logger->error(sprintf("不能处理原始凭证: L[%06d] B[%06d] I[%03d] errmsg[$@]", $line, $rotation, $size));

            $self->{cfg}{dbh}->rollback();

            # 重置批次:
            $size = 0;
            ++$rotation;
            ++$fail;
            next;
        }


        ++$size;

        # 批次完成， 提交批次
        if ($size == $self->{batch}) {
            $succ += $size;

            # 更新子任务进度
            $status = $fail > 0 ? JOB_FAIL : JOB_SUCCESS if $line == $args->{total};
            $self->{ujob}->execute($fail, $succ, $status, $args->{job_id});
            $self->{cfg}{dbh}->commit();

            my $elapse = tv_interval($ts_beg);
            $logger->debug(sprintf("成功! B[%06d], BS[%03d], L[%06d] T[$elapse]", $rotation, $self->{batch}, $line));

            $ts_beg = [gettimeofday];

            ++$rotation;
            $size = 0;
        }

    }
 
    # 最后一个批次
    if ( $size ) {
        $succ += $size;

        # 更新子任务进度
        $status = $fail > 0 ? -1 : 3;
        $self->{ujob}->execute($fail, $succ, $status, $args->{job_id});
        $self->{cfg}{dbh}->commit();

        my $elapse = tv_interval($ts_beg);
        $logger->debug(sprintf("成功! B[%06d], BS[%03d], L[%06d] T[$elapse]-- 最后一批", $rotation, $size, $line));
    }
    else {
        # 更新子任务进度
        $status = $fail > 0 ? -1 : 3;
        $self->{ujob}->execute($fail, $succ, $status, $args->{job_id});
        $self->{cfg}{dbh}->commit();
    }

    # 增加mission中，成功或失败数量
    $self->{upd_stat}->execute($succ, $fail, $args->{mission_id});
    $self->{cfg}{dbh}->commit();

    # 更新mission执行状态
    $self->{upd_m}->execute($args->{mission_id});
    $self->{cfg}{dbh}->commit();

    return $self;
}

1;

__END__

