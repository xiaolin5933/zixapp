#!/usr/bin/perl
use strict;
use warnings;
use Zeta::Run;
use Zeta::IPC::MsgQ;

use POE;
use Zeta::POE::HTTPD::JSON;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub {
    my $cfg = zkernel->zconfig();
    warn "begin setup HTTPD..." if DEBUG;
    Zeta::POE::HTTPD::JSON->spawn(
         port   => $cfg->{main}->{port}, 
         module => 'ZAPP::Admin',
         para   => [ $cfg ],
    );
    $poe_kernel->run();
    zkernel->process_stopall();
    exit 0;
};

__END__

