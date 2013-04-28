package ZAPP::Service;
use strict;
use warnings;
use constant {
	DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
# $cfg
#
sub new {
    my ($class, $cfg)  = @_;
    return bless $cfg , $class;
}

sub handle {
    my ($self, $req)  = @_;
    warn "-----------------got request------------------\n";
    Data::Dump->dump($req) if DEBUG;
    return $self->{svc}->{$req->{svc}}->($self, $req);
}

1;

