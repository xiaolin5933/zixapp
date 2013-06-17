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

    # 获取配置
    my $cfg = zkernel->zconfig();
    $cfg->{dbh} = zkernel->zdbh();

    # 重置zark
    my $zark = $cfg->{zark};
    $zark->setup($cfg->{dbh});

    # 连接stomp
    $cfg->{_stomp} = zkernel->zstomp($cfg);

    # 构建service的POE session
    Zeta::POE::HTTPD::JSON->spawn(
        lfd    => $cfg->{service}->{lfd},
        module => 'ZAPP::Service',
        para   => [ $cfg ],
    ) or confess "can not ZAPP::Service->new";

    # 运行
    $poe_kernel->run();
    
};

__END__

