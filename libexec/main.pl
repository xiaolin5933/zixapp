#!/usr/bin/perl

use Zeta::Run;
use Zeta::IPC::MsgQ;

use POE;
use Zeta::POE::HTTPD;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub {
    my $cfg = zkernel->zapp_config()->{main};
    Zeta::POE::HTTPD->spawn(
         port   => $cfg->{port}, 
         module => $cfg->{module}, 
         para   => [$cfg->{para}]
    );
    $poe_kernel->run();
    zkernel->process_stopall();
    exit 0;
};

__END__

