package ZAPP::Service;
use strict;
use warnings;
use base qw/Zark/;

#
# $dbh,    
# {
#   stomp       => $args->{stomp},
#   serrializer => $args->{serializer},
#   svc         => { xxx => sub { ... }, }
# }
#
sub _init {
    my ($self, $args)  = @_;
    bless $args, $self;
}

sub handle {
    my ($self, $req)  = @_;
    warn "-----------------got request------------------\n";
    Data::Dump->dump($req);
    return $self->{svc}->{$req->{svc}}->($self, $req);
}

1;
