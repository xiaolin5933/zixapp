package ZAPP::Test::Load;


sub new {
}

sub execute {
}

1;
__END__

#!perl
use Test::More
use ZAPP::Test::Load;

my $t = ZAPP::Test::Load->new();

plan tests => 1;
$t->execute();

done_testing();


