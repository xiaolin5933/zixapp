package ZAPP::Test::Service;


sub new {
}

sub execute {
}

1;
__END__

#!perl
use Test::More
use ZAPP::Test::Service;

my $t = ZAPP::Test::Service->new();

plan tests => 1;
$t->execute();

done_testing();
