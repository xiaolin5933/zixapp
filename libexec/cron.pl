#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Mojo::UserAgent;
use Getopt::Long;
use Zeta::Run;
use DateTime;
use ZAPP::YSPZ::Batch;
use ZAPP::YSPZ::Constant;
use Data::Dump;
use constant DEBUG => $ENV{ZAPP_CRON_DEBUG} || 0;

my $type;    # 类型
my $rtn = GetOptions(
    "type|t=s"  => \$type,
);
unless($rtn) {
    &usage();
}
unless(defined $type) {
    &usage();
}
unless($type =~ /(0002|0003|0004|0007|0009|0016|0017|prep)/) {
    &usage();
}

# 加载配置
my $cfg = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
if ($@) {
    confess "can not load zixapp.conf error[$@]";    
}
my $dt = DateTime->now('time_zone' => 'local');
my $date = $dt->ymd('-');

#####################################################
# debug模式, 提供date
#####################################################
if (DEBUG) {
    unless(@ARGV) {
        warn "debug usage: ./cron.pl -t 0002 yyyymmdd";
        exit 0;
    } 
    $date = shift;
    $date =~ /(\d{4})(\d{2})(\d{2})/;
    $date = "$1-$2-$3";
    warn "debug date: $date";
}

# 开始
&batch_mission($type);

# help & prompt
sub usage {
    print <<EOF;
    cron.pl -t|--type [0002|0003|0004|0007|0009|0016|0017|prep]
EOF
    exit 0;
}

################################################
# 处理任务
################################################
sub batch_mission {
    my $type = shift;
    $cfg->{dbh} = zkernel->zapp_dbh();
    my $batch = ZAPP::YSPZ::Batch->new($cfg);
 
    # 生成工作
    if ($type =~ /prep/) { 
        unless($batch->prep_mission({ date => $date})) {
            warn "生成工作失败";
        }
        warn "生成工作成功";
        exit 0;
    }

    # 找出mission
    my $m = $batch->mission_type($type, $date);


    # mission 完成
    if ($m->{status} == MISSION_SUCCESS) {
        warn "mission[$type][$date][$m->{id}] 已经成功";
        exit 0;
    }

    # mission 失败 - 运行
    if ($m->{status} == MISSION_FAIL_RUN) {
        warn "mission[$type][$date][$m->{id}] 运行失败, 请联系技术支持...";
        exit 0;
    }

    #######################################
    my $url = 'http://127.0.0.1:' . $cfg->{main}->{port} . '/';
    my $ua = Mojo::UserAgent->new;
    my $req;

    # mission 下载失败 -> 重新下载
    if ($m->{status} == MISSION_FAIL_DOWN) {
        warn "mission[$type][$date][$m->{id}] 下载失败, 重新下载...\n";
        $req = {
            action => 'down_file', 
            param  => {
                mission_id => $m->{id},
                date       => $m->{date},
                type       => $m->{type},
            },
        };
    }

    # mission 分配失败 -> 重新分配
    elsif ($m->{status} == MISSION_FAIL_ASSIGN) {
        warn "mission[$type][$date][$m->{id}] 失败分配, 重新分配...";
        $req = {
            action => 'assign_job',
            param  => {
                mission_id => $m->{id},
                date       => $m->{date},
                type       => $m->{type},
            },
        };
    }

    # mission 为可分配 -> 开发分配
    elsif ($m->{status} == MISSION_ASSIGNABLE) {
        warn "mission[$type][$date][$m->{id}] 为可分配, 开始分配...";
        $req = {
            action => 'assign_job',
            param  => {
                mission_id => $m->{id},
                date       => $m->{date},
                type       => $m->{type},
            },
        };
    }

    # mission 为可开始 -> 开始下载
    elsif ($m->{status} == MISSION_STARTABLE) {
        warn "mission[$type][$date][$m->{id}] 为可开始, 开始下载...";
        $req = {
            action => 'down_file', 
            param  => {
                mission_id => $m->{id},
                date       => $m->{date},
                type       => $m->{type},
            },
        };
    }

    # mission 为可运行 -> 开始运行...
    elsif ($m->{status} == MISSION_RUNNABLE) {
        warn "mission[$type][$date][$m->{id}] 为可运行, 开始运行...";
        $req = {
            action => 'run_mission',
            param  => {
                mission_id => $m->{id},
                date       => $m->{date},
                type       => $m->{type},
            },
        };
    }

    # 非法状态
    else {
        warn "internal error, 未知的mission status[$m->{status}]";
        exit 0;
    }
    
    my $res = $ua->post($url => json => $req)->res->json;
    my $msg = "mission[$type][$date][$m->{id}] action[$req->{action}]";
    Data::Dump->dump($res);
    if ($res->{status} == 0) {
        warn "$msg 成功";
    }
    else {
        warn "$msg 失败[$res->{errmsg}]";
    }
}

