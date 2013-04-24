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
# {
#   dbh         => $dbh,
#   zark        => $zark,
#   bip         => $bip,
#   stomp       => $args->{stomp},
#   serrializer => $args->{serializer},
#   svc         => { xxx => sub { ... }, }
# }
#
sub new {
    my $class = shift;
    return bless { @_ }, $class;
}

sub handle {
    my ($self, $req)  = @_;
    warn "-----------------got request------------------\n";
    Data::Dump->dump($req) if DEBUG;
    return $self->{svc}->{$req->{svc}}->($self, $req);
}



1;
