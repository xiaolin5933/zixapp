package ZAPP::YSPZ::Batch;
use strict;
use warnings;
use Carp;
use Net::FTP;
use DateTime;
use ZAPP::YSPZ::Constant;
use ZAPP::YSPZ::Load;
use File::Path qw/mkpath/;

use constant {
    DEBUG => $ENV{ZAPP_YSPZ_BATCH_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

###########################################
# 参数:  $cfg
#------------------------------------------
# 对象:
# {
#     dbh     => $dbh,
#     ins_j   => 插入任务,
#     upd_j   => 更新任务状态,
#     sel_j   => 查询某工作的所有任务,
#     sel_j_1 => 查询指定任务,
#     
#     ins_m   => 插入工作,
#     upd_m   => 更新工作,
#     sel_m   => 查询工作,
#     sel_m_1 => 
# }
###########################################
sub new {
    my ($class, $cfg) = @_;
    my $self = bless { }, $class;
    $self->{cfg} = $cfg;;
    $self->setup();
    return $self;
}

#
# 设置数据库相关
# $self->setup();
#
sub setup {
    my $self = shift;
    my $dbh = $self->{cfg}{dbh};

    my %sql = (
        # 插入mission的sth
        # 插入job的sth
        ins_j => q/insert into load_job values(?,?,?,?,?,?,?,?,?,?,default,default)/,
        ins_m => q/insert into load_mission  values(?,?,?,?,?,?,?,?,default,default)/,

        # 更新mission的sth
        # 更新job的sth
        upd_j => q/update load_job set status = ?, succ = ?, fail = ?  where id = ?/,
        upd_m => q/update load_mission set status = ?, total = ?, succ = ?, fail = ? 
                    where id = ?/,

        # 插入mission的sth
        # 找到mission_id的所有job
        # 指定任务id查询指定任务 
        # 获取整个load_cfg表信息
        sel_m   => q/select * from load_mission where id = ?/,
        sel_m_1   => q/select * from load_mission where type = ? and date = ?/,
        sel_j   => "select * from load_job where status = \'" . JOB_RUNNABLE . 
                   "\' and mission_id = ?",
        sel_j_1 => q/select * from load_job where id = ?/,

        # sequence
        seq_j => q/values nextval for seq_load_job/,
        seq_m => q/values nextval for seq_load_mission/,
    );

    # 准备sth
    for (keys %sql) {
        warn "begin prepare sql[$_][$sql{$_}]" if DEBUG;
        $self->{$_} = $dbh->prepare($sql{$_});
    }

    # 读取所有的load_cfg;
    my $all = $dbh->selectall_arrayref(q/select * from load_cfg/, { Slice => {} });
    for (@$all) {
       $self->{load_cfg}{delete $_->{type}}  = $_;
    }

    return $self;
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

#
# 获取任务ID
#
sub _job_id {
    my $self = shift;
    $self->{seq_j}->execute();
    my ($id) = $self->{seq_j}->fetchrow_array();
    return $id;
}

#
# 找出mission_id的所有JOB_RUNNNABLE记录ID
#
sub jobs {
    my ($self, $mid) = @_;
    $self->{sel_j}->execute($mid);
    my @jobs;
    while(my $row = $self->{sel_j}->fetchrow_hashref()) {
        push @jobs, $row;
    }
    return \@jobs;
}

sub job {
    my ($self, $jid) = @_;
    $self->{sel_j_1}->execute($jid);
    my $job = $self->{sel_j_1}->fetchrow_hashref();
    $self->{sel_j_1}->finish();

    return $job;
}

#
# 找出指定id的mission记录
#
sub mission {
    my ($self, $type) = @_;
    $self->{sel_m}->execute($type);
    return $self->{sel_m}->fetchrow_hashref();
}

#
# 找出指定日, 制定类型[0002|0003..]的mission记录
#
sub mission_type {
    my ($self, $type, $date) = @_;
    $self->{sel_m_1}->execute($type, $date);
    return $self->{sel_m_1}->fetchrow_hashref();
}

#
# 返回指定类型的fname
#
sub fname {
    my ($self, $type) = @_;
    return $self->{load_cfg}{$type}{fname};
}


#
# 准备mission: 每日早上00:10分, 将在load_mission中插入mission记录
# param => {date => '2013-03-25'}
#
sub prep_mission {
    my ($self, $param) = @_;

    # 向mission表中插入所有工作 : read table: load_cfg;
    eval {
        for my $type (keys %{$self->{load_cfg}}) {
            my $id = $self->_mission_id();
            $self->{ins_m}->execute($id, $type, $param->{date}, 
                                    0, 0, 0, MISSION_STARTABLE, undef);
        }
    };
    if ($@) {
        $self->{cfg}{dbh}->rollback();
        return $self; 
    }
    $self->{cfg}{dbh}->commit();

    # 插入完后在data目录下创建日期目录
    my $date = $param->{date};
    $date =~ s/-//g;
    mkpath("$ENV{ZIXAPP_HOME}/data/$date");  

    return $self;
}


#
# 下载文件
#
# $param = {
#     mission_id    => $mission_id,
#     type          => $type,
#     date          => $date,
# }
#
sub down_file {

    my ($self, $param) = @_;

    warn "being_down_file........" if DEBUG; 

    # 更新为下载中
    $self->{upd_m}->execute(MISSION_DOWNING, 0, 0, 0, $param->{mission_id});
    $self->{cfg}{dbh}->commit();

    my $date = $param->{date};
    $date =~ s/-//g;

    # 转到数据所在日期目录  
    chdir "$ENV{ZIXAPP_HOME}/data/$date";
   
    # 根据load_cfg下载文件 
    my $row = $self->{load_cfg}{$param->{type}};
    eval {
        my $down = Net::FTP->new($row->{host})              or confess "can not Net::FTP->new";
        $down->login(@{$row}{qw/user pass/})                or confess "can not login";
        $down->cwd($row->{rdir} . "/$date")                 or confess "can not cwd";
        $down->get($self->fname($param->{type}))            or confess "can not get file";
        $down->quit;     
        rename $self->fname($param->{type}), "$param->{type}.src" or confess "can not rename";
    };

    #下载失败, 更新状态为下载失败
    if ($@) {
        warn "down_file failed error[$@]" if DEBUG;
        $self->{cfg}{dbh}->rollback();
        $self->{upd_m}->execute(MISSION_FAIL_DOWN,0,0,0,$param->{mission_id});
        $self->{cfg}{dbh}->commit();
        return;
    }

    # 更新状态为下一步: 可分配
    $self->{upd_m}->execute(MISSION_ASSIGNABLE, 0, 0, 0, $param->{mission_id});
    $self->{cfg}{dbh}->commit();
  
    return $self;
}


#
# 分配任务
#
# $param = {
#     date       => $date,
#     type       => $type,
#     mission_id => $mid,
# }
#
sub assign_job {

    my ($self, $param) = @_;

    my $date = $param->{date};
    $date =~ s/-//g;

    # 建立工作目录, 进入工作目录
    my $jhome = "$ENV{ZIXAPP_HOME}/data/$date/$param->{type}";
    mkpath("$jhome");
    chdir $jhome;

    # 设置mission为分配中
    $self->{upd_m}->execute(MISSION_ASSIGNING, 0, 0, 0, $param->{mission_id});
    $self->{cfg}{dbh}->commit();

    # 待分配文件
    my $file  = "$jhome.src";
    my $total;
    $total = `wc -l $file | awk '{ print \$1}'`;

    my $iswc = 1;
    unless ( defined $total ) {
        $iswc  = 0; 
        $total = 'err';
    }
    unless ( $total =~ /^\d+$/ ) {
        $iswc = 0;
    }
    unless ($iswc) {
        $self->{upd_m}->execute(MISSION_FAIL_ASSIGN, 0, 0, 0, $param->{mission_id});
        $self->{cfg}{dbh}->commit();
        return;
    }
    $total =~ s/^\s+|\s+$//;

    # 文件为空, 直接更新mission为完成
    if ($total == 0 ) {
        $self->{upd_m}->execute(MISSION_SUCCESS, $total, 0, 0, $param->{mission_id} );
        $self->{cfg}{dbh}->commit();
        return $self;
    }

    # 计算分割为多少文件: 每个文件大小
    my $size  = int($total / 5);   # 单个文件大小
    my $res   = $total % 5;        # 最后一个文件大小
    my $cnt;
    if ($size == 0 ) {
        $cnt = 0;
    }
    else {
        $cnt = int($total/$size);
    }
    warn "total: $total, size: $size, res: $res" if DEBUG;


    # 开始分割, 插入load_job任务记录
    eval {
        # 文件切割
        `split -a 1 -d -l $size $file`;

        # 插入任务load_job
        for ( 0..$cnt-1 ) {
            my ($id) = $self->_job_id();
            $self->{ins_j}->execute($id, $param->{type}, $param->{date}, $_,
                $param->{mission_id}, $size, 0, 0, JOB_RUNNABLE, undef);
        } 

        # 不够整数部分
        if ($res) {
            my ($id) = $self->_job_id();
            $self->{ins_j}->execute($id, $param->{type}, $param->{date}, $cnt,
                $param->{mission_id}, $res, 0, 0, JOB_RUNNABLE, undef);
        }
    };

    # 更新mission为分配失败,
    if ($@) { 
        $self->{cfg}{dbh}->rollback();
        $self->{upd_m}->execute(MISSION_FAIL_ASSIGN, $total, 0, 0, $param->{mission_id});
        $self->{cfg}{dbh}->commit();
        return;
    }

    # 更新mission为已分配, total为$total
    $self->{upd_m}->execute(MISSION_RUNNABLE, $total, 0, 0, $param->{mission_id});
    $self->{cfg}{dbh}->commit();

    return 1;
}

#
# 运行任务
#
# $param => {
#     job_id => $jid 
# }
#
sub run_job {
    my ($self, $param) = @_;
    $self->{sel_j_1}->execute($param->{job_id});
    my $job = $self->{sel_j_1}->fetchrow_hashref();
    $self->_run_job($job);
}


#
# $job = load_job数据库记录
#
sub _run_job {
    my ($self, $job) = @_;

    # 如果$job不是可运行状态
    return unless $job->{status} == JOB_RUNNABLE;

    warn "begin run job:\n" . Data::Dump->dump($job) if DEBUG;

    # 用load处理任务
    $self->{cfg}{load}->handle({
        job_id      => $job->{id},            # '1',
        mission_id  => $job->{mission_id},    # '1',
        index       => $job->{index}, #
        type        => $job->{type},  # '0002',
        date        => $job->{date},  # '2013-03-25',
        total       => $job->{total}, #
    });
}

#
# param => {
#    job_id => $id,
#    type   => $type,
#    date   => $date,
# }
#
sub get_log {
    my ($self, $param)  = @_;
    my @logs;
    eval {
        my $date = $param->{date};
        $date =~ s/-//g;

        my $job   = $self->job($param->{job_id});
        my $index = $job->{index};
    
        my $logfile = "$ENV{ZIXAPP_HOME}/data/$date/$param->{type}/x$job->{index}.log";
        open(IN, "<$logfile");
        while ( <IN> ) {
            substr($_, 9, 39) = "";   # 过滤日志中的9-31列
            warn "str#####: $_";
            push @logs, $_;
        }
        close(IN);
    };
    if ($@) {
        warn "can not get job log type[$param->{type}] date[$param->{date} job_id[$param->{job_id}]" if DEBUG; 
    }

    return \@logs;
}

1;

__END__


