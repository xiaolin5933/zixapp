#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Zeta::Run;
use DBI;
use Zark;
use ZAPP::BIP::Config;
use ZAPP::YSPZ::Batch;
use Net::Stomp;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN { require Data::Dump if DEBUG; }

my $cfg;  # 主应用配置

my $svc;   # svc配置
my $proc;  # proc配置
my $load;  # load配置

eval {
    $cfg  = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
    $proc = do "$ENV{ZIXAPP_HOME}/conf/proc.conf";
    $svc  = do "$ENV{ZIXAPP_HOME}/conf/svc.conf";
    $load = do "$ENV{ZIXAPP_HOME}/conf/load.conf";
};
confess "[$@]" if $@;
$proc ||= {};
$svc  ||= {};
$load ||= {};

#
# svc配置  - svc   - 服务开发
# 增加配置 - dbh   - 数据库连接
# 增加配置 - zark  - 凭证处理
#
$cfg->{svc}  = $svc;
$cfg->{dbh}  = zkernel->zapp_dbh();
$cfg->{zark} = Zark->new(dbh => $cfg->{dbh}, proc => $proc, setup => 0,);

# 增加配置 - dt    : 时间管理
# 增加配置 - bip   : 银行协议配置
# 增加配置 - batch : 批处理控制
# 增加配置 - load  : 凭证批导
$cfg->{dt}    = ZAPP::DT->new($cfg);
$cfg->{bip}   = ZAPP::BIP::Config->new($cfg);
$cfg->{load}  = ZAPP::YSPZ::Load->new($cfg, $load, 0);
$cfg->{batch} = ZAPP::YSPZ::Batch->new($cfg);

# 返回值
$cfg;

