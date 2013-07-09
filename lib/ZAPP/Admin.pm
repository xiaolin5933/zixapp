package ZAPP::Admin;
use strict;
use warnings;
use Zeta::Run;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
# 参数: $cfg
#
# 对象结构:
# {
#    cfg    => $cfg,
# }
#
sub new {
    my ($class, $cfg, $flag) = @_;
    my $self = bless { cfg => $cfg }, $class;
    return $self;
}

#
# 子进程处理
#
sub child {
    my $req = shift;

    # 子进程重置, 需要dbh重置
    my $cfg = zkernel->zconfig;
    $cfg->{dbh} = zkernel->zdbh();
    $cfg->{batch}->setup();

    warn "---------------";
    warn "child with:\n" . Data::Dump->dump($req);

    # 只有run_job的任务需要zark, load
    if ($req->{action} =~ /run_job/) {
        $cfg->{zark}->setup($cfg->{dbh});
        $cfg->{load}->setup();
    }

    # 子进程处理
    no strict 'refs';
    my $code = \&{"ZAPP::YSPZ::Batch::$req->{action}"};
    $code->($cfg->{batch}, $req->{param});

    exit 0;
}

#
# {
#    action => 'down_file|assign_job|run_job'
#    param  => {
#        type => '0002|0003|0004|0007|0009',
#    }
# }
#
# 1:  down_file
#-------------------------------------------
# {
#    action => 'down_file',
#    param  => {
#        mission_id => $id,
#        date       => $date,
#        type       => $type,
#    }
# }
#
# 2:  assign_job
#-------------------------------------------
# {
#    action => 'assign_job',
#    param  => {
#        mission_id => $id,
#        date       => $date,
#        type       => $type,
#    }
# }
#
# 3:  run_job
#-------------------------------------------
# {
#    action => 'run_job',
#    param  => {
#        job_id => $id,
#        date   => $date,
#        type   => $type,
#    }
# }
#
# 4:  run_mission
#-------------------------------------------
# {
#    action => 'run_mission',
#    param  => {
#        mission_id => $id,
#        type       => $type,
#        date       => $date,
#    }
# }
#
# 5:  get_log
# {
#    action => 'get_log',
#    param  => {
#        job_id     => $id,
#        type       => $type,
#        date       => $date,
#    }
#
# }
#
#
# 6:  pack
# {
#    action => 'pack',
#    param  => {
#        sm_date    => $sm_date,        # 扫描日期(不能 >= 当前日期)
#        ack_id     => $ack_id,         # 确认规则ID
#    }
#
# }
#
# result:
# {
#   status => $status,      # 0 成功, 其他失败
#   errmsg => $errmsg,      # 错误信息
#   ret    => $ret,         # 返回值
# }
#
sub handle {
    my ($self, $req) = @_;

    # Data::Dump->dump($self->{cfg}{batch}->jobs(1));

    my $rtn = {
        status => 0,
    };

    #
    # if zkernel->prcess_count() > 16 , 
    # { status => 1,  errmsg => 'resubmit it later, system busy' }
    #
    my $date = $req->{param}{date};
    $date =~ s/-//g if $date;

    # 下载文件
    if($req->{action} =~ /^down_file/) {
        my $name = 'Zbatch' . 
                   '-' . $date .
                   '-' . $req->{param}{type} .
                   '-' . 'down';
        my $rtn = zkernel->process_submit(
            $name,
            {
               code => \&child,
               para => [ $req ],
               reap => 0,
               size => 1,
            },
        );
    }
    # 分配任务
    elsif($req->{action} =~ /^assign_job/) {
        my $name = 'Zbatch' . 
                   '-' . $date . 
                   '-' . $req->{param}{type} .
                   '-' . 'assign';
        my $rtn = zkernel->process_submit(
            $name,
            {
               code => \&child,
               para => [ $req ],
               reap => 0,
               size => 1,
            },
        );
    }
    # 运行任务
    elsif ($req->{action} =~ /^run_job/) {
        my $job = $self->{cfg}{batch}->job($req->{param}{job_id});
        my $name = 'Zbatch' . 
                   '-' . $date . 
                   '-' . $req->{param}{type} .
                   '-' . 'load' .
                   '-' . $job->{index};
        my $rtn = zkernel->process_submit(
            $name,
            {
               code => \&child,
               para => [ $req ],
               reap => 0,
               size => 1,
            },
        );
    }
    # 运行工作
    elsif ( $req->{action} =~ /run_mission/) {
        warn "begin get jobs id....." if DEBUG;
        my $jobs = $self->{cfg}{batch}->jobs($req->{param}{mission_id});
        Data::Dump->dump($req->{param}{mission_id}) if DEBUG;
        warn "run ids: \n" . Data::Dump->dump($jobs) if DEBUG;
        for (@$jobs) {

            my $name = 'Zbatch' .
                       '-' . $date .
                       '-' . $req->{param}{type} .
                       '-' . 'load' .
                       '-' . $_->{index};

            my $submit = {
                action => 'run_job',
                param  => {
                    type   => $req->{param}{type},
                    job_id => $_->{id}, 
                },
            };
            zkernel->process_submit(
                $name,
                {
                   code => \&child,
                   para => [ $submit ],
                   reap => 0,
                   size => 1,
                }
            );
        }
    }
    elsif ( $req->{action} =~ /get_log/ ) {
        $rtn->{ret} = $self->{cfg}{batch}->get_log($req->{param});
    }
    elsif ( $req->{action} =~ /pack/ ) {
        my $job = $self->{cfg}{batch}->job($req->{param}{job_id});
        my $name = 'Zbatch' .
                   '-' . $date .
                   '-' . $req->{param}{type} .
                   '-' . 'load' .
                   '-' . $job->{index};
        my $rtn = zkernel->process_submit(
            $name,
            {
               code => \&child,
               para => [ $req ],
               reap => 0,
               size => 1,
            },
        );
        $rtn->{ret} = $self->{cfg}{pack}->ack($req->{param});
    }
    else {
        zlogger->error("invalid action[$req->{action}]");
        $rtn->{status} = 1;
        $rtn->{errmsg} = "invalid action[$req->{action}]";
    }

    return $rtn;
}

1;

__END__
