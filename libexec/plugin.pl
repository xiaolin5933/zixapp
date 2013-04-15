#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Zeta::Run;
use DBI;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
# 父进程加载插件
#

my $cfg = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
confess "can not load $ENV{ZIXAPP_HOME}/conf/zixapp.conf error[$@]" unless $cfg;

helper zapp_config => sub { $cfg };
helper zapp_dbh    => sub {
    # 获取配置
    my $cfg = zkernel->zapp_config();

    warn "zapp_config:\n" . Data::Dump->dump($cfg) if DEBUG;

    # 连接数据库
    my $dbh = DBI->connect(
        @{$cfg->{db}}{qw/dsn user pass/},
        {
            RaiseError       => 1,
            PrintError       => 0,
            AutoCommit       => 0,
            FetchHashKeyName => 'NAME_lc',
            ChopBlanks       => 1,
        }
    );
    unless($dbh) {
        zlogger->error("can not connet db[@{$cfg->{db}}{qw/dsn user pass/}], quit");
        exit 0;
    }

    # 设置默认schema
    $dbh->do("set current schema $cfg->{db}->{schema}") or confess "can not set current schema $cfg->{db}->{schema}";
   
    return $dbh;
};

#helper zapp_proc    => sub {
#	# 构建proc对象
#    my $proc = Zark::Proc->new(
#        $dbh,
#        proc => $cfg->{proc}
#    ) or confess "can not Zark::Proc->new";	
#}


1;


