#!/usr/bin/env perl
use strict;
use warnings;
use Zeta::Run;
use DBI;
use Carp;

#
#
#
#
#

use constant{
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub {
    # 获取配置
    my $cfg = zkernel->zapp_config();

    # 连接数据库
    my $dbh = zkernel->zapp_dbh();

    # 重置zark的dbh
    my $zark = $cfg->{zark};
    $zark->reset_dbh($dbh);

    # 重置bip的dbh
    my $bip = $cfg->{bi};
    $bip->reset_dbh($dbh);

};

__END__



