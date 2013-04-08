#!/usr/bin/perl
use strict;
use warnings;
use Zeta::Run;
use Net::Stomp;
use DBI;
use Carp;
use POE;
use ZAPP::Service;

sub {

    # 获取配置
    my $cfg = zkernel->zapp_config();

    # 获取数据库连接
    my $dbh = zkernel->zapp_dbh();

    # 连接stomp
	my $stp = Net::Stomp->new( 
        {
            hostname => $cfg->{stomp}->{hostname}, 
            port     => $cfg->{stomp}->{port} ,
        }
    ) or confess "can not Net::Stomp with { hostname => $cfg->{stomp}->{hostname}, port => $cfg->{stomp}->{port} }";
    $stp->connect({ login => 'hello', passcode => 'there' });


	# 构建service的POE session
    Zeta::POE::HTTPD->spawn(
        ip     => $cfg->{service}->{ip},
        port   => $cfg->{service}->{port},
        module => 'ZAPP::Service',
        para   => {

            'dbh'        => $dbh,
			'stomp'      => $stp,
			'svc'		 => $cfg->{svc},
			'cfg'		 => $cfg,
        }
    ) or confess "can not ZAPP::Service->new";

    # 运行
    $poe_kernel->run();
    
};

__END__



