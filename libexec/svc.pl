#!/usr/bin/perl
use strict;
use warnings;
use Zeta::Run;
use Net::Stomp;
use DBI;
use Carp;
use POE;
use ZAPP::Service;

use constant{
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub {
    # 重置dbh
    zkernel->zapp_setup();

    # 获取配置
    my $cfg = zkernel->zapp_config();

    # 重置zark
    my $zark = $cfg->{zark};
    $zark->setup($cfg->{dbh});

    # 连接stomp
    $cfg->{_stomp} = zkernel->zapp_stomp($cfg);

    # 构建service的POE session
    Zeta::POE::HTTPD->spawn(
        lfd    => $cfg->{service}->{lfd},
        module => 'ZAPP::Service',
        para   => [ $cfg ],
    ) or confess "can not ZAPP::Service->new";

    # 运行
    $poe_kernel->run();
    
};

__END__

