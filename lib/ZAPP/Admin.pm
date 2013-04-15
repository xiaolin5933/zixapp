package ZAPP::Admin;
use strict;
use warnings;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub new {
    my ($class, $para) = @_;
    bless {}, $class;
}

my $cnt = 0;

sub handle {
    return {
       cnt      => $cnt++,
       datetime => `date +%Y-%m-%d %H:%M:%S`,
    };
}

1;

__END__

