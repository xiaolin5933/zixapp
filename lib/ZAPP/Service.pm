package ZAPP::Service;
use strict;
use warnings;

#
# {
#   stomp       => $args->{stomp},
#   dbh         => $args->{dbh},
#   serrializer => $args->{serializer},
#   svc         => { xxx => sub { ... }, }
# }
#
sub new {
    my ($class, $args)  = @_;
    bless $args, $class;
}

sub handle {
    my ($self, $req)  = @_;
    warn "-----------------got request------------------\n";
    Data::Dump->dump($req);
    return $self->{svc}->{$req->{svc}}->($self, $req);
}

1;
